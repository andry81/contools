@echo off

rem Author: Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts a file path to absolute canonical path.

rem Command arguments:
rem %1 - File path.

rem Examples:
rem 1. call abspath.bat "../Test"
rem    echo RETURN_VALUE=%RETURN_VALUE%

rem Drop return value
set "RETURN_VALUE="

setlocal

set "FROM_PATH=%~1"
if defined FROM_PATH set "FROM_PATH=%FROM_PATH:/=\%"

if defined FROM_PATH ^
if not "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_OK

(
  echo.%~nx0: error: path is invalid: "%FROM_PATH%".
  exit /b -255
) >&2

:FROM_PATH_OK

(
  endlocal
  set "RETURN_VALUE=%~dpf1"
)

exit /b 0
