@echo off

setlocal DISABLEDELAYEDEXPANSION

if "%~1" == "" exit /b 255
if not defined %~1 exit /b 255
call set "DIR_PATH=%%%~1:"=%%"
if not defined DIR_PATH exit /b 255
if not exist "%DIR_PATH%\*" exit /b 255

exit /b 0
