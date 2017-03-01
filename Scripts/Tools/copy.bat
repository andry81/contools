@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The copy wrapper script with echo and some conditions check before call.

setlocal

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"

if not exist "%~1" (
  echo.%~nx0: error: input path does not exist: "%~1"
  exit /b 127
) >&2

echo.^>copy %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%" "%TO_PATH%"
copy %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%" "%TO_PATH%"
