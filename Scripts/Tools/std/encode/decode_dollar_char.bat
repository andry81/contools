@echo off & if not defined __STRING__ exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__:$24=$!") do endlocal & set "__STRING__=%%i"
exit /b 0

rem Decode `$` character.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Keep comments at the end of the script to speed up the parsing times!
rem
