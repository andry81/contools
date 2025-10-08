@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,10000) do for /L %%a in (0,1,99) do rem

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 10

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
