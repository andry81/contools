@echo off

rem USAGE:
rem   trim_var.bat <Var> [<OutVar>]

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call:
rem   `setlocal DISABLEDELAYEDEXPANSION`, otherwise the `!` character will be
rem   expanded.
rem

rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION

rem encode characters

setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=* delims=" %%i in ("!%~1:$=$24!") do endlocal & set "RETURN_VALUE=%%i"

setlocal ENABLEDELAYEDEXPANSION & set "RETURN_VALUE=!RETURN_VALUE:"=$22!"
for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & set "RETURN_VALUE=%%i"

set "RETURN_VALUE=%RETURN_VALUE:!=$21%"

setlocal ENABLEDELAYEDEXPANSION & call "%%~dp0.trim_var/trim_var.trim_value_left.bat" & ^
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0
call "%%~dp0.trim_var/trim_var.trim_value_right.bat" & ^
if not defined RETURN_VALUE endlocal & ( if "%~2" == "" ( set "%~1=" ) else set "%~2=" ) & exit /b 0

for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & set "RETURN_VALUE=%%i"

rem decode characters

set "RETURN_VALUE=%RETURN_VALUE:$21=!%"

setlocal ENABLEDELAYEDEXPANSION & set "RETURN_VALUE=!RETURN_VALUE:$22="!"
for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & set "RETURN_VALUE=%%i"

setlocal ENABLEDELAYEDEXPANSION & set "RETURN_VALUE=!RETURN_VALUE:$24=$!" & ^
for /F "eol= tokens=* delims=" %%i in ("!RETURN_VALUE!") do endlocal & endlocal & if not "%~2" == "" ( set "%~2=%%i" ) else set "%~1=%%i"
exit /b 0
