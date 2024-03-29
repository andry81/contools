@echo off

rem USAGE:
rem   trim_var.bat <Var> [<OutVar>]

rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION

rem Load and replace a value quote characters by the \x01 character.
call set "RETURN_VALUE=%%%~1:"=%%"

call "%%~dp0.trim_var/trim_var.trim_value_left.bat" || exit /b
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0
call "%%~dp0.trim_var/trim_var.trim_value_right.bat" || exit /b
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0

rem recode quote and exclamation characters
set "__ESC__=^"
set __QUOT__=^"
set "__EXCL__=!"
set "RETURN_VALUE=%RETURN_VALUE:!=!__EXCL__!%"
set "RETURN_VALUE=%RETURN_VALUE:^=!__ESC__!%"
set "RETURN_VALUE=%RETURN_VALUE:=!__QUOT__!%"

rem safe set
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do for /F "eol= tokens=* delims=" %%j in ("%%i") do endlocal & endlocal & if not "%~2" == "" ( set "%~2=%%j" ) else set "%~1=%%j"
exit /b 0
