@echo off

rem USAGE:
rem   echo_var.bat <VAR> [<PREFIX> [<SUFFIX>]]

setlocal DISABLEDELAYEDEXPANSION

set "__?VAR__=%~1"
if not defined __?PREFIX__ set "__?PREFIX__=%~2"
if not defined __?SUFFIX__ set "__?SUFFIX__=%~3"

if not defined __?VAR__ exit /b 255
if not defined %__?VAR__% exit /b 1

rem safe echo
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__?PREFIX__!!%__?VAR__%!!__?SUFFIX__!") do ( endlocal & echo.%%i)
exit /b 0
