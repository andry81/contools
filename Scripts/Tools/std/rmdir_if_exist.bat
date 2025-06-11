@echo off & goto DOC_END

rem USAGE:
rem   rmdir_if_exist.bat <path> [<rmdir-flags>...]

rem Description:
rem   The `rmdir` if-exist wrapper script with echo and some conditions check
rem   before call.
rem
rem   Not strict version, reports an error in case of unexisted drive, but
rem   does not check for disconnected symbolic reference to a directory.

rem <path>
rem   Single directory path.

rem <rmdir-flags>:
rem   Command line flags to pass into builtin `rmdir` command.
:DOC_END

if %TOOLS_VERBOSE%0 NEQ 0 echo;^>%~nx0 %*

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "DIR_PATH=%~1"

if not defined DIR_PATH (
  echo;%?~%: error: directory path is not defined.
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
if not "%DIR_PATH%" == "%DIR_PATH:<=%" goto DIR_PATH_ERROR
if not "%DIR_PATH%" == "%DIR_PATH:>=%" goto DIR_PATH_ERROR

goto DIR_PATH_OK

:DIR_PATH_ERROR
(
  echo;%?~%: error: directory path is invalid: "%DIR_PATH%".
  exit /b -254
) >&2

:DIR_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%DIR_PATH%\.") do set "DIR_PATH=%%~fi" & set "DIR_DRIVE=%%~di"

rem CAUTION:
rem   The drive still must exist even if the path is not. If path exists, the path directory still can be in a disconnected state.
rem
if not exist "%DIR_DRIVE%" (
  echo;%?~%: error: the directory path drive is not exist: "%DIR_PATH%".
  exit /b -254
) >&2

rem CAUTION:
rem   The `mklink` command can create symbolic directory link and in the disconnected state it does
rem   report existence of a directory without the trailing back slash:
rem     `x:\<path-to-dir-without-trailing-back-slash>`
rem   So we must test the path with the trailing back slash to check existence of the link AND it's connection state.
rem
if not exist "\\?\%DIR_PATH%" (
  exit /b 0
) >&2 else if not exist "\\?\%DIR_PATH%\*" (
  echo;%?~%: error: path does exist and is not a directory: "%DIR_PATH%".
  echo;
  exit /b -254
) >&2

call "%%~dp0setshift.bat" 1 RMDIR_FLAGS_ %%*

echo;^>^>rmdir "%DIR_PATH%" %RMDIR_FLAGS_%
rmdir "%DIR_PATH%" %RMDIR_FLAGS_%
