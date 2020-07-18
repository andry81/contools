@echo off

if not defined %~1 (
  echo.%~2%~3
  exit /b 0
)

setlocal DISABLEDELAYEDEXPANSION

rem Load and replace a value quote characters by the \x01 character.
call set "RETURN_VALUE=%%%~1:"=%%"

rem recode quote and exclamation characters
set "__ESC__=^"
set __QUOT__=^"
set "__EXCL__=!"
set "RETURN_VALUE=%RETURN_VALUE:!=!__EXCL__!%"
set "RETURN_VALUE=%RETURN_VALUE:^=!__ESC__!%"
set "RETURN_VALUE=%RETURN_VALUE:=!__QUOT__!%"

rem safe echo
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=* delims=" %%i in ("!RETURN_VALUE!") do for /F "tokens=* delims=" %%j in ("%%i") do (
  endlocal
  endlocal
  echo.%~2%%j%~3
)

exit /b 0
