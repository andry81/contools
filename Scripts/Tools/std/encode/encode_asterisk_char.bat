@echo off & if not defined __STRING__ exit /b 0

setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & if "!__STRING__!" == "!__STRING__:**=!" ( exit /b 0 ) else endlocal

:LOOP
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1 delims=*"eol^= %%i in (".!__STRING__!") do for /F "tokens=* delims="eol^= %%j in ("!__STRING__:**=!.") do endlocal & set "__STRING__=%%i$2A%%j" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~1,-1!") do ^
if not "!__STRING__!" == "!__STRING__:**=!" ( endlocal & set "__STRING__=%%i" & goto LOOP ) else endlocal & endlocal & set "__STRING__=%%i"
exit /b 0

rem Encode `*` character.

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
