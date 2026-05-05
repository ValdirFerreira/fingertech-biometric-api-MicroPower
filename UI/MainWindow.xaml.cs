// Alias explícitos para evitar ambiguidade entre WPF e WinForms
using WpfMessageBox = System.Windows.MessageBox;

using System.Collections.ObjectModel;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Windows;
using System.Windows.Media;
using System.Windows.Threading;

namespace BiometricService.UI
{
    public sealed class IdLogEntry
    {
        public DateTime Timestamp { get; init; }
        public uint Id { get; init; }
        public string StatusText => Id != 0 ? "✓ Identificado" : "✗ Não encontrado";
    }

    public partial class MainWindow : Window
    {
        // ── estado ───────────────────────────────────────────────────────────────
        private readonly ObservableCollection<IdLogEntry> _idLog = [];
        private readonly DispatcherTimer _refreshTimer = new();
        private static readonly StringBuilder _logBuffer = new();
        private static MainWindow? _instance;

        // ── construtor ───────────────────────────────────────────────────────────
        public MainWindow()
        {
            InitializeComponent();
            _instance = this;

            GridIdLog.ItemsSource = _idLog;

            _refreshTimer.Interval = TimeSpan.FromSeconds(2);
            _refreshTimer.Tick += RefreshMetrics;
            _refreshTimer.Start();

            LoadConfig();

            TxtEndpoints.Text = string.Join('\n', new[]
            {
                "GET  /apiservice/capture-hash",
                "GET  /apiservice/capture-for-verify",
                "POST /apiservice/match-one-on-one",
                "GET  /apiservice/identification",
                "POST /apiservice/load-to-memory",
                "POST /apiservice/load-from-db",
                "POST /apiservice/load-from-senior",
                "POST /apiservice/identification/start",
                "POST /apiservice/identification/stop",
                "GET  /apiservice/identification/status",
            });
        }

