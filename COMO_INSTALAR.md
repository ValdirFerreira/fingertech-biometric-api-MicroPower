# Fingertech Biometric API — Como Gerar o Instalador

## Pré-requisitos

| Requisito | Versão | Link |
|-----------|--------|------|
| .NET 8 SDK | 8.0+ | https://dotnet.microsoft.com/download/dotnet/8.0 |
| Inno Setup | 6.x | https://jrsoftware.org/isdl.php |
| SDK NITGEN eNBioBSP | Qualquer | Fornecido pela NITGEN |

> **O SDK da NITGEN** deve estar instalado em:  
> `C:\Program Files (x86)\NITGEN\eNBSP SDK Professional\SDK\dotNET\NITGEN.SDK.NBioBSP.dll`

---

## Gerar o instalador (modo fácil)

```
Duplo clique em:  build.bat
```

O script faz automaticamente:
1. `dotnet publish` → compila e publica em `publish\`
2. `ISCC.exe installer.iss` → gera o `.exe` em `installer-output\`

---

## O que o instalador faz ao rodar no cliente

1. **Verifica** se o .NET 8 Runtime está instalado (exige, mostra link se não tiver)
2. **Avisa** se o SDK NITGEN não foi encontrado (não bloqueia)
3. **Tela de configuração** onde o usuário define:
   - Porta HTTP (padrão: 5000)
   - String de conexão Oracle (opcional)
   - Credenciais do Senior RH (opcional)
4. **Instala** os arquivos em `C:\Program Files\Fingertech\BiometricAPI\`
5. **Registra** como Serviço do Windows com restart automático em falhas
6. **Abre a porta** no Firewall do Windows
7. **Inicia** o serviço automaticamente (opcional)

---

## Atualização (rodar o instalador em cima de versão existente)

O instalador detecta automaticamente se já existe uma instalação:
- Para o serviço existente
- Substitui os binários
- **Preserva** o `appsettings.json` com as configurações do cliente
- Registra o serviço novamente
- Reinicia o serviço

---

## Desinstalação

Via **Painel de Controle → Programas → Desinstalar**

O desinstalador:
- Para e remove o serviço do Windows
- Remove a regra do Firewall
- Remove os arquivos (mantém `appsettings.json` se o usuário quiser)

---

## Estrutura de arquivos pós-instalação

```
C:\Program Files\Fingertech\BiometricAPI\
├── BiometricService.exe       ← executável principal
├── appsettings.json           ← configurações (preservado em updates)
├── identification_log.txt     ← log de identificações (gerado em runtime)
└── webapp\                    ← interface web
    └── ...
```

---

## Serviço Windows

| Campo | Valor |
|-------|-------|
| Nome do serviço | `FingertechBiometricAPI` |
| Nome de exibição | `Fingertech Biometric API` |
| Startup | Automático |
| Recuperação | Restart automático (3 tentativas, 60s) |

Comandos úteis:
```cmd
sc start  FingertechBiometricAPI
sc stop   FingertechBiometricAPI
sc query  FingertechBiometricAPI
```
