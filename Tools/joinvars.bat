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
rem You should use special variables in the file to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful when -e flag defined)
rem   %?1% - expands to " (Should always be used instead)
rem   !?2! - expands to ! (Should always be used inside "setlocal ENABLEDELAYEDEXPANSION")

rem Examples:
rem 1. call joinvars.bat PATH "pathlist.txt"

if "%~1" == "" exit /b 65
if "%~2" == "" exit /b 64
if not exist "%~2" exit /b 63

rem Drop last error level
cd .

rem Create local variable's stack
setlocal

set "?0=^"
set ?1="
set !?2!=!

set "__SET_VAR=%~1"
set "__SPLIT_STR=%~3"

for /F "usebackq eol=# tokens=* delims=" %%i in ("%~2") do (
  set __VAR1=%%i
  call :JOIN_ROUTINE
)

goto EXIT

:JOIN_ROUTINE
call set __SET1=%%?0%%%%%__SET_VAR%:~0,1%%

if "%__SET1%^" == ""^" goto SET1_NOT_EMPTY
if "%__SET1%" == "~0,1" goto SET1_EMPTY
if "%__SET1%" == "" goto SET1_EMPTY

goto :SET1_NOT_EMPTY

:SET1_NOT_EMPTY
set __SET2=^%__VAR1:~0,1%

if "%__SET2%^" == ""^" goto SET1
if "%__SET2%" == "~0,1" exit /b 0
if "%__SET2%" == "" exit /b 0

:SET1
rem call echo.1%%__SET_VAR%%=%%%__SET_VAR%%%%%__SPLIT_STR%%%__VAR1%
call set %%__SET_VAR%%=%%%__SET_VAR%%%%%__SPLIT_STR%%%__VAR1%
goto :EOF

:SET1_EMPTY
set __SET2=%__VAR1:~0,1%

if "%__SET2%^" == ""^" goto SET2
if "%__SET2%" == "~0,1" exit /b 0
if "%__SET2%" == "" exit /b 0

:SET2
rem call echo.2%%__SET_VAR%%=%__VAR1%
call set %%__SET_VAR%%=%__VAR1%
goto :EOF

rem Exit with current error level.
goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
call set "__ARGS__=%%__SET_VAR%%=%%%__SET_VAR%%%"
(
  endlocal
  set "%__ARGS__%"
)
