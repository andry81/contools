@echo off

setlocal

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100000) do rem

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 100

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
