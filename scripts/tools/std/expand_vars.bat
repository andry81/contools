@echo off & ( for %%i in (%*) do setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%j in ('"!%%i!"') do endlocal & call set "%%i=%%~j" ) & exit /b %ERRORLEVEL%

rem USAGE:
rem   expand_vars.bat <var>...

rem Description:
rem   Expand variables script with a variable list in the command line.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.
