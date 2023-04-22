@echo off

setlocal

set "DIR_PATH=%~f1"
set "FILE_PATH=%~2"

set "FILE_PATH_PREFIX="
if defined DIR_PATH set "FILE_PATH_PREFIX=%DIR_PATH%\"

if defined FILE_PATH_PREFIX ^
if not exist "%FILE_PATH_PREFIX%" (
  echo.%~nx0: error: Directory path does not exist: "%FILE_PATH_PREFIX%"
  exit /b 1
) >&2

if not defined FILE_PATH (
  echo.%~nx0: error: File path does not set.
  exit /b 2
) >&2

if not exist "%FILE_PATH_PREFIX%%FILE_PATH%" (
  echo.%~nx0: error: File path does not exist: "%FILE_PATH_PREFIX%%FILE_PATH%"
  exit /b 3
) >&2

call "%%~dp0__init__.bat" || exit /b

rem add EULA acception into registry to avoid EULA acception GUI dialog in the build process
reg add HKCU\Software\Sysinternals\SigCheck /v EulaAccepted /t REG_DWORD /d 0x00000001 /f >nul 2>nul

"%CONTOOLS_SYSINTERNALS_ROOT%/sigcheck.exe" -n "%FILE_PATH_PREFIX%%FILE_PATH%" 2>nul

exit /b 0
