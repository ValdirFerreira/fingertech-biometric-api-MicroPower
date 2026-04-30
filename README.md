# Fingertech Biometric API

API REST para captura e identificação biométrica com leitores **NITGEN NBioBSP**, empacotada como aplicação desktop Windows (WPF) com servidor HTTP/HTTPS embutido.

## Funcionalidades

- Captura de digitais e geração de templates biométricos
- Identificação 1:1 (verificação) e 1:N (identificação em memória)
- Modo de identificação contínua em background
- Carregamento de templates via Oracle ou API Senior RH
- Interface desktop WPF com painel de status em tempo real
- Ícone na bandeja do sistema (system tray)
- Instalador Windows gerado com Inno Setup

## Tecnologias

- .NET 8 / C#
- WPF (Windows Presentation Foundation)
- ASP.NET Core (Kestrel embutido)
- NITGEN NBioBSP SDK
- Oracle.ManagedDataAccess
- Inno Setup 6

## Pré-requisitos

| Requisito | Versão |
|-----------|--------|
| Windows | 10 ou superior (x64) |
| .NET 8 SDK | 8.0+ |
| NITGEN eNBioBSP SDK | Qualquer |
| Inno Setup | 6.x |

## Como compilar

```bash
# Restaurar dependências
dotnet restore

# Compilar
dotnet build --configuration Release
```

## Como gerar o instalador

```bash
# Duplo clique no build.bat
# ou via linha de comando:
dotnet publish BiometricServiceAPI/BiometricService.csproj \
  --configuration Release \
  --runtime win-x64 \
  --self-contained false \
  --output publish/
```

Com o Inno Setup instalado, o instalador é gerado automaticamente após o publish via Visual Studio (perfil `Installer`).

## Endpoints disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/apiservice/capture-hash` | Captura digital e retorna template |
| GET | `/apiservice/capture-for-verify` | Captura para verificação |
| POST | `/apiservice/match-one-on-one` | Match 1:1 |
| GET | `/apiservice/identification` | Identificação 1:N |
| POST | `/apiservice/load-to-memory` | Carrega templates na memória |
| POST | `/apiservice/load-from-db` | Carrega do Oracle |
| POST | `/apiservice/load-from-senior` | Carrega do Senior RH |
| POST | `/apiservice/identification/start` | Inicia identificação contínua |
| POST | `/apiservice/identification/stop` | Para identificação contínua |
| GET | `/apiservice/identification/status` | Status do modo contínuo |

## Configuração

Edite o `appsettings.json` na pasta de instalação:

```json
{
  "Urls": "https://0.0.0.0:53079",
  "OracleConnection": "User Id=user;Password=pass;Data Source=host:1521/SID",
  "Senior": {
    "ApiUrl": "https://api.senior.com.br",
    "ClientId": "...",
    "AccessKey": "...",
    "Secret": "...",
    "TenantName": "..."
  }
}
```

Para HTTPS, execute uma vez na máquina:
```bash
dotnet dev-certs https --trust
```

## Estrutura do projeto

```
BiometricServiceAPI/
├── Controllers/
│   └── APIController.cs       # Endpoints REST
├── Modules/
│   └── Biometric.cs           # Lógica de captura e matching
├── UI/
│   ├── App.xaml(.cs)          # Ponto de entrada WPF + inicialização do Kestrel
│   ├── MainWindow.xaml(.cs)   # Janela principal com painel de status
│   └── UiLogger.cs            # Redireciona logs do ASP.NET para a UI
├── APIService.cs              # BackgroundService + NBioBSP + IndexSearch
├── GlobalUsings.cs            # Usings globais
├── appsettings.json           # Configurações
├── BiometricService.csproj
installer.iss                  # Script Inno Setup
build.bat                      # Script de build e geração do instalador
```

## Licença

Proprietário — Fingertech © 2025

## Como gerar o instalador .exe (NSIS)

### Pré-requisitos
1. Instale o **NSIS** (gratuito) → https://nsis.sourceforge.io/Download
   - Baixe o `nsis-3.xx-setup.exe` e instale normalmente

### Estrutura de pastas

Crie uma pasta `C:\installer_build\` com essa estrutura:

```
C:\installer_build\
├── installer.nsi          ← script NSIS (disponível no repositório)
└── publish_files\         ← arquivos gerados pelo dotnet publish
    ├── BiometricService.exe
    ├── *.dll
    ├── appsettings.json
    ├── webapp\
    └── wwwroot\
```

### Gerar o `.exe`

1. Instale o NSIS → https://nsis.sourceforge.io/Download
2. Monte a pasta conforme estrutura acima
3. Clique com botão direito no `installer.nsi` → **"Compile NSIS Script"**
4. O instalador `Fingertech-BiometricAPI-Setup-v2.4.5.exe` é gerado na mesma pasta

> Toda vez que gerar um novo build do projeto, basta substituir os arquivos dentro de `publish_files\` e compilar o script novamente.
