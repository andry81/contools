@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads standard output from command passed into arguments and counts
rem   not empty lines into variable STDOUT_LINES.

rem Examples:
rem 1. call countlines.bat dir c:\
rem    echo STDOUT_LINES=%STDOUT_LINES%

rem Drop STDOUT_LINES
set "STDOUT_LINES="

if "%~1" == "" exit /b 65

rem Drop last error level
call;

rem Create local variable's stack
setlocal

set "?3=("
set "?4=)"

rem Command `%*` inside for instruction doesn't raise the ERRORLEVEL
for /F "usebackq tokens=*" %%i in (`%%?3%%%*%%?4%%`) do (
  if not "%%i" == "" set /A STDOUT_LINES+=1
)

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set "STDOUT_LINES=%STDOUT_LINES%"
)

exit /b 0
