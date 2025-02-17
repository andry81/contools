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

call :CMD schtasks /Change /tn "\Microsoft\Windows\Application Experience\AitAgent" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable

call :CMD schtasks /Change /tn "\Microsoft\Windows\WindowsUpdate\AUFirmwareInstall" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WindowsUpdate\AUScheduledInstall" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WindowsUpdate\AUSessionConnect" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start With Network" /Disable

echo.

pause

exit /b

:CMD
echo.^>%*
(
  %*
)
