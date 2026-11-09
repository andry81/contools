@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set L=-345678901234567891
set R=-345678901234567890

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do call "%%CONTOOLS_ROOT%%/math/icmp_nvar.bat" L GEQ R

call "%%CONTOOLS_ROOT%%/time/end_time.bat"

echo Time spent: %TIME_INTS:*0=%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
