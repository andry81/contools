@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set __STRING__=a

setlocal ENABLEDELAYEDEXPANSION

for /L %%i in (1,1,11) do set __STRING__=!__STRING__!!__STRING__!

for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & set "__STRING__=%%i"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

if %TIME_INTS% EQU 0 set "TIME_INTS="

echo Time spent: %TIME_INTS%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
