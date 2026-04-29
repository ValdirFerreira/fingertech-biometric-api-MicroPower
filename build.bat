@echo off
setlocal enabledelayedexpansion
title Fingertech - Gerar Instalador

echo.
echo =====================================================
echo   Fingertech Biometric API - Gerar Instalador
echo =====================================================
echo.

:: ============================================================
:: EDITE ESTES CAMINHOS SE NECESSARIO
:: ============================================================
set "PROJETO=C:\CeperaCustom_6_6_1_1\BiometricServiceAPI_completo-version-git\BiometricServiceAPI\BiometricService.csproj"
set "PUBLISH=C:\CeperaCustom_6_6_1_1\BiometricServiceAPI_completo-version-git\publish"
set "INSTALLER_OUTPUT=C:\CeperaCustom_6_6_1_1\BiometricServiceAPI_completo-version-git\installer-output"
set "ISS=C:\CeperaCustom_6_6_1_1\BiometricServiceAPI_completo-version-git\installer.iss"
set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
:: ============================================================

echo Projeto : %PROJETO%
echo Publish : %PUBLISH%
echo Saida   : %INSTALLER_OUTPUT%
echo.

:: Verifica arquivos necessarios
if not exist "%PROJETO%" (
    echo [ERRO] Projeto nao encontrado: %PROJETO%
    pause & exit /b 1
)
if not exist "%ISS%" (
    echo [ERRO] installer.iss nao encontrado: %ISS%
    pause & exit /b 1
)
if not exist "%ISCC%" (
    echo [ERRO] Inno Setup nao encontrado: %ISCC%
    pause & exit /b 1
)

:: Limpa pastas anteriores
echo Limpando builds anteriores...
if exist "%PUBLISH%"           rmdir /s /q "%PUBLISH%"
if exist "%INSTALLER_OUTPUT%"  rmdir /s /q "%INSTALLER_OUTPUT%"
mkdir "%PUBLISH%"
mkdir "%INSTALLER_OUTPUT%"

:: Compila
echo.
echo [1/2] Compilando projeto...
echo -------------------------------------------------------
dotnet publish "%PROJETO%" --configuration Release --runtime win-x64 --self-contained false --output "%PUBLISH%" -p:DebugType=none -p:DebugSymbols=false
echo -------------------------------------------------------

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Falha na compilacao! Veja os erros acima.
    pause & exit /b 1
)

echo.
echo Arquivos gerados em publish\:
dir "%PUBLISH%" /b
echo.

:: Gera instalador
echo [2/2] Gerando instalador...
echo -------------------------------------------------------
"%ISCC%" "%ISS%"
echo -------------------------------------------------------

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Falha ao gerar instalador!
    pause & exit /b 1
)

echo.
echo =====================================================
echo   SUCESSO!
echo.
dir "%INSTALLER_OUTPUT%\*.exe" /b 2>nul
echo.
echo   Local: %INSTALLER_OUTPUT%\
echo =====================================================
echo.
pause
explorer "%INSTALLER_OUTPUT%"
