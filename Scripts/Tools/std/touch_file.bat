@echo off

rem USAGE:
rem   touch_file.bat <path>...

rem Description:
rem   The `touch` command analog for files, with echo and some conditions check
rem   before call. Does support long paths.
rem
rem   Partially based on this:
rem     https://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764725#764725

rem <path>...
rem   File path list.

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>%~nx0 %*

setlocal

set "?~nx0=%~nx0%"

set "FILE_PATH=%~1"
set FILE_COUNT=1

if not defined FILE_PATH (
  echo.%?~nx0%: error: at least one file path argument must be defined.
  exit /b -255
) >&2

:TOUCH_FILE_LOOP

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
for /F "eol= tokens=* delims=" %%j in ("%%~dpi.") do ( set "FILE_PATH=%%~fi" & set "FILE_DIR=%%~fj" & set "FILE_NAME=%%~nxi" )

if "%FILE_PATH:~0,4%" == "\\?\" set "FILE_PATH=%FILE_PATH:~4%"
if "%FILE_DIR:~0,4%" == "\\?\" set "FILE_DIR=%FILE_DIR:~4%"

rem CAUTION: must be with `\\?\` prefix to workaround a long path
for /F "eol= tokens=* delims=" %%i in ("\\?\%FILE_PATH%") do set "FILE_ATTR=%%~ai"

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>^>touch "%FILE_PATH%"

if exist "\\?\%FILE_PATH%\*" (
  echo.%?~nx0%: error: file path is a directory: "%FILE_PATH%".
  goto CONTINUE
) >&2

if not exist "\\?\%FILE_DIR%\*" (
  echo.%?~nx0%: error: directory does not exist: "%FILE_DIR%".
  goto CONTINUE
) >&2

rem CAUTION:
rem   The `type nul >> \\?\...` nor `copy \\?\...` does not support long file paths to an existed file.
rem   So we test on a long file path existence and if a long path, then move the file to a temporary directory,
rem   touch it and move back.

if not exist "\\?\%FILE_PATH%" ( type nul >> "\\?\%FILE_PATH%" & goto CONTINUE )

rem CAUTION:
rem   If the file were deleted before, then the creation date will be set from the previously deleted file!

rem check on long file path
if not exist "%FILE_PATH%" if exist "%SystemRoot%\System32\robocopy.exe" goto MOVE_TO_TMP

if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
  copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul
) else (
  attrib -r "%FILE_PATH%" >nul & copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul & attrib +r "%FILE_PATH%" >nul
)

goto CONTINUE

:MOVE_TO_TMP

set "FILE_PATH_TEMP_DIR=%TEMP%\touch_file.%RANDOM%-%RANDOM%"

"%SystemRoot%\System32\robocopy.exe" "%FILE_DIR%" "%FILE_PATH_TEMP_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
  copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
) else (
  "%SystemRoot%\System32\attrib.exe" -r "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & "%SystemRoot%\System32\attrib.exe" +r "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
)

"%SystemRoot%\System32\robocopy.exe" "%FILE_PATH_TEMP_DIR%" "%FILE_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /TEE /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

rmdir /S /Q "%FILE_PATH_TEMP_DIR%" >nul 2>nul

:CONTINUE

shift

set "FILE_PATH=%~1"

if "%FILE_PATH%" == "" exit /b 0

set /A FILE_COUNT+=1

goto TOUCH_FILE_LOOP
