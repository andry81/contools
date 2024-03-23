@echo off

setlocal DISABLEDELAYEDEXPANSION

if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "FILE_PATH=%%%~1:"=%%"
if not defined FILE_PATH exit /b 1
if not exist "%FILE_PATH%" exit /b 1
if exist "%FILE_PATH%\*" exit /b 1

exit /b 0
