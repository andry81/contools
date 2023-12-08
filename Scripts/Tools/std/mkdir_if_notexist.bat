@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   The `mkdir` if not exist wrapper script with echo and some conditions
rem   check before call.

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>%~nx0 %*

setlocal

set "DIR_PATHS="

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

for /F "eol= tokens=* delims=" %%i in ("%DIR_PATH%\.") do ( set "DIR_PATH=%%~fi" && set "DIR_DRIVE=%%~di" )

rem CAUTION:
rem   The directory can or can not exist on the disconnected drive.
rem
if not exist "%DIR_DRIVE%" (
  echo.%~nx0: error: the directory path drive is not exist: ARG=%DIR_COUNT% DIR_PATH="%DIR_PATH%".
  exit /b -254
) >&2

rem CAUTION:
rem   The `mklink` command can create symbolic directory link and in the disconnected state it does
rem   report existences of a directory without the trailing back slash:
rem     `x:\<path-to-dir-without-trailing-back-slash>`
rem   So we must test the path with the trailing back slash to check existence of the link AND it's connection state.
rem
if not exist "\\?\%DIR_PATH%" if not exist "\\?\%DIR_PATH%\*" set DIR_PATHS=%DIR_PATHS% "%DIR_PATH%"

shift

if "%~1" == "" goto MKDIR_LOOP_END

set /A DIR_COUNT+=1

goto MKDIR_LOOP

:MKDIR_LOOP_END
if not defined DIR_PATHS exit /b 0

echo.^>^>mkdir%DIR_PATHS%
mkdir%DIR_PATHS%
