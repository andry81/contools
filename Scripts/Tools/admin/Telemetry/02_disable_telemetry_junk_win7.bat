@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

wusa.exe /uninstall /kb:3068708 /quiet /norestart
wusa.exe /uninstall /kb:3022345 /quiet /norestart
wusa.exe /uninstall /kb:3075249 /quiet /norestart
wusa.exe /uninstall /kb:3080149 /quiet /norestart
