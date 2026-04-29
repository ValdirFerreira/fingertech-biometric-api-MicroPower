; ============================================================
; Fingertech Biometric API - Inno Setup Installer Script
; Versao: 2.4.5
; ============================================================

#define AppName       "Fingertech Biometric API"
#define AppVersion    "2.4.5"
#define AppPublisher  "Fingertech"
#define AppURL        "https://github.com/FingertechSuporte4"
#define AppExeName    "BiometricService.exe"
#define ServiceName   "FingertechBiometricAPI"
#define ServiceDisplay "Fingertech Biometric API"
#define PublishDir    "publish"

; ============================================================
[Setup]
AppId={{A3F2C1D4-8B5E-4F7A-9C2D-1E6B3A4F5D8C}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} v{#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\Fingertech\BiometricAPI
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=installer-output
OutputBaseFilename=Fingertech-BiometricAPI-Setup-v{#AppVersion}
SetupIconFile=icone-finger.ico
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName} {#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=120
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
MinVersion=10.0
CloseApplications=yes
CloseApplicationsFilter=*{#AppExeName}*
RestartApplications=no
ChangesEnvironment=no

; ============================================================
[Languages]
Name: "ptbr";    MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

; ============================================================
[CustomMessages]
ptbr.PageConfigTitle=Configuracoes da API
ptbr.PageConfigDesc=Configure a porta e as integracoes da API Biometrica
ptbr.LabelPort=Porta HTTP da API (padrao: 5000):
ptbr.LabelOracle=String de conexao Oracle (opcional):
ptbr.LabelOraceHint=Exemplo: User Id=usuario;Password=senha;Data Source=servidor:1521/SID
ptbr.LabelSeniorUrl=URL da API Senior (opcional):
ptbr.LabelSeniorClientId=Client ID Senior:
ptbr.LabelSeniorAccessKey=Access Key Senior:
ptbr.LabelSeniorSecret=Secret Senior:
ptbr.LabelSeniorTenant=Tenant Name Senior:
ptbr.GroupOracle=Integracao Oracle
ptbr.GroupSenior=Integracao Senior RH
ptbr.TaskStartService=Iniciar o servico apos a instalacao
ptbr.TaskOpenBrowser=Abrir interface web apos a instalacao
ptbr.MsgNitgenNotFound=O SDK da NITGEN (eNBioBSP) nao foi encontrado nesta maquina.%n%nO caminho esperado e:%n  C:\Program Files (x86)\NITGEN\eNBSP SDK Professional\SDK\dotNET\NITGEN.SDK.NBioBSP.dll%n%nA API requer este SDK para comunicar com o leitor biometrico.%nVoce pode instalar o SDK depois e a API funcionara normalmente.%n%nDeseja continuar a instalacao mesmo assim?
ptbr.MsgDotNetNotFound=O .NET 8 Runtime nao foi encontrado nesta maquina.%n%nA API requer o .NET 8 Runtime (x64) para funcionar.%n%nDeseja abrir a pagina de download do .NET 8?
ptbr.MsgInvalidPort=Por favor, insira um numero de porta valido entre 1 e 65535.
ptbr.MsgServiceStopping=Parando servico existente para atualizacao...
ptbr.MsgServiceStarting=Iniciando servico...
ptbr.MsgFirewall=Configurando regra de firewall...

english.PageConfigTitle=API Configuration
english.PageConfigDesc=Configure the port and integrations for the Biometric API
english.LabelPort=API HTTP Port (default: 5000):
english.LabelOracle=Oracle connection string (optional):
english.LabelOraceHint=Example: User Id=user;Password=pass;Data Source=host:1521/SID
english.LabelSeniorUrl=Senior API URL (optional):
english.LabelSeniorClientId=Senior Client ID:
english.LabelSeniorAccessKey=Senior Access Key:
english.LabelSeniorSecret=Senior Secret:
english.LabelSeniorTenant=Senior Tenant Name:
english.GroupOracle=Oracle Integration
english.GroupSenior=Senior RH Integration
english.TaskStartService=Start the service after installation
english.TaskOpenBrowser=Open web interface after installation
english.MsgNitgenNotFound=NITGEN SDK (eNBioBSP) was not found on this machine.%n%nExpected path:%n  C:\Program Files (x86)\NITGEN\eNBSP SDK Professional\SDK\dotNET\NITGEN.SDK.NBioBSP.dll%n%nThe API requires this SDK to communicate with the biometric reader.%nYou can install the SDK later and the API will work normally.%n%nDo you want to continue the installation anyway?
english.MsgDotNetNotFound=.NET 8 Runtime was not found on this machine.%n%nThe API requires .NET 8 Runtime (x64) to work.%n%nDo you want to open the .NET 8 download page?
english.MsgInvalidPort=Please enter a valid port number between 1 and 65535.
english.MsgServiceStopping=Stopping existing service for update...
english.MsgServiceStarting=Starting service...
english.MsgFirewall=Configuring firewall rule...

; ============================================================
[Tasks]
Name: "startservice"; Description: "{cm:TaskStartService}"; Flags: checked
Name: "openbrowser";  Description: "{cm:TaskOpenBrowser}"; Flags: unchecked

; ============================================================
[Files]
; Todos os arquivos raiz do publish (exe + dlls + jsons gerados pelo dotnet publish)
; Exceto o appsettings.json que e tratado separadamente abaixo
Source: "{#PublishDir}\*";        DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "appsettings.json,webapp\*,wwwroot\*"

; Configuracao — nao sobrescreve se ja existe (preserva config do usuario em updates)
Source: "{#PublishDir}\appsettings.json"; DestDir: "{app}"; Flags: onlyifdoesntexist

; Frontend web
Source: "{#PublishDir}\webapp\*";  DestDir: "{app}\webapp";  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#PublishDir}\wwwroot\*"; DestDir: "{app}\wwwroot"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; ============================================================
[Icons]
Name: "{group}\{#AppName}";              Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"
Name: "{group}\Interface Web";           Filename: "http://localhost:5000"
Name: "{group}\Desinstalar {#AppName}";  Filename: "{uninstallexe}"
Name: "{commondesktop}\{#AppName}";      Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: not startservice

; ============================================================
[Run]
; Para servico existente se for atualizacao
Filename: "{sys}\sc.exe"; Parameters: "stop ""{#ServiceName}"""; Flags: runhidden waituntilterminated; StatusMsg: "{cm:MsgServiceStopping}"; Check: ServiceExists

; Aguarda o servico parar
Filename: "{sys}\ping.exe"; Parameters: "127.0.0.1 -n 3"; Flags: runhidden waituntilterminated; Check: ServiceExists

; Remove servico antigo se existir (para recriar com novas configuracoes)
Filename: "{sys}\sc.exe"; Parameters: "delete ""{#ServiceName}"""; Flags: runhidden waituntilterminated; Check: ServiceExists

; Registra como servico do Windows
Filename: "{sys}\sc.exe"; Parameters: "create ""{#ServiceName}"" binPath= ""{app}\{#AppExeName} --windows-service"" start= auto DisplayName= ""{#ServiceDisplay}"""; Flags: runhidden waituntilterminated; StatusMsg: "Registrando servico Windows..."

; Configura descricao do servico
Filename: "{sys}\sc.exe"; Parameters: "description ""{#ServiceName}"" ""API de captura biometrica Fingertech - v{#AppVersion}"""; Flags: runhidden waituntilterminated

; Configura restart automatico em caso de falha (3 tentativas, 60s entre cada)
Filename: "{sys}\sc.exe"; Parameters: "failure ""{#ServiceName}"" reset= 86400 actions= restart/60000/restart/60000/restart/60000"; Flags: runhidden waituntilterminated

; Abre porta no firewall (remove regra antiga primeiro)
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""{#AppName}"""; Flags: runhidden waituntilterminated
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""{#AppName}"" dir=in action=allow protocol=TCP localport={code:GetPort} program=""{app}\{#AppExeName}"" description=""Fingertech Biometric API"""; Flags: runhidden waituntilterminated; StatusMsg: "{cm:MsgFirewall}"

; Inicia o servico
Filename: "{sys}\sc.exe"; Parameters: "start ""{#ServiceName}"""; Flags: runhidden waituntilterminated; StatusMsg: "{cm:MsgServiceStarting}"; Tasks: startservice

; Abre interface web no navegador
Filename: "http://localhost:{code:GetPort}"; Flags: shellexec; Tasks: openbrowser; Check: IsTaskSelected('startservice')

; ============================================================
[UninstallRun]
Filename: "{sys}\sc.exe";    Parameters: "stop ""{#ServiceName}""";   Flags: runhidden waituntilterminated
Filename: "{sys}\ping.exe";  Parameters: "127.0.0.1 -n 3";            Flags: runhidden waituntilterminated
Filename: "{sys}\sc.exe";    Parameters: "delete ""{#ServiceName}"""; Flags: runhidden waituntilterminated
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""{#AppName}"""; Flags: runhidden waituntilterminated

; ============================================================
[UninstallDelete]
; Remove arquivos gerados em runtime (nao remove appsettings.json - preserva configuracoes)
Type: files; Name: "{app}\identification_log.txt"
Type: filesandordirs; Name: "{app}\logs"

; ============================================================
[Code]

var
  PageConfig: TWizardPage;
  EdtPort: TEdit;
  EdtOracle: TEdit;
  EdtSeniorUrl: TEdit;
  EdtSeniorClientId: TEdit;
  EdtSeniorAccessKey: TEdit;
  EdtSeniorSecret: TEdit;
  EdtSeniorTenant: TEdit;

// ----------------------------------------------------------------
// Utilitarios
// ----------------------------------------------------------------

function ServiceExists(): Boolean;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\sc.exe'), 'query "{#ServiceName}"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := (ResultCode = 0);
end;

function NitgenSDKInstalled(): Boolean;
begin
  Result := FileExists('C:\Program Files (x86)\NITGEN\eNBSP SDK Professional\SDK\dotNET\NITGEN.SDK.NBioBSP.dll');
end;

function DotNet8Installed(): Boolean;
var
  Key: String;
begin
  Key := 'SOFTWARE\dotnet\Setup\InstalledVersions\x64\sdk';
  Result := RegKeyExists(HKLM, 'SOFTWARE\dotnet\Setup\InstalledVersions\x64\hostfxr');
  if not Result then
    Result := RegKeyExists(HKLM, 'SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\hostfxr');
  // Verifica tambem pelo diretorio
  if not Result then
    Result := DirExists(ExpandConstant('{pf}\dotnet\shared\Microsoft.NETCore.App')) or
              DirExists('C:\Program Files\dotnet\shared\Microsoft.NETCore.App');
end;

function GetPort(Param: String): String;
begin
  if Assigned(EdtPort) and (EdtPort.Text <> '') then
    Result := EdtPort.Text
  else
    Result := '5000';
end;

// ----------------------------------------------------------------
// Pagina de configuracao customizada
// ----------------------------------------------------------------

procedure CreateConfigPage();
var
  LblPort, LblOracle, LblOracleHint, LblSeniorUrl: TLabel;
  LblSeniorClientId, LblSeniorAccessKey, LblSeniorSecret, LblSeniorTenant: TLabel;
  GrpOracle, GrpSenior: TGroupBox;
  Y: Integer;
begin
  PageConfig := CreateCustomPage(
    wpSelectDir,
    ExpandConstant('{cm:PageConfigTitle}'),
    ExpandConstant('{cm:PageConfigDesc}')
  );

  // --- Porta ---
  LblPort := TLabel.Create(PageConfig);
  LblPort.Parent := PageConfig.Surface;
  LblPort.Caption := ExpandConstant('{cm:LabelPort}');
  LblPort.Left := 0;
  LblPort.Top := 0;
  LblPort.Width := PageConfig.SurfaceWidth;

  EdtPort := TEdit.Create(PageConfig);
  EdtPort.Parent := PageConfig.Surface;
  EdtPort.Left := 0;
  EdtPort.Top := 20;
  EdtPort.Width := 120;
  EdtPort.Text := '5000';
  EdtPort.MaxLength := 5;

  // --- Grupo Oracle ---
  Y := 60;
  GrpOracle := TGroupBox.Create(PageConfig);
  GrpOracle.Parent := PageConfig.Surface;
  GrpOracle.Caption := ' ' + ExpandConstant('{cm:GroupOracle}') + ' ';
  GrpOracle.Left := 0;
  GrpOracle.Top := Y;
  GrpOracle.Width := PageConfig.SurfaceWidth;
  GrpOracle.Height := 80;

  LblOracle := TLabel.Create(PageConfig);
  LblOracle.Parent := GrpOracle;
  LblOracle.Caption := ExpandConstant('{cm:LabelOracle}');
  LblOracle.Left := 10;
  LblOracle.Top := 18;
  LblOracle.Width := GrpOracle.Width - 20;

  EdtOracle := TEdit.Create(PageConfig);
  EdtOracle.Parent := GrpOracle;
  EdtOracle.Left := 10;
  EdtOracle.Top := 36;
  EdtOracle.Width := GrpOracle.Width - 20;
  EdtOracle.Text := '';
  EdtOracle.MaxLength := 512;

  LblOracleHint := TLabel.Create(PageConfig);
  LblOracleHint.Parent := GrpOracle;
  LblOracleHint.Caption := ExpandConstant('{cm:LabelOraceHint}');
  LblOracleHint.Left := 10;
  LblOracleHint.Top := 60;
  LblOracleHint.Width := GrpOracle.Width - 20;
  LblOracleHint.Font.Size := 7;

  // --- Grupo Senior ---
  Y := Y + 92;
  GrpSenior := TGroupBox.Create(PageConfig);
  GrpSenior.Parent := PageConfig.Surface;
  GrpSenior.Caption := ' ' + ExpandConstant('{cm:GroupSenior}') + ' ';
  GrpSenior.Left := 0;
  GrpSenior.Top := Y;
  GrpSenior.Width := PageConfig.SurfaceWidth;
  GrpSenior.Height := 200;

  // Senior URL
  LblSeniorUrl := TLabel.Create(PageConfig);
  LblSeniorUrl.Parent := GrpSenior;
  LblSeniorUrl.Caption := ExpandConstant('{cm:LabelSeniorUrl}');
  LblSeniorUrl.Left := 10; LblSeniorUrl.Top := 18;
  EdtSeniorUrl := TEdit.Create(PageConfig);
  EdtSeniorUrl.Parent := GrpSenior;
  EdtSeniorUrl.Left := 10; EdtSeniorUrl.Top := 34;
  EdtSeniorUrl.Width := GrpSenior.Width - 20;
  EdtSeniorUrl.Text := 'https://api.senior.com.br';

  // ClientId + AccessKey (lado a lado)
  LblSeniorClientId := TLabel.Create(PageConfig);
  LblSeniorClientId.Parent := GrpSenior;
  LblSeniorClientId.Caption := ExpandConstant('{cm:LabelSeniorClientId}');
  LblSeniorClientId.Left := 10; LblSeniorClientId.Top := 60;
  EdtSeniorClientId := TEdit.Create(PageConfig);
  EdtSeniorClientId.Parent := GrpSenior;
  EdtSeniorClientId.Left := 10; EdtSeniorClientId.Top := 76;
  EdtSeniorClientId.Width := (GrpSenior.Width - 30) div 2;
  EdtSeniorClientId.Text := '';

  LblSeniorAccessKey := TLabel.Create(PageConfig);
  LblSeniorAccessKey.Parent := GrpSenior;
  LblSeniorAccessKey.Caption := ExpandConstant('{cm:LabelSeniorAccessKey}');
  LblSeniorAccessKey.Left := (GrpSenior.Width div 2) + 5; LblSeniorAccessKey.Top := 60;
  EdtSeniorAccessKey := TEdit.Create(PageConfig);
  EdtSeniorAccessKey.Parent := GrpSenior;
  EdtSeniorAccessKey.Left := (GrpSenior.Width div 2) + 5; EdtSeniorAccessKey.Top := 76;
  EdtSeniorAccessKey.Width := (GrpSenior.Width - 30) div 2;
  EdtSeniorAccessKey.Text := '';

  // Secret + Tenant (lado a lado)
  LblSeniorSecret := TLabel.Create(PageConfig);
  LblSeniorSecret.Parent := GrpSenior;
  LblSeniorSecret.Caption := ExpandConstant('{cm:LabelSeniorSecret}');
  LblSeniorSecret.Left := 10; LblSeniorSecret.Top := 106;
  EdtSeniorSecret := TEdit.Create(PageConfig);
  EdtSeniorSecret.Parent := GrpSenior;
  EdtSeniorSecret.Left := 10; EdtSeniorSecret.Top := 122;
  EdtSeniorSecret.Width := (GrpSenior.Width - 30) div 2;
  EdtSeniorSecret.PasswordChar := '*';
  EdtSeniorSecret.Text := '';

  LblSeniorTenant := TLabel.Create(PageConfig);
  LblSeniorTenant.Parent := GrpSenior;
  LblSeniorTenant.Caption := ExpandConstant('{cm:LabelSeniorTenant}');
  LblSeniorTenant.Left := (GrpSenior.Width div 2) + 5; LblSeniorTenant.Top := 106;
  EdtSeniorTenant := TEdit.Create(PageConfig);
  EdtSeniorTenant.Parent := GrpSenior;
  EdtSeniorTenant.Left := (GrpSenior.Width div 2) + 5; EdtSeniorTenant.Top := 122;
  EdtSeniorTenant.Width := (GrpSenior.Width - 30) div 2;
  EdtSeniorTenant.Text := '';
end;

// ----------------------------------------------------------------
// Gera o appsettings.json com as configuracoes do usuario
// ----------------------------------------------------------------

procedure WriteAppSettings();
var
  Port, OracleConn, SeniorUrl, SeniorClientId, SeniorAccessKey, SeniorSecret, SeniorTenant: String;
  Json: TStringList;
  FilePath: String;
begin
  Port           := EdtPort.Text;
  OracleConn     := EdtOracle.Text;
  SeniorUrl      := EdtSeniorUrl.Text;
  SeniorClientId := EdtSeniorClientId.Text;
  SeniorAccessKey:= EdtSeniorAccessKey.Text;
  SeniorSecret   := EdtSeniorSecret.Text;
  SeniorTenant   := EdtSeniorTenant.Text;

  FilePath := ExpandConstant('{app}\appsettings.json');

  Json := TStringList.Create;
  try
    Json.Add('{');
    Json.Add('  "Urls": "http://0.0.0.0:' + Port + '",');
    Json.Add('  "OracleConnection": "' + OracleConn + '",');
    Json.Add('  "Senior": {');
    Json.Add('    "ApiUrl": "' + SeniorUrl + '",');
    Json.Add('    "ClientId": "' + SeniorClientId + '",');
    Json.Add('    "AccessKey": "' + SeniorAccessKey + '",');
    Json.Add('    "Secret": "' + SeniorSecret + '",');
    Json.Add('    "TenantName": "' + SeniorTenant + '"');
    Json.Add('  },');
    Json.Add('  "Logging": {');
    Json.Add('    "LogLevel": {');
    Json.Add('      "Default": "Information",');
    Json.Add('      "Microsoft.AspNetCore": "Warning"');
    Json.Add('    }');
    Json.Add('  }');
    Json.Add('}');
    Json.SaveToFile(FilePath);
  finally
    Json.Free;
  end;
end;

// ----------------------------------------------------------------
// Carrega appsettings existente para pre-preencher campos
// ----------------------------------------------------------------

procedure LoadExistingSettings();
var
  FilePath, Content: String;
  P1, P2: Integer;

  function ExtractJsonValue(const Json, Key: String): String;
  var
    SearchStr, Trimmed: String;
    Pos1, Pos2: Integer;
  begin
    Result := '';
    SearchStr := '"' + Key + '"';
    Pos1 := Pos(SearchStr, Json);
    if Pos1 = 0 then Exit;
    Pos1 := Pos(':', Copy(Json, Pos1, Length(Json))) + Pos1;
    // Pula espacos e acha a aspa de abertura
    while (Pos1 <= Length(Json)) and ((Json[Pos1] = ' ') or (Json[Pos1] = '"') or (Json[Pos1] = ':')) do
      Inc(Pos1);
    Pos2 := Pos1;
    while (Pos2 <= Length(Json)) and (Json[Pos2] <> '"') and (Json[Pos2] <> ',') and (Json[Pos2] <> #13) and (Json[Pos2] <> #10) do
      Inc(Pos2);
    Result := Copy(Json, Pos1, Pos2 - Pos1);
  end;

begin
  FilePath := ExpandConstant('{app}\appsettings.json');
  if not FileExists(FilePath) then Exit;

  if not LoadStringFromFile(FilePath, Content) then Exit;

  // Porta
  P1 := Pos('"Urls"', Content);
  if P1 > 0 then
  begin
    P1 := Pos(':', Copy(Content, P1 + 6, Length(Content))) + P1 + 5;
    P2 := Pos('"', Copy(Content, P1, Length(Content)));
    if P2 > 0 then
    begin
      // Extrai a porta da URL
      P1 := Pos(':', Copy(Content, P1, Length(Content))) + P1;
      P2 := Pos('"', Copy(Content, P1, Length(Content))) + P1 - 1;
      EdtPort.Text := Copy(Content, P1, P2 - P1);
    end;
  end;

  EdtOracle.Text         := ExtractJsonValue(Content, 'OracleConnection');
  EdtSeniorUrl.Text      := ExtractJsonValue(Content, 'ApiUrl');
  EdtSeniorClientId.Text := ExtractJsonValue(Content, 'ClientId');
  EdtSeniorAccessKey.Text:= ExtractJsonValue(Content, 'AccessKey');
  EdtSeniorSecret.Text   := ExtractJsonValue(Content, 'Secret');
  EdtSeniorTenant.Text   := ExtractJsonValue(Content, 'TenantName');
end;

// ----------------------------------------------------------------
// Eventos do Setup
// ----------------------------------------------------------------

function InitializeSetup(): Boolean;
begin
  Result := True;

  // Verifica .NET 8
  if not DotNet8Installed() then
  begin
    if MsgBox(ExpandConstant('{cm:MsgDotNetNotFound}'), mbError, MB_YESNO) = IDYES then
      ShellExec('open', 'https://dotnet.microsoft.com/en-us/download/dotnet/8.0', '', '', SW_SHOW, ewNoWait, 0);
    Result := False;
    Exit;
  end;

  // Avisa sobre SDK NITGEN (nao bloqueia)
  if not NitgenSDKInstalled() then
    MsgBox(ExpandConstant('{cm:MsgNitgenNotFound}'), mbConfirmation, MB_OK);
end;

procedure InitializeWizard();
begin
  CreateConfigPage();
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = PageConfig.ID then
    if ServiceExists() then
      LoadExistingSettings();
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  PortNum: Integer;
begin
  Result := True;

  if CurPageID = PageConfig.ID then
  begin
    // Valida porta
    PortNum := StrToIntDef(EdtPort.Text, 0);
    if (PortNum < 1) or (PortNum > 65535) then
    begin
      MsgBox(ExpandConstant('{cm:MsgInvalidPort}'), mbError, MB_OK);
      EdtPort.SetFocus;
      Result := False;
      Exit;
    end;

    // Define porta padrao para Senior se vazio
    if EdtSeniorUrl.Text = '' then
      EdtSeniorUrl.Text := 'https://api.senior.com.br';
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  // Apos instalar os arquivos, grava o appsettings com as configuracoes do usuario
  if CurStep = ssPostInstall then
    WriteAppSettings();
end;

