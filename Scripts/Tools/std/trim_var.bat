@echo off

rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION

rem Load and replace a value quote characters by the \x01 character.
call set "RETURN_VALUE=%%%~1:"=%%"

rem Encode value to remove exclamation characters.
set "RETURN_VALUE=%RETURN_VALUE:?=?00%"
set "RETURN_VALUE=%RETURN_VALUE:!=?01%"

if not defined RETURN_VALUE exit /b 0

rem safe to enable
setlocal ENABLEDELAYEDEXPANSION

:TRIM_LEFT_LOOP
if not "!RETURN_VALUE:~0,1!" == " " if not "!RETURN_VALUE:~0,1!" == "	" goto TRIM_LEFT_LOOP_END
set "RETURN_VALUE=!RETURN_VALUE:~1!"
goto TRIM_LEFT_LOOP

:TRIM_LEFT_LOOP_END
if not defined RETURN_VALUE exit /b 0

:TRIM_RIGHT_LOOP
if not "!RETURN_VALUE:~-1!" == " " if not "!RETURN_VALUE:~-1!" == "	" goto END
set "RETURN_VALUE=!RETURN_VALUE:~0,-1!"
goto TRIM_RIGHT_LOOP

:END
if not defined RETURN_VALUE exit /b 0

rem restore value
(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE:?01=!%"
)

rem restore value
set "RETURN_VALUE=%RETURN_VALUE:?00=?%"

rem recode quote and exclamation characters
set "__ESC__=^"
set __QUOT__=^"
set "__EXCL__=!"
set "RETURN_VALUE=%RETURN_VALUE:!=!__EXCL__!%"
set "RETURN_VALUE=%RETURN_VALUE:^=!__ESC__!%"
set "RETURN_VALUE=%RETURN_VALUE:=!__QUOT__!%"

rem safe set
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=* delims=" %%i in ("!RETURN_VALUE!") do for /F "tokens=* delims=" %%j in ("%%i") do (
  endlocal
  endlocal
  if not "%~2" == "" (
    set "%~2=%%j"
  ) else (
    set "%~1=%%j"
  )
)

exit /b 0
