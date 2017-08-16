@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `copy` wrapper script with echo and some conditions check before
rem   call.

setlocal

set "FROM_PATH=%~1"
set "TO_PATH=%~2"

if not defined FROM_PATH (
  echo.%~nx0: error: input path argument must be defined.
  exit /b -255
) >&2

if not defined TO_PATH (
  echo.%~nx0: error: output path argument must be defined.
  exit /b -254
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"
set "TO_PATH=%TO_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FROM_PATH:~0,1%" goto FROM_PATH_ERROR

rem ...double `\\` character
if not "%FROM_PATH%" == "%FROM_PATH:\\=\%" goto FROM_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FROM_PATH:~-1%" goto FROM_PATH_ERROR

rem check on invalid characters in path
if not "%FROM_PATH%" == "%FROM_PATH:**\=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:?=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo.%~nx0: error: input path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -253
) >&2

:FROM_PATH_OK

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

rem ...double `\\` character
if not "%TO_PATH%" == "%TO_PATH:\\=\%" goto TO_PATH_ERROR

rem ...trailing `\` character
if "\" == "%TO_PATH:~-1%" goto TO_PATH_ERROR

rem check on invalid characters in path
if not "%TO_PATH%" == "%TO_PATH:**=%" goto TO_PATH_ERROR
if not "%TO_PATH%" == "%TO_PATH:?=%" goto TO_PATH_ERROR

if "\" == "%TO_PATH:~0,1%" goto TO_PATH_ERROR

goto TO_PATH_OK

:TO_PATH_ERROR
(
  echo.%~nx0: error: output path is invalid: FROM_PATH="%FROM_PATH%" TO_PATH="%TO_PATH%".
  exit /b -252
) >&2

:TO_PATH_OK

if not exist "%FROM_PATH%" (
  echo.%~nx0: error: input path does not exist: "%FROM_PATH%"
  exit /b -251
) >&2

if not exist "%TO_PATH%\" (
  echo.%~nx0: error: output directory does not exist: "%TO_PATH%\"
  exit /b -250
) >&2

set "FROM_PATH=%~dpf1"
set "TO_PATH=%~dpf2"

echo.^>copy %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%" "%TO_PATH%"
copy %3 %4 %5 %6 %7 %8 %9 "%FROM_PATH%" "%TO_PATH%"
