@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,3) do call "%%CONTOOLS_ROOT%%/std/sleep.bat" -vbs 50

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 3

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
