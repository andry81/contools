@echo off

rem with save of previous error level
setlocal DISABLEDELAYEDEXPANSION & set LAST_ERROR=%ERRORLEVEL%

set "__?VAR__=%~1"

if not defined __?VAR__ exit /b 255
if not defined %__?VAR__% exit /b 1

if not defined __?PREFIX__ set "__?PREFIX__=%~2"
if not defined __?SUFFIX__ set "__?SUFFIX__=%~3"

rem safe echo
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__?PREFIX__!!%__?VAR__%!!__?SUFFIX__!") do endlocal & echo;%%i

endlocal & exit /b %LAST_ERROR%

rem USAGE:
rem   echo_var.bat <var> [<prefix> [<suffix>]]

rem Description:
rem   Script prints a variable value with prefix and suffix text.
rem   Does not change the error level.
