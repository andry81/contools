@echo off

rem Description:
rem   Script disables maintenance tasks in Windows 8...
rem

setlocal

call "%%~dp0..\__init__\__init__.bat"

if 0%IMPL_MODE% NEQ 0 goto IMPL
set "PSEXEC=%CONTOOLS_SYSINTERNALS_ROOT%/psexec.exe"
"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/cmd_admin_system.bat" /c @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
call "%%CONTOOLS_ROOT%%/std/is_system_elevated.bat" || (
  echo.%~nx0: error: process must be System account elevated to continue.
  exit /b 255
) >&2

call :CMD schtasks /Change /tn "\Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Maintenance\WinSAT" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\SkyDrive\Routine Maintenance Task" /Disable

rem saw a reenable by WUS, update the trigger time instead
call :CMD schtasks /Change /tn "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTask" /SD 01/01/3000

call :CMD schtasks /Change /tn "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskLogon" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\WS\WSTask" /Disable

echo.

pause

exit /b

:CMD
echo.^>%*
(
  %*
)
