@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script creates or updates variable consisted from concatenated strings
rem   joined with passed string. Strings are stored in file, which reads by
rem   script.

rem Command arguments:
rem %1 - Variable name, which will store concatenated strings.
rem %2 - Path to string file.
rem %3 - String join with.

rem Examples:
rem 1. call joinvars.bat PATH "pathlist.txt"

if "%~1" == "" exit /b 65
if "%~2" == "" exit /b 64
if not exist "%~2" exit /b 63

rem Drop return value
set "%~1="

rem Drop last error level
call;

rem Create local variable's stack
setlocal DISABLEDELAYEDEXPANSION

set "?0=^"

set "__SET_VAR=%~1"
set "__SPLIT_STR=%~3"

for /F "usebackq eol=# tokens=* delims=" %%i in ("%~2") do (
  set __VAR1=%%i
  call :JOIN_ROUTINE
)

goto EXIT

:JOIN_ROUTINE
call set __SET1=%%?0%%%%%__SET_VAR%:~0,1%%

if not defined __SET1 goto SET1_EMPTY
if "%__SET1%^" == ""^" goto SET1_NOT_EMPTY
if "%__SET1%" == "~0,1" goto SET1_EMPTY

goto :SET1_NOT_EMPTY

:SET1_NOT_EMPTY
set __SET2=^%__VAR1:~0,1%

if not defined __SET2 exit /b 0
if "%__SET2%^" == ""^" goto SET1
if "%__SET2%" == "~0,1" exit /b 0

:SET1
rem call echo.1%%__SET_VAR%%=%%%__SET_VAR%%%%%__SPLIT_STR%%%__VAR1%
call set %%__SET_VAR%%=%%%__SET_VAR%%%%%__SPLIT_STR%%%__VAR1%
exit /b

:SET1_EMPTY
set __SET2=%__VAR1:~0,1%

if not defined __SET2 exit /b 0
if "%__SET2%^" == ""^" goto SET2
if "%__SET2%" == "~0,1" exit /b 0

:SET2
rem call echo.2%%__SET_VAR%%=%__VAR1%
call set %%__SET_VAR%%=%__VAR1%
exit /b

rem Exit with current error level.
exit /b

:EXIT
rem Drop internal variables but use some changed value(s) for the return
setlocal ENABLEDELAYEDEXPANSION
for /F tokens^=^*^ delims^=^ eol^= %%i in ("!%__SET_VAR%!") do (
  endlocal
  endlocal
  set "%__SET_VAR%=%%i"
)
