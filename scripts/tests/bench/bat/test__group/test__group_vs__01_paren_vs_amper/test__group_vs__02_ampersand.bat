@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & ^
set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0" & set /A "X+=0"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
