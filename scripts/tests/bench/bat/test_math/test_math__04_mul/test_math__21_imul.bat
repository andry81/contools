@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set L=-998,998,998,998,998,999

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do call "%%CONTOOLS_ROOT%%/math/umul.bat" OUT L 2149633

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

if %TIME_INTS% EQU 0 set "TIME_INTS="

echo Time spent: %TIME_INTS%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
