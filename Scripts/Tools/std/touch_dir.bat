@echo off & goto DOC_END

rem USAGE:
rem   touch_dir.bat <path>...

rem Description:
rem   The `touch` command analog for directories, with echo and some conditions
rem   check before call.
rem
rem   Does support long paths.
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

rem <path>...
rem   Directory path list.
:DOC_END

if %TOOLS_VERBOSE%0 NEQ 0 echo;^>%~nx0 %*

setlocal

set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~dp0=%~dp0%"

set "DIR_PATH=%~1"
set DIR_COUNT=1

if not defined DIR_PATH (
  echo;%?~%: error: at least one directory path argument must be defined.
  exit /b -255
) >&2

:TOUCH_DIR_LOOP

set "DIR_PATH=%DIR_PATH:/=\%"

if "%DIR_PATH:~0,4%" == "\\?\" set "DIR_PATH=%DIR_PATH:~4%"

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
  echo;%?~%: error: directory path is invalid: ARG=%DIR_COUNT% DIR_PATH="%DIR_PATH%".
  exit /b -254
) >&2

:DIR_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%DIR_PATH%\.") do set "DIR_PATH=%%~fi"

if not exist "\\?\%DIR_PATH%\*" (
  echo;%?~%: error: directory does not exist: "%DIR_PATH%".
  goto CONTINUE
) >&2

set "DIR_PATH_TEMP_FILE_NAME=.%?~n0%.%RANDOM%-%RANDOM%.tmp"
set "DIR_PATH_TEMP_FILE=%DIR_PATH%\%DIR_PATH_TEMP_FILE_NAME%"

rem CAUTION:
rem   If the file were deleted before, then the creation date will be set by `type nul >> ...` from the previously deleted file!

type nul > "\\?\%DIR_PATH_TEMP_FILE%"

call "%%?~dp0%%xremove_file.bat" "%%DIR_PATH_TEMP_FILE%%"

:CONTINUE

shift

set "DIR_PATH=%~1"

if "%DIR_PATH%" == "" exit /b 0

set /A DIR_COUNT+=1

goto TOUCH_DIR_LOOP
