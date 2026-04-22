@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set "?~nx0=%~nx0"

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" ?~nx0 ">"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do call :TEST
goto END

:TEST
for /L %%# in (1,1,256) do for /L %%# in (1,1,256) do for /L %%# in (1,1,256) do for /L %%# in (1,1,256) do exit /b 0

:END

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
