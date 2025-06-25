@echo off & if not defined __STRING__ exit /b 0

setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:|=$7C!" & set "__STRING__=!__STRING__:&=$26!" & set "__STRING__=!__STRING__:(=$28!" & set "__STRING__=!__STRING__:)=$29!" & ^
set "__STRING__=!__STRING__:<=$3C!" & set "__STRING__=!__STRING__:>=$3E!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & set "__STRING__=%%i"
exit /b 0

rem Encode these characters:
rem  |&()<>     - control flow characters

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be encoded separately BEFORE this script call!
rem

rem CAUTION:
rem   Keep comments at the end of the script to speed up the parsing times!
rem
