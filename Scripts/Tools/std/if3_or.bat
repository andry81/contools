@echo off
rem call "%%~dp0call.bat" echo;%%*
:LOOP
if "%~1" %~2 "%~3" ( exit /b 0 ) else shift & shift & shift
if not "%~2" == "" goto LOOP
exit /b 255
