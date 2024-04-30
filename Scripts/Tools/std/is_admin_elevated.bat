@echo off

rem Description:
rem   Script checks Administrator privileges.

rem Based on:
rem   https://superuser.com/questions/809901/check-for-elevation-at-command-prompt
rem   https://www.robvanderwoude.com/battech_elevation.php

setlocal

if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\find.exe" "S-1-16-12288" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\system32\config\system" exit /b 0
exit /b 255
