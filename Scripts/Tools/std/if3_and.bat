@echo off
rem call "%%~dp0call.bat" echo;%%*
:LOOP
if "%~1" %~2 "%~3" ( shift & shift & shift ) else exit /b 255
if not "%~2" == "" goto LOOP
exit /b 0
