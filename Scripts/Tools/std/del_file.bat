@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `del` wrapper script with echo and some conditions check before
rem   call.

echo.^>%~nx0 %*

setlocal

set "FROM_PATH=%~1"

if not defined FROM_PATH (
  echo.%~nx0: error: file path argument must be defined.
  exit /b -255
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_ERROR

rem ...double `\\` character
if not "%FROM_PATH%" == "%FROM_PATH:\\=\%" goto FROM_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FROM_PATH:~-1%" goto FROM_PATH_ERROR

rem check on invalid characters in path
if not "%FROM_PATH%" == "%FROM_PATH:**=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:?=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo.%~nx0: error: file path is invalid: "%FROM_PATH%".
  exit /b -254
) >&2

:FROM_PATH_OK

if not exist "%FROM_PATH%" (
  echo.%~nx0: error: input file path does not exist: "%FROM_PATH%"
  exit /b -253
) >&2 else if exist "%FROM_PATH%\*" (
  echo.%~nx0: error: input path is a directory path: "%FROM_PATH%"
  exit /b -252
) >&2

set "FROM_PATH=%~f1"

del %2 %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%"
