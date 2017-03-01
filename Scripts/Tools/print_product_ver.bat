@echo off

setlocal

set "DIR_PATH=%~dpf1"
set "FILE_PATH=%~2"

set "FILE_PATH_PREFIX="
if not "%DIR_PATH%" == "" set "FILE_PATH_PREFIX=%DIR_PATH%\"

if not "%FILE_PATH_PREFIX%" == "" ^
if not exist "%FILE_PATH_PREFIX%" (
  echo.%~nx0: error: Directory path does not exist: "%FILE_PATH_PREFIX%"
  exit /b 1
) >&2

if "%FILE_PATH%" == "" (
  echo.%~nx0: error: File path does not set.
  exit /b 2
) >&2

if not exist "%FILE_PATH_PREFIX%%FILE_PATH%" (
  echo.%~nx0: error: File path does not exist: "%FILE_PATH_PREFIX%%FILE_PATH%"
  exit /b 3
) >&2

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

rem add EULA acception into registry to avoid EULA acception GUI dialog in the build process
reg add HKCU\Software\Sysinternals\SigCheck /v EulaAccepted /t REG_DWORD /d 0x00000001 /f >nul 2>nul

"%TOOLS_PATH%\sigcheck.exe" -n "%FILE_PATH_PREFIX%%FILE_PATH%" 2>nul

exit /b 0
