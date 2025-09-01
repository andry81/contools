@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

set L=-345678901234567890
set R=-345678901234567891

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do call "%%CONTOOLS_ROOT%%/math/icmp_nvar.bat" L EQU R

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

if %TIME_INTS% EQU 0 set "TIME_INTS="

echo Time spent: %TIME_INTS%%TIME_FRACS:~0,1%.%TIME_FRACS:~1%0 msecs
echo;

exit /b 0
