@echo off & setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~2!"') do endlocal & set "%~1=%%~i" & exit /b %ERRORLEVEL%

rem USAGE:
rem   set_var.bat <out-var> <var>

rem Description:
rem   Sets `<var>` variable into `<out-var>` variable.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
