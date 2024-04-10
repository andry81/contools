@echo off

rem Decode these characters:
rem  "'`^%!+    - escape or sequence expand characters (`+` is a unicode codepoint sequence character in 65000 code page)

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem CAUTION:
rem   Character `$` must be decoded separately AFTER this script call!
rem

if not defined __STRING__ exit /b 0

setlocal DISABLEDELAYEDEXPANSION & set "__STRING__=%__STRING__:$21=!%"

setlocal ENABLEDELAYEDEXPANSION & set "__STRING__=!__STRING__:$22="!"
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & set "__STRING__=%%i"

setlocal ENABLEDELAYEDEXPANSION & ^
set "__STRING__=!__STRING__:$27='!" & set "__STRING__=!__STRING__:$60=`!" & set "__STRING__=!__STRING__:$5E=^!" & set "__STRING__=!__STRING__:$25=%%!" & set "__STRING__=!__STRING__:$2B=+!" & ^
for /F "eol= tokens=* delims=" %%i in ("!__STRING__!") do endlocal & endlocal & set "__STRING__=%%i"
exit /b 0
