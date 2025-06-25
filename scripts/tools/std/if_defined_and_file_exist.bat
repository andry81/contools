@echo off
(call) & if "%~1" == "" exit /b 255
if not defined %~1 <nul ( exit /b 255 )
setlocal DISABLEDELAYEDEXPANSION & call set "FILE_PATH=%%%~1:"=%%"
if not defined FILE_PATH exit /b 255
if not exist "%FILE_PATH%" exit /b 255
if exist "%FILE_PATH%\*" exit /b 255
exit /b 0
