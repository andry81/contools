@echo off

rem Encode these characters:
rem  |&()<>     - control flow characters
rem  "'`^%!+    - escape or sequence expand characters (`+` is a unicode codepoint sequence character in 65000 code page)
rem  ?*         - globbing characters in the `for ... %%i in (...)` expression or in a command line
rem  ,;=        - separator characters in the `for ... %%i in (...)` expression or in a command line

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be encoded separately BEFORE this script call!
rem

if not defined __STRING__ exit /b 0

setlocal DISABLEDELAYEDEXPANSION & ^
setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!__STRING__:"=$22!"
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "__STRING__=%%i"

set "__STRING__=%__STRING__:!=$21%"

call "%%~dp0encode_asterisk_char.bat" & call "%%~dp0encode_equal_char.bat"

setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:|=$7C!" & set "__STRING__=!__STRING__:&=$26!"  & set "__STRING__=!__STRING__:(=$28!" & set "__STRING__=!__STRING__:)=$29!" & ^
set "__STRING__=!__STRING__:<=$3C!" & set "__STRING__=!__STRING__:>=$3E!"  & set "__STRING__=!__STRING__:'=$27!" & set "__STRING__=!__STRING__:`=$60!" & ^
set "__STRING__=!__STRING__:^=$5E!" & set "__STRING__=!__STRING__:%%=$25!" & set "__STRING__=!__STRING__:+=$2B!" & ^
set "__STRING__=!__STRING__:?=$3F!" & set "__STRING__=!__STRING__:,=$2C!"  & set "__STRING__=!__STRING__:;=$3B!" & ^
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & endlocal & set "__STRING__=%%i"
exit /b 0
