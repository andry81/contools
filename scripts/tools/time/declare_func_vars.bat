@echo off

if "!!" == "" (
  echo;%~nx0: error: delayed expansion must be disable before the call
  exit /b 255
) >&2

set @ENDLOCAL_AND_RECALC_TIME@=setlocal ENABLEDELAYEDEXPANSION ^& for /F "usebackq tokens=* delims="eol^^= %%i in ('"!TIME_DIFF!"') do endlocal ^& endlocal ^& call "%%CONTOOLS_ROOT%%/time/recalc_time.bat" 1 "%%~i"

exit /b 0

rem Description:
rem   Built-in variables to use as macro generics.

rem @ENDLOCAL_AND_RECALC_TIME@:
rem   To use instead of `endlocal` after `end_time.bat` call to return
rem   `TIME_DIFF` variable.
