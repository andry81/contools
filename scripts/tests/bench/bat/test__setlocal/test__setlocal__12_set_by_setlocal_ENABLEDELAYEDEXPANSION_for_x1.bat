@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

set VAR=1234567890

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do ^
setlocal ENABLEDELAYEDEXPANSION & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
set "VAR=!VAR!" & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!VAR!"') do endlocal & set "VAR=%%~i"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
