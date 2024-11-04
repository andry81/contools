@echo off

rem USAGE:
rem   expand_vars.bat <var0> ... <varN>

rem Description:
rem   Expand variables from the command line.
rem   Does not change the error level.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

( for %%i in (%*) do if defined %%i setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!%%i!") do endlocal & call set "%%i=%%j" ) & exit /b %ERRORLEVEL%
