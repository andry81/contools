@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The del wrapper script with echo and some conditions check before call.

setlocal

set "FROM_PATH=%~1"
if not "%FROM_PATH%" == "" set "FROM_PATH=%FROM_PATH:/=\%"

if not "%FROM_PATH%" == "" ^
if not "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_OK

(
  echo.%~nx0: error: path is invalid: "%FROM_PATH%".
  exit /b -255
) >&2

:FROM_PATH_OK

set "FROM_PATH=%~dpf1"

echo.^>del %2 %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%"
del %2 %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%"
