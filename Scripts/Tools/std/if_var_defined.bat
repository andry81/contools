@echo off

setlocal DISABLEDELAYEDEXPANSION

if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "VALUE=%%%~1:"=%%"
if not defined VALUE exit /b 1

exit /b 0
