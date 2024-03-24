@echo off

rem USAGE:
rem   touch_file.bat <path>...

rem Description:
rem   The `touch` command analog for files.
rem
rem   based on: https://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764725#764725

rem <path>...
rem   File path list.

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>%~nx0 %*

setlocal

set "?~nx0=%~nx0%"

:TOUCH_FILE_LOOP

set "FILE_PATH=%~1"
set FILE_COUNT=1

if not defined FILE_PATH (
  echo.%?~nx0%: error: at least one file path argument must be defined.
  exit /b -255
) >&2

set "FILE_PATH=%FILE_PATH:/=\%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FILE_PATH:~0,1%" goto FILE_PATH_ERROR

rem ...double `\\` character
if not "%FILE_PATH%" == "%FILE_PATH:\\=\%" goto FILE_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FILE_PATH:~-1%" goto FILE_PATH_ERROR

rem check on invalid characters in path
if not "%FILE_PATH%" == "%FILE_PATH:**=%" goto FILE_PATH_ERROR
if not "%FILE_PATH%" == "%FILE_PATH:?=%" goto FILE_PATH_ERROR

goto FILE_PATH_OK

:FILE_PATH_ERROR
(
  echo.%?~nx0%: error: file path is invalid: ARG=%FILE_COUNT% FILE_PATH="%FILE_PATH%".
  exit /b -254
) >&2

:FILE_PATH_OK

for /F "eol= tokens=* delims=" %%i in ("%FILE_PATH%\.") do ^
for /F "eol= tokens=* delims=" %%j in ("%%~dpi.") do ( set "FILE_PATH=%%~fi" & set "FILE_DIR=%%~fj" & set "FILE_ATTR=%%~ai" )

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>^>touch "%FILE_PATH%"

if not exist "%FILE_DIR%\*" (
  echo.%?~nx0%: error: directory does not exist: "%FILE_DIR%".
  goto CONTINUE
) >&2

if not exist "%FILE_PATH%" ( type nul >> "%FILE_PATH%" & goto CONTINUE )

if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
  copy "%~1"+,, > nul
) else (
  attrib -r "%FILE_PATH%" >nul & copy "%FILE_PATH%"+,, > nul & attrib +r "%FILE_PATH%" >nul
)

:CONTINUE

shift

if "%~1" == "" exit /b 0

set /A FILE_COUNT+=1

goto TOUCH_FILE_LOOP
