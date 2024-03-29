@echo off

rem Description:
rem   Script disables telemetry junk from Microsoft and others...
rem

setlocal

rem scripts must run in administrator mode
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /C %%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b -254
) >&2

:X64
rem WORKAROUND:
rem   Under pure Windows x64 create system64 directory to bypass sysnative directory permissions

if exist "%SystemRoot%\System64\*" goto IGNORE_SYSTEM64_CREATE

call :CMD mklink /D "%%SystemRoot%%\System64" "%%SystemRoot%%\System32"
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: run `mklink.exe /D "%SystemRoot%\System64" "%SystemRoot%\System32"` manually or restart system!
  exit /b -253
) >&2

:X32
:IGNORE_SYSTEM64_CREATE

set "COMPATTELRUNNER_LOG_DIR=%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger"

echo Stopping and disabling CompatTelRunner.exe services..
call :CMD sc stop DiagTrack
call :CMD sc config DiagTrack start= disabled
call :CMD sc stop dmwappushservice
call :CMD sc config dmwappushservice start= disabled
echo.

echo Stopping and disabling NvTelemetryContainer.exe services..
call :CMD sc stop NvTelemetryContainer
call :CMD sc config NvTelemetryContainer start= disabled
echo.

echo Updating CompatTelRunner.exe files..
if not exist "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.bak" (
  copy /Y /B "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.etl" "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.bak"
)
echo.> "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.etl"
echo.

echo Updating CompatTelRunner.exe registry..
call :CMD reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
call :CMD reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v Debugger /t REG_SZ /d "systray.exe" /f
echo.

echo Updating CompatTelRunner.exe permissions...
for /F "usebackq eol=; tokens=* delims=" %%i in (`dir "%SystemRoot%\CompatTelRunner.exe" /A:-D /S /B`) do (
  set "FILE=%%i"
  call :UPDATE_PERMISSIONS
)
echo.

exit /b

:UPDATE_PERMISSIONS
echo.^>%FILE%
if exist "%~dp0retakeowner.exe" goto RETAKEOWNER_WORKAROUND

rem CAUTION: Obsolete implementation, `takeown` and `icacls` does not work anymore on TrustedInstaller protected files!
echo.%~nx0: warning: system takeown utility may fail to take ownership on TrustedInstaller protected files beginning from Windows 7. Copy `retakeowner.exe` utility into directory with the script to bypass this issue.
call :CMD takeown /S localhost /U "%%USERNAME%%" /F "%%FILE%%"

goto RETAKEOWNER_WORKAROUND_END

:RETAKEOWNER_WORKAROUND
call :CMD "%%~dp0retakeowner.exe" "%%FILE%%" "%%USERNAME%%"
echo.%~nx0: retakeowner last error code: %ERRORLEVEL%

:RETAKEOWNER_WORKAROUND_END

call :CMD icacls "%%FILE%%" /remove:g "NT SERVICE\TrustedInstaller"
call :CMD icacls "%%FILE%%" /deny *S-1-1-0:(WO,GE)

echo.

exit /b

:CMD
echo.^>%*
%*
