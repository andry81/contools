@echo off

rem USAGE:
rem   rmdir.bat <path> [<rmdir-flags>...]

rem Description:
rem   The `rmdir` wrapper script with echo and some conditions check before
rem   call.

rem <path>
rem   Single directory path.

rem <rmdir-flags>:
rem   Command line flags to pass into builtin `rmdir` command.

if %TOOLS_VERBOSE%0 NEQ 0 echo.^>%~nx0 %*

setlocal

set "DIR_PATH=%~1"

if not defined DIR_PATH (
  echo.%~nx0: error: directory path is not defined.
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
  echo.%~nx0: error: directory path is invalid: "%DIR_PATH%".
  exit /b -254
) >&2

:DIR_PATH_OK

for /F "eol= tokens=* delims=" %%i in ("%DIR_PATH%\.") do set "DIR_PATH=%%~fi"

call "%%~dp0setshift.bat" 1 RMDIR_FLAGS_ %%*

echo.^>^>rmdir "%DIR_PATH%" %RMDIR_FLAGS_%
rmdir "%DIR_PATH%" %RMDIR_FLAGS_%
