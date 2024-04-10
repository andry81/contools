@echo off

rem Encode these characters:
rem  ?*         - globbing characters in the `for ... %%i in (...)` expression or in a command line

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be encoded separately BEFORE this script call!
rem

if not defined __STRING__ exit /b 0

call "%%~dp0encode_asterisk_char.bat"

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!__STRING__:?=$3F!") do endlocal & set "__STRING__=%%i"
exit /b 0
