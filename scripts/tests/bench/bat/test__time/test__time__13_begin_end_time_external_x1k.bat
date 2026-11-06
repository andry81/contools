@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set TIME_DIFF_ACCUM=0

for /L %%i in (1,1,1000) do call "%%CONTOOLS_ROOT%%/time/begin_time.bat" & call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1 0 "%%TIME%%" & set /A TIME_DIFF_ACCUM+=TIME_DIFF

set /A TIME_DIFF=TIME_DIFF_ACCUM

call "%%CONTOOLS_ROOT%%/time/recalc_time.bat"

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
