@echo off

rem Script runs Device Manager in administrator mode with enabled show of
rem nonpresent devices.
rem The `hidden devices` must be enabled from the Device Manager menu to show
rem inactive Network Adapters to uninstall them.

setlocal

rem scripts must run in administrator mode
call :IS_ADMIN_ELEVATED || (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

goto MAIN

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
set DEVMGR_SHOW_NONPRESENT_DEVICES=1

devmgmt.msc
