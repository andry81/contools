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
takeown /S localhost /U "%USERNAME%" /F "%FILE%"
icacls "%FILE%" /remove:g "NT SERVICE\TrustedInstaller"
icacls "%FILE%" /deny *S-1-1-0:(WO,GE)