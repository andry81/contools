@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set "?~nx0=%~nx0"

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" ?~nx0 ">"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/declare_func_vars.bat" || exit /b

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

for /L %%i in (1,1,1000) do call :FOR

goto END

:FOR
%@DO_LOOP_16x8@% exit /b
exit /b

:END

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

echo Time spent: %TIME_INTS%.%TIME_FRACS% msecs
echo;

exit /b 0
