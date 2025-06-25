@echo off & setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~2!"') do endlocal & set "%~1=%%~i" & exit /b %ERRORLEVEL%

rem USAGE:
rem   set_var.bat <outvar> <var>

rem Description:
rem   Sets variable into another variable.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem
