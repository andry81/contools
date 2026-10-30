@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set "?~nx0=%~nx0"

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" ?~nx0 ">"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/declare_func_vars.bat" || exit /b
call "%%CONTOOLS_ROOT%%/time/declare_func_vars.bat" || exit /b

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

setlocal ENABLEDELAYEDEXPANSION

set INDEX=0
%@DO_LOOP_16x8@% (
  set /A INDEX+=1
  if !INDEX! GEQ 10000 goto :EXIT
)

:EXIT

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1

%@ENDLOCAL_AND_RECALC_TIME@%

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
