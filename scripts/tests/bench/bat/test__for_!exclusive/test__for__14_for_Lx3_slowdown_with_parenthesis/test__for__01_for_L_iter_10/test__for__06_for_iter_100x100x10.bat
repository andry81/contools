@echo off

setlocal

rem call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,100) do ( for /L %%j in (1,1,100) do ( for /L %%k in (1,1,10) do ( rem
) ) )

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
