@echo off

rem Decode `=` character.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be decoded separately AFTER this script call!
rem

if not defined __STRING__ exit /b 0
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__:$2A=*!") do endlocal & set "__STRING__=%%i"
exit /b 0
