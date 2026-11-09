@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b

set "?~nx0=%~nx0"

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" ?~nx0 ">"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/std/declare_func_vars.bat" || exit /b
call "%%CONTOOLS_ROOT%%/time/declare_func_vars.bat" || exit /b

setlocal ENABLEDELAYEDEXPANSION

call "%%CONTOOLS_ROOT%%/time/begin_time.bat"

set INDEX=0
for /L %%# in (1,1,16) do for /L %%# in (1,1,16) do for %%# in (:) do for %%# in (:) do (
  set /A INDEX+=1
  if !INDEX! GEQ 100 goto :EXIT
)

:EXIT

call "%%CONTOOLS_ROOT%%/time/end_time.bat"

%@ENDLOCAL_AND_RECALC_TIME@%

echo Time spent: %TIME_INTS%.%TIME_FRACS% secs
echo;

exit /b 0
