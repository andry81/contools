@echo off

rem Description:
rem   Script disables telemetry junk from Microsoft and others...
rem

setlocal

set "COMPATTELRUNNER_LOG_DIR=%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger"

echo Stopping and disabling CompatTelRunner.exe services..
sc stop DiagTrack
sc config DiagTrack start= disabled
sc stop dmwappushservice
sc config dmwappushservice start= disabled
echo.

echo Stopping and disabling NvTelemetryContainer.exe services..
sc stop NvTelemetryContainer
sc config NvTelemetryContainer start= disabled
echo.

echo Updating CompatTelRunner.exe files..
if not exist "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.bak" (
  copy /Y /B "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.etl" "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.bak"
)
echo.> "%COMPATTELRUNNER_LOG_DIR%\AutoLogger-Diagtrack-Listener.etl"
echo.

echo Updating CompatTelRunner.exe registry..
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v Debugger /t REG_SZ /d "systray.exe" /f
echo.

echo Updating CompatTelRunner.exe permissions...
for /F "usebackq eol=; tokens=* delims=" %%i in (`dir "%WINDIR%\CompatTelRunner.exe" /A:-D /S /B`) do (
  set "FILE=%%i"
  call :UPDATE_PERMISSIONS
)
echo.

goto :EOF

:UPDATE_PERMISSIONS
echo.^>%FILE%
if exist "%~dp0retakeowner.exe" goto RETAKEOWNER_WORKAROUND

rem CAUTION: Obsolete implementation, `takeown` and `icacls` does not work anymore on TrustedInstaller protected files!
echo.%~nx0: warning: system takeown utility may fail to take ownership on TrustedInstaller protected files beginning from Windows 7. Copy `retakeowner.exe` utility into directory with the script to bypass this issue.
takeown /S localhost /U "%USERNAME%" /F "%FILE%"

goto RETAKEOWNER_WORKAROUND_END

:RETAKEOWNER_WORKAROUND
"%~dp0retakeowner.exe" "%FILE%" "%USERNAME%"
echo.%~nx0: retakeowner last error code: %ERRORLEVEL%

:RETAKEOWNER_WORKAROUND_END

icacls "%FILE%" /remove:g "NT SERVICE\TrustedInstaller"
icacls "%FILE%" /deny *S-1-1-0:(WO,GE)
