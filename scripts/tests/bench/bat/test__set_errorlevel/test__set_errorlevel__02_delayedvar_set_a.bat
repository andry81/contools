@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

echo;^>%~nx0

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

setlocal ENABLEDELAYEDEXPANSION

for /L %%i in (1,1,1000) do call :SETERRLVL %%i & set /A "X=!ERRORLEVEL!" & rem set X

endlocal

goto TESTEND

:SETERRLVL
exit /b %~1

:TESTEND

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
