@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

echo Uninstalling KB3075249 (telemetry for Win7/8.1)
wusa.exe /uninstall /kb:3075249 /quiet /norestart
echo Uninstalling KB3080149 (telemetry for Win7/8.1)
wusa.exe /uninstall /kb:3080149 /quiet /norestart
echo Uninstalling KB3021917 (telemetry for Win7)
wusa.exe /uninstall /kb:3021917 /quiet /norestart
echo Uninstalling KB3022345 (telemetry)
wusa.exe /uninstall /kb:3022345 /quiet /norestart
echo Uninstalling KB3068708 (telemetry)
wusa.exe /uninstall /kb:3068708 /quiet /norestart
echo Uninstalling KB3044374 (Get Windows 10 for Win8.1)
wusa.exe /uninstall /kb:3044374 /quiet /norestart
echo Uninstalling KB3035583 (Get Windows 10 for Win7sp1/8.1)
wusa.exe /uninstall /kb:3035583 /quiet /norestart
echo Uninstalling KB2990214 (Get Windows 10 for Win7 without sp1)
wusa.exe /uninstall /kb:2990214 /quiet /norestart
echo Uninstalling KB2952664 (Get Windows 10 assistant)
wusa.exe /uninstall /kb:2952664 /quiet /norestart
echo Uninstalling KB3075853 (update for “Windows Update” on Win8.1/Server 2012R2)
wusa.exe /uninstall /kb:3075853 /quiet /norestart
echo Uninstalling KB3065987 (update for “Windows Update” on Win7/Server 2008R2)
wusa.exe /uninstall /kb:3065987 /quiet /norestart
echo Uninstalling KB3050265 (update for “Windows Update” on Win7)
wusa.exe /uninstall /kb:3050265 /quiet /norestart
echo Uninstalling KB971033 (license validation)
wusa.exe /uninstall /kb:971033 /quiet /norestart
echo Uninstalling KB2902907 (description not available)
wusa.exe /uninstall /kb:2902907 /quiet /norestart

echo Uninstalling KB2976987 (description not available)
wusa.exe /uninstall /kb:2976987 /quiet /norestart

echo Uninstalling KB3114409 (description not available)
wusa.exe /uninstall /kb:3114409 /quiet /norestart

echo Uninstalling KB2976987 (Get Windows 10 for Win7sp1/8.1)
wusa.exe /uninstall /kb:3150513 /quiet /norestart
