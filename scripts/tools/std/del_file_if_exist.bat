@echo off & goto DOC_END

rem USAGE:
rem   del_file_if_exist.bat <path> [<del-flags>...]

rem Description:
rem   The `del` wrapper script with echo and some conditions check before
rem   call.
rem
rem   Does support long paths, but can not delete.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like builtin `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` builtin variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.

rem <path>
rem   Single file path.

rem <del-flags>:
rem   Command line flags to pass into builtin `del` command.
:DOC_END

echo;^>%~nx0 %*

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "FROM_PATH=%~1"

if not defined FROM_PATH (
  echo;%?~%: error: file path argument must be defined.
  exit /b -255
) >&2

set "FROM_PATH=%FROM_PATH:/=\%"

if "%FROM_PATH:~0,4%" == "\\?\" set "FROM_PATH=%FROM_PATH:~4%"

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
if not "%FROM_PATH%" == "%FROM_PATH:<=%" goto FROM_PATH_ERROR
if not "%FROM_PATH%" == "%FROM_PATH:>=%" goto FROM_PATH_ERROR

goto FROM_PATH_OK

:FROM_PATH_ERROR
(
  echo;%?~%: error: file path is invalid: "%FROM_PATH%".
  exit /b -254
) >&2

:FROM_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%FROM_PATH%\.") do set "FROM_PATH=%%~fi"

rem CAUTION:
rem   The `mklink` command can create symbolic directory link and in the disconnected state it does
rem   report existence of a directory without the trailing back slash:
rem     `x:\<path-to-dir-without-trailing-back-slash>`
rem   So we must test the path with the trailing back slash to check existence of the link AND it's connection state.
rem
if not exist "\\?\%FROM_PATH%" (
  exit /b 0
) >&2 else if exist "\\?\%FROM_PATH%\*" (
  echo;%?~%: error: path does exist and is a directory: "%FROM_PATH%"
  exit /b -254
) >&2 else if exist "\\?\%FROM_PATH%\" (
  echo;%?~%: error: path does exist and is an unlinked directory: "%FROM_PATH%"
  exit /b -253
) >&2

rem CAUTION: we must override `/A` flag for a file removement ONLY
call "%%~dp0setshift.bat" 1 DEL_FLAGS_ %%* /A:-D

if %TOOLS_VERBOSE%0 NEQ 0 echo;^>^>del %DEL_FLAGS_% "%FROM_PATH%"
del %DEL_FLAGS_% "%FROM_PATH%"
