@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do call :SET

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0

:SET
set /A "TEST=0"
set /A "TEST=1"
set /A "TEST=2"
set /A "TEST=3"
set /A "TEST=4"
set /A "TEST=5"
set /A "TEST=6"
set /A "TEST=7"
set /A "TEST=8"
set /A "TEST=9"
