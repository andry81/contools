@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `mkdir` wrapper script with echo and some conditions check before
rem   call.

echo.^>%~nx0 %*

setlocal

:MKDIR_LOOP

set "DIR_PATH=%~1"
set DIR_COUNT=1

if not defined DIR_PATH (
  echo.%~nx0: error: at least one directory path argument must be defined.
  exit /b -255
) >&2

set "DIR_PATH=%DIR_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%DIR_PATH:~0,1%" goto DIR_PATH_ERROR

rem ...double `\\` character
if not "%DIR_PATH%" == "%DIR_PATH:\\=\%" goto DIR_PATH_ERROR

rem ...trailing `\` character
if "\" == "%DIR_PATH:~-1%" goto DIR_PATH_ERROR

rem check on invalid characters in path
if not "%DIR_PATH%" == "%DIR_PATH:**=%" goto DIR_PATH_ERROR
if not "%DIR_PATH%" == "%DIR_PATH:?=%" goto DIR_PATH_ERROR

goto DIR_PATH_OK

:DIR_PATH_ERROR
(
  echo.%~nx0: error: the directory path is invalid: ARG=%DIR_COUNT% DIR_PATH="%DIR_PATH%".
  exit /b -254
) >&2

:DIR_PATH_OK

shift

if "%~1" == "" goto MKDIR_LOOP_END

set /A DIR_COUNT+=1

goto MKDIR_LOOP

:MKDIR_LOOP_END
mkdir %*
