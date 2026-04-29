// Alias explícitos para evitar ambiguidade entre WPF e WinForms
using WpfApp        = System.Windows.Application;
using WpfWindow     = System.Windows.Window;
using WpfMessageBox = System.Windows.MessageBox;
using WpfStartup    = System.Windows.StartupEventArgs;

using Microsoft.Extensions.Logging.Configuration;
using Microsoft.Extensions.Logging.EventLog;
using System.Windows;

namespace BiometricService.UI
{
    public partial class App : WpfApp
    {
        private WebApplication? _webApp;
        private MainWindow?     _mainWindow;
        private System.Windows.Forms.NotifyIcon? _trayIcon;

        public static App Instance => (App)Current;
        public WebApplication? WebApp => _webApp;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            Task.Run(StartApiAsync);
            _mainWindow = new MainWindow();
            _mainWindow.Show();
            SetupTrayIcon();
        }

        private async Task StartApiAsync()
        {
            try
            {
                var builder = WebApplication.CreateBuilder();

                var urls = builder.Configuration["Urls"] ?? "https://0.0.0.0:53079";
                var uri = new Uri(urls.Split(';')[0].Trim());
                var port = uri.Port;
                var isHttps = uri.Scheme == "https";

                builder.WebHost.ConfigureKestrel(options =>
                {
                    options.ListenAnyIP(port, listenOptions =>
                    {
                        if (isHttps)
                            listenOptions.UseHttps(); // requer: dotnet dev-certs https --trust
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
                builder.Services.AddCors(o =>
                    o.AddPolicy("AllowAll", p =>
                        p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

                _webApp = builder.Build();
                _webApp.UseRouting();
                _webApp.UseCors("AllowAll");
                _webApp.UseDefaultFiles();
                _webApp.UseStaticFiles();
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
                Icon    = System.IO.File.Exists(iconPath)
                            ? new System.Drawing.Icon(iconPath)
                            : System.Drawing.SystemIcons.Application,
                Visible = true,
                Text    = "Fingertech Biometric API"
            };

            var menu = new System.Windows.Forms.ContextMenuStrip();
            menu.Items.Add("Abrir painel",       null, (_, _) => ShowWindow());
            menu.Items.Add("Abrir no navegador", null, (_, _) => OpenBrowser());
            menu.Items.Add(new System.Windows.Forms.ToolStripSeparator());
            menu.Items.Add("Sair",               null, (_, _) => ExitApp());
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
                    new System.Diagnostics.ProcessStartInfo(url) { UseShellExecute = true });
            }
            catch { }
        }

        internal void ExitApp()
        {
            _trayIcon?.Dispose();
            try { _webApp?.StopAsync(TimeSpan.FromSeconds(3)).GetAwaiter().GetResult(); }
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
