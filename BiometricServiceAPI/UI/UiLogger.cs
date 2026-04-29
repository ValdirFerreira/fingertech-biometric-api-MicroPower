using Microsoft.Extensions.Logging;

namespace BiometricService.UI
{
    public sealed class UiLoggerProvider : ILoggerProvider
    {
        public ILogger CreateLogger(string categoryName) => new UiLogger(categoryName);
        public void Dispose() { }
    }

    public sealed class UiLogger : ILogger
    {
        private static readonly string[] _skipCategories =
        [
            "Microsoft.AspNetCore.Routing",
            "Microsoft.AspNetCore.StaticFiles",
            "Microsoft.AspNetCore.Hosting.Diagnostics",
        ];

        private readonly string _category;
        public UiLogger(string category) => _category = category;

        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;

        public bool IsEnabled(LogLevel logLevel) => logLevel >= LogLevel.Information;

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state,
            Exception? exception, Func<TState, Exception?, string> formatter)
        {
            if (!IsEnabled(logLevel)) return;
            if (_skipCategories.Any(s => _category.StartsWith(s,
                StringComparison.OrdinalIgnoreCase))) return;

            var level = logLevel switch
            {
                LogLevel.Error       => "ERRO",
                LogLevel.Warning     => "AVISO",
                LogLevel.Information => "INFO",
                _                   => "DBG"
            };

            MainWindow.AppendLog($"[{level}] {formatter(state, exception)}");
        }
    }
}
