@echo off

setlocal DISABLEDELAYEDEXPANSION

if "%~1" == "" exit /b 255
if not defined %~1 exit /b 255
call set "VALUE=%%%~1:"=%%"
if not defined VALUE exit /b 255

exit /b 0
