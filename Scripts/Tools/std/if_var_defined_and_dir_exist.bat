@echo off

setlocal DISABLEDELAYEDEXPANSION

if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1:"=%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%\*" exit /b 1

exit /b 0
