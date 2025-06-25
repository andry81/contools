@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

:LOOP
"%SystemRoot%\System32\cscript.exe" //nologo "%CONTOOLS_ROOT%/std/sleep.vbs" 1
goto LOOP
