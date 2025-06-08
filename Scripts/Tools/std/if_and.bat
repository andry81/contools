@echo off
rem call "%%~dp0call.bat" echo;%%*
:LOOP
if %~1 ( shift ) else exit /b 255
if not "%~1" == "" goto LOOP
exit /b 0
