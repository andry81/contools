@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

set "CMD_QUIET="
set /P "IS_QUIET=Quiet uninstall? [y/N] "
if "%IS_QUIET%" == "y" set "CMD_QUIET=/quiet"

wusa.exe /uninstall /kb:3068708 %CMD_QUIET% /norestart
wusa.exe /uninstall /kb:3022345 %CMD_QUIET% /norestart
wusa.exe /uninstall /kb:3075249 %CMD_QUIET% /norestart
wusa.exe /uninstall /kb:3080149 %CMD_QUIET% /norestart
