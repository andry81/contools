@echo off

rem Decode these characters:
rem  <space>,;= - separator characters in the `for ... %%i in (...)` expression or in a command line

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be decoded separately AFTER this script call!
rem

if not defined __STRING__ exit /b 0

call "%%~dp0decode_equal_char.bat"

setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:$20= !" & set "__STRING__=!__STRING__:$2C=,!" & set "__STRING__=!__STRING__:$38=;!" & ^
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "__STRING__=%%i"
exit /b 0
