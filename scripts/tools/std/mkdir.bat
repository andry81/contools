@echo off & goto DOC_END

rem USAGE:
rem   mkdir.bat <path>...

rem Description:
rem   The `mkdir` wrapper script with echo and some conditions check before
rem   call.
rem
rem   Does support long paths, but can not create.
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
rem
rem   Strict version, reports an error in case of unexisted drive or
rem   disconnected symbolic reference to a directory.

rem <path>...
rem   Directory path list.
:DOC_END

if %TOOLS_VERBOSE%0 NEQ 0 echo;^>%~nx0 %*

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "DIR_PATH=%~1"

if not defined DIR_PATH (
  echo;%?~%: error: at least one directory path argument must be defined.
  exit /b -255
) >&2

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "CMDLINE_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%.txt"
) else set "CMDLINE_TEMP_FILE=%TEMP%\%~n0.%RANDOM%-%RANDOM%.txt"

rem redirect command line into temporary file to print it correctly
(
  setlocal DISABLEEXTENSIONS
  (set PROMPT=$_)
  echo on
  for %%z in (%%z) do rem * %*#
  @echo off
  endlocal
) > "%CMDLINE_TEMP_FILE%"

set "__STRING__=" & for /F "usebackq tokens=* delims="eol^= %%i in ("%CMDLINE_TEMP_FILE%") do set "__STRING__=%%i"

del /F /Q /A:-D "%CMDLINE_TEMP_FILE%" >nul 2>nul

rem WORKAROUND:
rem   In case if `echo` is turned off externally.
rem
if not defined __STRING__ exit /b 0

setlocal ENABLEDELAYEDEXPANSION & if not "!__STRING__:~6!" == "# " (
  for /F "tokens=* delims="eol^= %%i in ("!__STRING__:~6,-2!") do endlocal & set "__STRING__=%%i"
) else endlocal & set "__STRING__="

if not defined __STRING__ exit /b 0

call "%%~dp0encode\encode_sys_chars_bat_cmdline.bat"

set DIR_COUNT=1
set DIR_COUNT_MAX=0

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do endlocal & for %%j in (%%i) do set /A DIR_COUNT_MAX+=1

:MKDIR_LOOP

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
  echo;%?~%: error: directory path is invalid: ARG=%DIR_COUNT% DIR_PATH="%DIR_PATH%".
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
if exist "\\?\%DIR_PATH%\*" (
  echo;%?~%: error: directory already exists: "%DIR_PATH%".
  echo;
  exit /b 1
) >&2 else if exist "\\?\%DIR_PATH%" (
  echo;%?~%: error: path does exist and is not a directory: "%DIR_PATH%".
  echo;
  exit /b -254
) >&2

shift

set /A DIR_COUNT+=1

if %DIR_COUNT_MAX% LSS %DIR_COUNT% goto EXEC

set "DIR_PATH=%~1"

if not defined DIR_PATH (
  echo;%?~%: error: directory path argument is not defined: ARG=%DIR_COUNT%
  exit /b -255
) >&2

goto MKDIR_LOOP

:EXEC
echo;^>^>mkdir %*
mkdir %*
