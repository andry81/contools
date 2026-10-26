@echo off & goto DOC_END

rem USAGE:
rem   trim_var.bat <var> [<out-var>]

rem Description:
rem   Trims `<var>` variable value optionally into `<out-var>` variable.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
:DOC_END

rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=* delims=	 "eol^= %%i in ("!%~1!") do endlocal & set "RETURN_VALUE=%%i" & ^
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0
call "%%~dp0.trim_var/trim_var.trim_value_right.bat" & ^
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!RETURN_VALUE!") do endlocal & endlocal & if "%~2" == "" ( set "%~1=%%i" ) else set "%~2=%%i"
