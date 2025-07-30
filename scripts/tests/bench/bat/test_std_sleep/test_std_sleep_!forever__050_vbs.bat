@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

:LOOP
call "%%CONTOOLS_ROOT%%/std/sleep.bat" -vbs 50
goto LOOP
