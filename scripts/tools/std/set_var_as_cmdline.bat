@echo off & goto DOC_END

rem USAGE:
rem   set_var_as_cmdline.bat <out-var> <var>

rem Description:
rem   Script sets `... & set "VAR=VALUE"` string into `<out-var>` variable to
rem   be able to execute it later to set variables after a nested `setlocal`
rem   context.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
:DOC_END

if "%~1" == "" exit /b 255
if "%~2" == "" exit /b 1

setlocal DISABLEDELAYEDEXPANSION

rem remove double quotes
if defined %~2 call set "%%~2=%%%~2:"=%%"

if defined %~1 if /i not "%~1" == "%~2" ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!%~1!") do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!%~2!"') do ^
endlocal & endlocal & set %~1=%%i^& set "%~2=%%~j"& exit /b 0

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~2!"') do ^
endlocal & endlocal & set %~1=set "%~2=%%~i"& exit /b 0
