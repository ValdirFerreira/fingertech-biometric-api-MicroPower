@echo off
setlocal enabledelayedexpansion
title Fingertech Biometric API - Gerar Instalador

echo.
echo =====================================================
echo   Fingertech Biometric API v2.4.5 (Desktop + API)
echo   Script para gerar o instalador Windows
echo =====================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "CSPROJ=%SCRIPT_DIR%BiometricServiceAPI\BiometricService.csproj"
set "PUBLISH_DIR=%SCRIPT_DIR%publish"
set "INSTALLER_OUTPUT=%SCRIPT_DIR%installer-output"
set "ISS_FILE=%SCRIPT_DIR%installer.iss"
set "BUILD_LOG=%SCRIPT_DIR%build_log.txt"

if not exist "%CSPROJ%" (
    echo [ERRO] Projeto nao encontrado: %CSPROJ%
    echo Certifique-se que build.bat esta na mesma pasta que BiometricServiceAPI\
    pause & exit /b 1
)

:: PASSO 1: Verifica .NET SDK
echo [1/4] Verificando .NET SDK...
where dotnet >nul 2>&1
if errorlevel 1 (
    echo [ERRO] .NET SDK nao encontrado!
    echo        Instale em: https://dotnet.microsoft.com/download/dotnet/8.0
    start https://dotnet.microsoft.com/download/dotnet/8.0
    pause & exit /b 1
)
for /f "tokens=*" %%i in ('dotnet --version 2^>nul') do set DOTNET_VER=%%i
echo       OK - .NET SDK %DOTNET_VER%

:: PASSO 2: Verifica SDK NITGEN
echo [2/4] Verificando SDK NITGEN...
set "NITGEN_DLL=C:\Program Files (x86)\NITGEN\eNBSP SDK Professional\SDK\dotNET\NITGEN.SDK.NBioBSP.dll"
if not exist "%NITGEN_DLL%" (
    echo.
    echo [ERRO] SDK da NITGEN nao encontrado em:
    echo        %NITGEN_DLL%
    echo.
    echo Instale o eNBioBSP SDK da NITGEN e tente novamente.
    pause & exit /b 1
)
echo       OK - SDK NITGEN encontrado

:: PASSO 3: Compila e publica
echo.
echo [3/4] Compilando projeto (aguarde)...
echo -------------------------------------------------------

if exist "%PUBLISH_DIR%"      rmdir /s /q "%PUBLISH_DIR%"
if exist "%INSTALLER_OUTPUT%" rmdir /s /q "%INSTALLER_OUTPUT%"
if exist "%BUILD_LOG%"        del /q "%BUILD_LOG%"

dotnet publish "%CSPROJ%" ^
    --configuration Release ^
    --runtime win-x64 ^
    --self-contained false ^
    --output "%PUBLISH_DIR%" ^
    -p:DebugType=none ^
    -p:DebugSymbols=false > "%BUILD_LOG%" 2>&1

set BUILD_RESULT=%ERRORLEVEL%
type "%BUILD_LOG%"
echo -------------------------------------------------------

if %BUILD_RESULT% NEQ 0 (
    echo.
    echo =====================================================
    echo   [ERRO] FALHA NA COMPILACAO
    echo =====================================================
    echo.
    echo Resumo dos erros:
    echo --------------------------------------------------
    findstr /i " error " "%BUILD_LOG%"
    echo --------------------------------------------------
    echo.
    echo Log completo salvo em: %BUILD_LOG%
    choice /c SN /m "Abrir o log no Bloco de Notas?"
    if errorlevel 1 if not errorlevel 2 notepad "%BUILD_LOG%"
    echo.
    echo Causas mais comuns:
    echo   1. SDK NITGEN nao instalado
    echo   2. .NET 8 SDK nao instalado ^(so Runtime nao basta^)
    echo   3. Execute: dotnet restore
    pause & exit /b 1
)
echo       OK - Build concluido!

:: PASSO 4: Gera instalador
echo.
echo [4/4] Gerando instalador .exe...
echo -------------------------------------------------------

set "ISCC="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"    set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe"         set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

if "%ISCC%"=="" (
    echo [AVISO] Inno Setup 6 nao encontrado.
    echo Projeto compilado em: %PUBLISH_DIR%
    echo Instale o Inno Setup 6 em: https://jrsoftware.org/isdl.php
    start https://jrsoftware.org/isdl.php
    pause & exit /b 0
)

mkdir "%INSTALLER_OUTPUT%" 2>nul
"%ISCC%" "%ISS_FILE%" > "%BUILD_LOG%" 2>&1
set ISS_RESULT=%ERRORLEVEL%
type "%BUILD_LOG%"
echo -------------------------------------------------------

if %ISS_RESULT% NEQ 0 (
    echo [ERRO] Falha ao gerar instalador!
    findstr /i "error\|Error\|failed" "%BUILD_LOG%"
    choice /c SN /m "Abrir o log?"
    if errorlevel 1 if not errorlevel 2 notepad "%BUILD_LOG%"
    pause & exit /b 1
)

echo.
echo =====================================================
for %%f in ("%INSTALLER_OUTPUT%\*.exe") do (
    echo   INSTALADOR GERADO COM SUCESSO!
    echo   Arquivo : %%~nxf
    echo   Local   : %INSTALLER_OUTPUT%\
)
echo =====================================================
echo.
pause >nul
explorer "%INSTALLER_OUTPUT%"
