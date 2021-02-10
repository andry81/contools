@echo off

if not defined %~1 (
  echo.%~2%~3
  exit /b 0
)

setlocal DISABLEDELAYEDEXPANSION

rem Load and replace a value quote characters by the \x01 character.
call set "RETURN_VALUE=%%%~1:"=%%"

rem recode quote and exclamation characters
set __?QUOT__=^"
set "__?EXCL__=!" & set "__?ESC__=^"
set "RETURN_VALUE=%RETURN_VALUE:!=!__?EXCL__!%"
set "RETURN_VALUE=%RETURN_VALUE:=!__?QUOT__!%"
set "RETURN_VALUE=%RETURN_VALUE:^=!__?ESC__!%"

rem safe echo
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do for /F "eol= tokens=* delims=" %%j in ("%%i") do endlocal & echo.%~2%%j%~3
exit /b 0
