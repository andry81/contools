@echo off & if not defined __STRING__ exit /b 0

setlocal DISABLEDELAYEDEXPANSION & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do for /F "tokens=1 delims=="eol^= %%j in (".!__STRING__!") do endlocal & set "__HEAD__=%%j" & set "__TAIL__=.%%i" & ^
setlocal ENABLEDELAYEDEXPANSION & if "!__HEAD__!" == "!__TAIL__!" ( exit /b 0 ) else endlocal

set "__STRING__=" & setlocal ENABLEDELAYEDEXPANSION
:LOOP
if "!__HEAD__!" == "!__TAIL__!" for /F "tokens=* delims="eol^= %%i in ("!__STRING__!!__TAIL__:~1!") do endlocal & endlocal & set "__STRING__=%%i" & exit /b 0
set "__OFFSET__=2" & set "__TMP__=!__HEAD__!" & for %%i in (65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!__TMP__:~%%i,1!" == "" set /A "__OFFSET__+=%%i" & set "__TMP__=!__TMP__:~%%i!"
if defined __TAIL__ set "__TAIL__=!__TAIL__:~%__OFFSET__%!"
set "__STRING__=!__STRING__!!__HEAD__:~1!$3D" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do for /F "tokens=1 delims=="eol^= %%j in (".!__TAIL__!") do for /F "tokens=* delims="eol^= %%k in (".!__TAIL__!") do ^
endlocal & set "__STRING__=%%i" & set "__HEAD__=%%j" & set "__TAIL__=%%k" & setlocal ENABLEDELAYEDEXPANSION
goto LOOP

rem Encode `=` character.

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