        // ── chamado pelo App quando o Kestrel sobe ───────────────────────────────
        public void OnApiStarted(string urls)
        {
            StatusDot.Fill = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x22, 0xC5, 0x5E));
            MetricStatus.Text = "Online";
            MetricStatus.Foreground = (System.Windows.Media.Brush)FindResource("SuccessBrush");
            MetricPort.Text = ExtractPort(urls);
            StatusBarText.Text = $"API rodando em {urls.Replace("0.0.0.0", "localhost")}";
            AppendLog($"Servidor iniciado — {urls.Replace("0.0.0.0", "localhost")}");
        }

        // ── log estático (chamado pelo UiLogger de qualquer thread) ──────────────
        public static void AppendLog(string message)
        {
            _instance?.Dispatcher.BeginInvoke(() =>
            {
                lock (_logBuffer)
                {
                    _logBuffer.AppendLine($"{DateTime.Now:HH:mm:ss}  {message}");
                    var text = _logBuffer.ToString();
                    var count = text.Count(c => c == '\n');
                    if (count > 150)
                    {
                        var idx = 0;
                        for (var i = 0; i < count - 120; i++)
                            idx = text.IndexOf('\n', idx) + 1;
                        _logBuffer.Clear();
                        _logBuffer.Append(text[idx..]);
                    }
                }
                _instance!.TxtLog.Text = _logBuffer.ToString();
                _instance.LogScroller.ScrollToBottom();
            }, DispatcherPriority.Background);
        }

        // ── timer: atualiza métricas a cada 2s ───────────────────────────────────
        private void RefreshMetrics(object? sender, EventArgs e)
        {
            var svc = GetApiService();
            if (svc == null) return;

            try
            {
                svc._IndexSearch.GetDataCount(out uint count);
                MetricTemplates.Text = count.ToString();
            }
            catch { MetricTemplates.Text = "—"; }

            var running = svc.IsContinuousRunning;
            MetricContinuous.Text = running ? "Ativo" : "Parado";
            MetricContinuous.Foreground = (System.Windows.Media.Brush)FindResource(
                running ? "SuccessBrush" : "TextSecondaryBrush");
            BtnStartContinuous.IsEnabled = !running;
            BtnStopContinuous.IsEnabled = running;

            var existing = _idLog.Select(x => x.Timestamp).ToHashSet();
            foreach (var r in svc.IdentificationLog
                .OrderByDescending(x => x.Timestamp).Take(50))
                if (!existing.Contains(r.Timestamp))
                    _idLog.Insert(0, new IdLogEntry
                    { Id = r.Id, Timestamp = r.Timestamp });
            while (_idLog.Count > 50) _idLog.RemoveAt(_idLog.Count - 1);

            StatusBarRight.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
        }

        // ── identificação contínua ────────────────────────────────────────────────
        private void BtnStartContinuous_Click(object sender, RoutedEventArgs e)
        {
            var svc = GetApiService();
            if (svc == null) { ShowError("Serviço não disponível ainda."); return; }
            uint level = (uint)(CmbSecuLevel.SelectedIndex + 1);
            svc.StartContinuous(level);
            AppendLog($"Identificação contínua iniciada (nível {level})");
        }

        private void BtnStopContinuous_Click(object sender, RoutedEventArgs e)
        {
            GetApiService()?.StopContinuous();
            AppendLog("Identificação contínua parada.");
        }

        // ── configurações ─────────────────────────────────────────────────────────
        private void LoadConfig()
        {
            try
            {
                var path = AppSettingsPath();
                if (!System.IO.File.Exists(path)) return;

                var json = JsonNode.Parse(System.IO.File.ReadAllText(path));
                if (json == null) return;

                CfgPort.Text = ExtractPort(json["Urls"]?.ToString() ?? "http://0.0.0.0:5000");
                CfgOracle.Text = json["OracleConnection"]?.ToString() ?? string.Empty;
                CfgSeniorUrl.Text = json["Senior"]?["ApiUrl"]?.ToString() ?? string.Empty;
                CfgSeniorTenant.Text = json["Senior"]?["TenantName"]?.ToString() ?? string.Empty;
                CfgSeniorClientId.Text = json["Senior"]?["ClientId"]?.ToString() ?? string.Empty;
                CfgSeniorAccessKey.Text = json["Senior"]?["AccessKey"]?.ToString() ?? string.Empty;
                CfgSistemaUrl.Text = json["SistemaUrl"]?.ToString() ?? "https://cepera.staging02.micropower.com.br";
            }
            catch (Exception ex)
            {
                AppendLog($"[AVISO] Erro ao carregar configurações: {ex.Message}");
            }
        }

        private void BtnSaveConfig_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(CfgPort.Text.Trim(), out var port) || port < 1 || port > 65535)
            {
                ShowError("Porta inválida. Use um número entre 1 e 65535.");
                return;
            }

            try
            {
                var json = new JsonObject
                {
                    ["Urls"] = $"http://0.0.0.0:{port}",
                    ["OracleConnection"] = CfgOracle.Text.Trim(),
                    ["SistemaUrl"] = CfgSistemaUrl.Text.Trim(),
                    ["Senior"] = new JsonObject
                    {
                        ["ApiUrl"] = CfgSeniorUrl.Text.Trim(),
                        ["ClientId"] = CfgSeniorClientId.Text.Trim(),
                        ["AccessKey"] = CfgSeniorAccessKey.Text.Trim(),
                        ["Secret"] = CfgSeniorSecret.Password,
                        ["TenantName"] = CfgSeniorTenant.Text.Trim(),
                    },
                    ["Logging"] = new JsonObject
                    {
                        ["LogLevel"] = new JsonObject
                        {
                            ["Default"] = "Information",
                            ["Microsoft.AspNetCore"] = "Warning",
                        }
                    }
                };

                System.IO.File.WriteAllText(AppSettingsPath(),
                    json.ToJsonString(new JsonSerializerOptions { WriteIndented = true }));

                TxtSaveStatus.Visibility = Visibility.Visible;
                AppendLog("Configurações salvas. Reinicie para aplicar mudança de porta.");

                var timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(3) };
                timer.Tick += (_, _) =>
                {
                    TxtSaveStatus.Visibility = Visibility.Collapsed;
                    timer.Stop();
                };
                timer.Start();
            }
            catch (Exception ex) { ShowError($"Erro ao salvar: {ex.Message}"); }
        }

        // ── botões ────────────────────────────────────────────────────────────────
        private void BtnClearSysLog_Click(object sender, RoutedEventArgs e)
        {
            lock (_logBuffer) _logBuffer.Clear();
            TxtLog.Text = string.Empty;
        }

        private void BtnClearIdLog_Click(object sender, RoutedEventArgs e) =>
            _idLog.Clear();

        private void BtnAbrirSistema_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var url = CfgSistemaUrl.Text.Trim();
                if (string.IsNullOrEmpty(url))
                    url = "https://cepera.staging02.micropower.com.br";

                AbrirChromeInseguro(url);
            }
            catch (Exception ex)
            {
                ShowError($"Erro ao abrir o Chrome:\n{ex.Message}");
            }
        }


        public void AbrirSistemaAutomatico()
        {
            try
            {
                var url = CfgSistemaUrl.Text.Trim();
                if (string.IsNullOrEmpty(url))
                    url = "https://cepera.staging02.micropower.com.br";

                AbrirChromeInseguro(url);
            }
            catch (Exception ex)
            {
                ShowError($"Erro ao abrir o Chrome:\n{ex.Message}");
            }
        }

        private static void AbrirChromeInseguro(string url)
        {
            // Caminhos possiveis do Chrome
            var chromePaths = new[]
            {
                @"C:\Program Files\Google\Chrome\Application\chrome.exe",
                @"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    @"Google\Chrome\Application\chrome.exe"),
            };

            var chrome = chromePaths.FirstOrDefault(System.IO.File.Exists);

            if (chrome == null)
            {
                // Chrome nao encontrado - abre no navegador padrao
                System.Diagnostics.Process.Start(
                    new System.Diagnostics.ProcessStartInfo(url) { UseShellExecute = true });
                return;
            }

            // Abre Chrome com flags que ignoram erros de certificado e segurança
            // Usa um perfil separado para nao afetar o Chrome normal do usuario
            var profileDir = System.IO.Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Fingertech", "ChromeProfile");

            var args = string.Join(" ", new[]
            {
                "--ignore-certificate-errors",
                "--ignore-urlfetchfailure",
                "--allow-running-insecure-content",
                "--disable-web-security",
                "--allow-insecure-localhost",
                $"--unsafely-treat-insecure-origin-as-secure=https://fingertech.local:53079",
                $"--user-data-dir=\"{profileDir}\"",
                $"\"{url}\""
            });

            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = chrome,
                Arguments = args,
                UseShellExecute = false
            });
        }

        private void BtnBrowser_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var port = MetricPort.Text == "—" ? "5000" : MetricPort.Text;
                System.Diagnostics.Process.Start(
                    new System.Diagnostics.ProcessStartInfo(
                        $"http://localhost:{port}")
                    { UseShellExecute = true });
            }
            catch { }
        }

        private void BtnMinimize_Click(object sender, RoutedEventArgs e) => Hide();

        private void Window_Closing(object sender,
            System.ComponentModel.CancelEventArgs e)
        {
            e.Cancel = true;
            Hide();
        }

        // ── helpers ───────────────────────────────────────────────────────────────
        private static APIService? GetApiService()
        {
            try { return App.Instance.WebApp?.Services.GetRequiredService<APIService>(); }
            catch { return null; }
        }

        private static string ExtractPort(string urls)
        {
            try { return new Uri(urls.Split(';')[0].Trim()).Port.ToString(); }
            catch { return "5000"; }
        }

        private static string AppSettingsPath() =>
            System.IO.Path.Combine(
                AppDomain.CurrentDomain.BaseDirectory, "appsettings.json");

        private static void ShowError(string msg) =>
            WpfMessageBox.Show(msg, "Atenção",
                MessageBoxButton.OK, MessageBoxImage.Warning);
    }
}
