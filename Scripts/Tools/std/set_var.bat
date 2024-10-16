@echo off

rem USAGE:
rem   set_var.bat <outvar> <var>

rem Description:
rem   Sets variable into another variable.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

(
  if defined %~2 (
    setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%~2!") do endlocal & set "%~1=%%i"
  ) else set "%~1="
  exit /b %ERRORLEVEL%
)
