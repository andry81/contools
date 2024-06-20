@echo off

rem USAGE:
rem   touch_dir.bat <path>...

rem Description:
rem   The `touch` command analog for directories, with echo and some conditions
rem   check before call. Does support long paths.
rem
rem <path>...
rem   Directory path list.

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>%~nx0 %*

setlocal

set "?~nx0=%~nx0%"

set "DIR_PATH=%~1"
set DIR_COUNT=1

if not defined DIR_PATH (
  echo.%?~nx0%: error: at least one directory path argument must be defined.
  exit /b -255
) >&2

:TOUCH_DIR_LOOP

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
  echo.%?~nx0%: error: directory path is invalid: ARG=%DIR_COUNT% DIR_PATH="%DIR_PATH%".
  exit /b -254
) >&2

:DIR_PATH_OK

for /F "eol= tokens=* delims=" %%i in ("%DIR_PATH%\.") do set "DIR_PATH=%%~fi"

if "%DIR_PATH:~0,4%" == "\\?\" set "DIR_PATH=%DIR_PATH:~4%"

if not exist "\\?\%DIR_PATH%\*" (
  echo.%?~nx0%: error: directory does not exist: "%DIR_PATH%".
  goto CONTINUE
) >&2

set "DIR_PATH_TEMP_FILE_NAME=touch_dir.%RANDOM%-%RANDOM%.tmp"
set "DIR_PATH_TEMP_FILE=%DIR_PATH%\%DIR_PATH_TEMP_FILE_NAME%"

type nul >> "\\?\%DIR_PATH_TEMP_FILE%"

rem check on long file path and if long file path, then move the file to a temporary directory to delete it
if not exist "%FILE_PATH%" if exist "%SystemRoot%\System32\robocopy.exe" goto MOVE_TO_TMP

del /F /Q /A:-D "\\?\%DIR_PATH_TEMP_FILE%" >nul 2>nul

goto CONTINUE

:MOVE_TO_TMP

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "FILE_PATH_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\touch_dir.%RANDOM%-%RANDOM%"
) else set "FILE_PATH_TEMP_DIR=%TEMP%\touch_dir.%RANDOM%-%RANDOM%"

"%SystemRoot%\System32\robocopy.exe" "%DIR_PATH%" "%FILE_PATH_TEMP_DIR%" "%DIR_PATH_TEMP_FILE_NAME%" /R:0 /W:0 /NP /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

rmdir /S /Q "%FILE_PATH_TEMP_DIR%" >nul 2>nul

:CONTINUE

shift

set "DIR_PATH=%~1"

if "%DIR_PATH%" == "" exit /b 0

set /A DIR_COUNT+=1

goto TOUCH_DIR_LOOP
