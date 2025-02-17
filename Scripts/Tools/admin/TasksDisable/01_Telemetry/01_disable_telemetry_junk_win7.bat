@echo off

rem Description:
rem   Script disables telemetry junk from Microsoft and others...
rem

setlocal

call "%%~dp0..\__init__\__init__.bat"

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/cmd_admin.bat" /c @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo.%~nx0: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /c %%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b 255
) >&2

:X64
:X32

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

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%SystemRoot%\CompatTelRunner.exe" /A:-D /B /O:N /S 2^>nul

echo Updating CompatTelRunner.exe permissions...
for /F "usebackq eol=; tokens=* delims=" %%i in (`%%?.%%`) do (
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
(
  %*
)
