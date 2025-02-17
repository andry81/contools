@echo off

rem Description:
rem   Script disables telemetry junk from Microsoft and others...
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

call :CMD schtasks /Change /tn "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\AppID\SmartScreenSpecific" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Autochk\Proxy" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Location\Notifications" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\SettingSync\BackgroundUploadTask" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\SettingSync\BackupTask" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Setup\EOSNotify2" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Shell\FamilySafetyRefresh" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Shell\FamilySafetyUpload" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\SkyDrive\Idle Sync Maintenance Task" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Time Synchronization\SynchronizeTime" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Time Zone\SynchronizeTimeZone" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\User Profile Service\HiveUploadTask" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\WS\Badge Update" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WS\License Validation" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WS\Sync Licenses" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WS\WSRefreshBannedAppsListTask" /Disable

echo.

pause

exit /b

:CMD
echo.^>%*
(
  %*
)
