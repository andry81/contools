@echo off

rem USAGE:
rem   trim_var.bat <Var> [<OutVar>]

rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%~1!") do endlocal & set "RETURN_VALUE=%%i"

call "%%~dp0.trim_var/trim_var.trim_value_left.bat" || exit /b
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0
call "%%~dp0.trim_var/trim_var.trim_value_right.bat" || exit /b
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & endlocal & if not "%~2" == "" ( set "%~2=%%i" ) else set "%~1=%%i"
exit /b 0
