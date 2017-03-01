@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The del wrapper script with echo and some conditions check before call.

setlocal

set "FROMTO_PATH=%~dpf1"

if not exist "%~1" (
  echo.%~nx0: error: path does not exist: "%~1"
  exit /b 127
) >&2

echo.^>del %2 %3 %4 %5 %6 %7 %8 %9 "%FROMTO_PATH%"
del %2 %3 %4 %5 %6 %7 %8 %9 "%FROMTO_PATH%"
