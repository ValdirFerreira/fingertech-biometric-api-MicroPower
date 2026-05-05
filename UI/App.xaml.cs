// Alias explícitos para evitar ambiguidade entre WPF e WinForms
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Configuration;
using Microsoft.Extensions.Logging.EventLog;
using System.Windows;
using WpfApp = System.Windows.Application;
using WpfMessageBox = System.Windows.MessageBox;
using WpfStartup = System.Windows.StartupEventArgs;
using WpfWindow = System.Windows.Window;

namespace BiometricService.UI
{
    public partial class App : WpfApp
    {
        private WebApplication? _webApp;
        private MainWindow? _mainWindow;
        private System.Windows.Forms.NotifyIcon? _trayIcon;

        public static App Instance => (App)Current;
        public WebApplication? WebApp => _webApp;

        //protected override void OnStartup(StartupEventArgs e)
        //{
        //    base.OnStartup(e);

        //    Task.Run(StartApiAsync);

        //    _mainWindow = new MainWindow();
        //    _mainWindow.Show();

        //    SetupTrayIcon();
        //}

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            Task.Run(StartApiAsync);

            _mainWindow = new MainWindow();
            _mainWindow.Show();

            SetupTrayIcon();

            // ← COLOCA AQUI
            Task.Run(async () =>
            {
                await Task.Delay(3000);
                Dispatcher.Invoke(() => _mainWindow?.AbrirSistemaAutomatico());
            });
        }

        private async Task StartApiAsync()
        {
            try
            {
                var builder = WebApplication.CreateBuilder();

                // ✅ Usa localhost + dev-cert confiável pelo Chrome (rodar "dotnet dev-certs https --trust" na máquina do usuário)
                const int port = 53079;
                var urls = $"https://localhost:{port}";

                builder.WebHost.ConfigureKestrel(options =>
                {
                    options.ListenLocalhost(port, listenOptions =>
                    {
                        listenOptions.UseHttps(); // usa o dev-cert confiável instalado na máquina
                    });
                });

                builder.Logging.ClearProviders();
                builder.Logging.AddProvider(new UiLoggerProvider());

                builder.Services.AddWindowsService();

                LoggerProviderOptions.RegisterProviderOptions<EventLogSettings,
                    EventLogLoggerProvider>(builder.Services);

                builder.Services.AddHttpClient();
                builder.Services.AddScoped<Biometric>();
                builder.Services.AddSingleton<APIService>();
                builder.Services.AddHostedService(
                    sp => sp.GetRequiredService<APIService>());
                builder.Services.AddControllers();

                builder.Services.AddCors(options =>
                {
                    options.AddPolicy("AllowAll", policy =>
                    {
                        policy
                            .SetIsOriginAllowed(origin =>
                            {
                                if (string.IsNullOrEmpty(origin)) return false;

                                var uri = new Uri(origin);
                                var host = uri.Host.ToLower();

                                return
                                    host == "localhost" ||
                                    host == "127.0.0.1" ||
                                    host == "cepera.staging02.micropower.com.br" ||
                                    host.EndsWith(".micropower.com.br");
                            })
                            .AllowAnyMethod()
                            .AllowAnyHeader()
                            .AllowCredentials()
                            .WithExposedHeaders("*");
                    });
                });

                _webApp = builder.Build();

                // ✅ 1. Private Network Access (deve ser o PRIMEIRO middleware)
                // Necessário para o Chrome permitir que sites HTTPS acessem localhost
                _webApp.Use(async (context, next) =>
                {
                    context.Response.Headers.Append("Access-Control-Allow-Private-Network", "true");

                    if (context.Request.Method == "OPTIONS")
                    {
                        var origin = context.Request.Headers["Origin"].ToString();
                        if (!string.IsNullOrEmpty(origin))
                            context.Response.Headers.Append("Access-Control-Allow-Origin", origin);

                        context.Response.Headers.Append("Access-Control-Allow-Methods", "*");
                        context.Response.Headers.Append("Access-Control-Allow-Headers", "*");
                        context.Response.Headers.Append("Access-Control-Allow-Credentials", "true");
                        context.Response.StatusCode = 204;
                        return;
                    }

                    await next();
                });

                // ✅ 2. CORS
                _webApp.UseCors("AllowAll");

                // ✅ 3. Routing e arquivos estáticos
                _webApp.UseRouting();
                _webApp.UseDefaultFiles();
                _webApp.UseStaticFiles();

                // ✅ 4. Controllers por último
                _webApp.MapControllers();

                _webApp.Lifetime.ApplicationStarted.Register(() =>
                    Dispatcher.Invoke(() => _mainWindow?.OnApiStarted(urls)));

                await _webApp.RunAsync();
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(() => WpfMessageBox.Show(
                    $"Erro ao iniciar a API:\n\n{ex.Message}",
                    "Fingertech Biometric API",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error));
            }
        }

        private void SetupTrayIcon()
        {
            var iconPath = System.IO.Path.Combine(
                AppDomain.CurrentDomain.BaseDirectory, "icone-finger.ico");

            _trayIcon = new System.Windows.Forms.NotifyIcon
            {
                Icon = System.IO.File.Exists(iconPath)
                            ? new System.Drawing.Icon(iconPath)
                            : System.Drawing.SystemIcons.Application,
                Visible = true,
                Text = "Fingertech Biometric API"
            };

            var menu = new System.Windows.Forms.ContextMenuStrip();
            menu.Items.Add("Abrir painel", null, (_, _) => ShowWindow());
            menu.Items.Add("Abrir no navegador", null, (_, _) => OpenBrowser());
            menu.Items.Add(new System.Windows.Forms.ToolStripSeparator());
            menu.Items.Add("Sair", null, (_, _) => ExitApp());

            _trayIcon.ContextMenuStrip = menu;
            _trayIcon.DoubleClick += (_, _) => ShowWindow();
        }

        private void ShowWindow()
        {
            Dispatcher.Invoke(() =>
            {
                _mainWindow ??= new MainWindow();
                _mainWindow.Show();
                _mainWindow.WindowState = WindowState.Normal;
                _mainWindow.Activate();
            });
        }

        private void OpenBrowser()
        {
            try
            {
                var url = (_webApp?.Urls?.FirstOrDefault() ?? "http://localhost:5000")
                    .Replace("0.0.0.0", "localhost");

                System.Diagnostics.Process.Start(
                    new System.Diagnostics.ProcessStartInfo(url)
                    {
                        UseShellExecute = true
                    });
            }
            catch { }
        }

        internal void ExitApp()
        {
            _trayIcon?.Dispose();

            try
            {
                _webApp?.StopAsync(TimeSpan.FromSeconds(3))
                       .GetAwaiter()
                       .GetResult();
            }
            catch { }

            Shutdown();
        }

        protected override void OnExit(ExitEventArgs e)
        {
            _trayIcon?.Dispose();
            base.OnExit(e);
        }

        [STAThread]
        public static void Main()
        {
            var app = new App();
            app.InitializeComponent();
            app.Run();
        }
    }
}