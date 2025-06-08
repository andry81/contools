@echo off
rem call "%%~dp0call.bat" echo;%%*
:LOOP
if %~1 ( exit /b 0 ) else shift
if not "%~1" == "" goto LOOP
exit /b 255
