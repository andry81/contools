@echo off & if not defined __STRING__ exit /b 0

call "%%~dp0encode_asterisk_char.bat"

setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!__STRING__:<=$3C!" & set "__STRING__=!__STRING__:>=$3E!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__:?=$3F!") do endlocal & set "__STRING__=%%i"
exit /b 0

rem Encode these characters:
rem  ?*<>       - globbing characters in the `for ... %%i in (...)` expression or in a command line (`?<` has different globbing versus `*`, `*.` versus `*.>`)

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.

rem CAUTION:
rem   Character `$` must be encoded separately BEFORE this script call!

rem CAUTION:
rem   Keep comments at the end of the script to speed up the parsing times!
