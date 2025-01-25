@echo off

rem Description:
rem   Script disables maintenance tasks in Windows 8...
rem
rem   Based on:
rem     https://serverfault.com/questions/866336/do-i-need-to-disable-tiworker-exe-and-respective-tasksheduler-task-in-windows-se

setlocal

rem scripts must run in administrator mode
call :IS_ADMIN_ELEVATED && goto MAIN

(
  echo.%~nx0: error: process must be elevated before continue.
  exit /b 255
) >&2

rem CAUTIOM:
rem   Windows 7 has an issue around the `find.exe` utility and code page 65001.
rem   We use `findstr.exe` instead of `find.exe` to workaround it.
rem
rem   Based on: https://superuser.com/questions/557387/pipe-not-working-in-cmd-exe-on-windows-7/1869422#1869422

:IS_ADMIN_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\findstr.exe" /L "S-1-16-12288" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul & exit /b
if exist "%SystemRoot%\System32\config\system" exit /b 0
exit /b 255

:MAIN
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Idle Maintenance" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Manual Maintenance" /Disable
call :CMD schtasks /Change /tn "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable

call :CMD "%%SystemRoot%%\System32\reg.exe" add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

echo.

exit /b

:CMD
echo.^>%*
(
  %*
)
