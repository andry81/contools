@echo off & goto DOC_END

rem USAGE:
rem   mkdir_if_notexist_strict.bat <path>

rem Description:
rem   A build pipeline wrapper over builtin `mkdir` command with
rem   echo, some conditions check, single long path workaround through the
rem   `robocopy` executable utility and `EMPTY_DIR_TMP` variable.
rem
rem   Does support long paths, but falls back to `robocopy.exe` implementation.
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
rem   Directory in the `EMPTY_DIR_TMP` variable must be not a long path.
rem
rem   Strict version, reports an error in case of unexisted drive or
rem   disconnected symbolic reference to a directory.

rem <path>
rem   Single directory path.
:DOC_END

setlocal

set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "DIR_PATH=%~1"

if not defined DIR_PATH (
  echo;%?~%: error: directory path is not defined.
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
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
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b -254
) >&2

:DIR_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%DIR_PATH%\.") do set "DIR_PATH=%%~fi" & set "DIR_DRIVE=%%~di"

rem CAUTION:
rem   The drive still must exist even if the path is not. If path exists, the path directory still can be in a disconnected state.
rem
if not exist "%DIR_DRIVE%" (
  echo;%?~%: error: the directory path drive is not exist: "%DIR_PATH%".
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b -254
) >&2

rem CAUTION:
rem   The `mklink` command can create symbolic directory link and in the disconnected state it does
rem   report existence of a directory without the trailing back slash:
rem     `x:\<path-to-dir-without-trailing-back-slash>`
rem   So we must test the path with the trailing back slash to check existence of the link AND it's connection state.
rem
if exist "\\?\%DIR_PATH%\*" (
  exit /b 0
) else if exist "\\?\%DIR_PATH%" (
  echo;%?~%: error: path does exist but is not a directory: "%DIR_PATH%".
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b -254
) >&2

echo;^>mkdir "%DIR_PATH%"

mkdir "%DIR_PATH%" && (
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b 0
)

if not exist "\\?\%SystemRoot%\System32\robocopy.exe" (
  echo;%?~%: error: could not create a target file directory: "%DIR_PATH%".
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b 255
) >&2

set REMOVE_EMPTY_DIR_TMP=0
if defined EMPTY_DIR_TMP (
  for /F "tokens=* delims="eol^= %%i in ("%EMPTY_DIR_TMP%\.") do set "EMPTY_DIR_TMP=%%~fi"
) else if defined SCRIPT_TEMP_CURRENT_DIR (
  set REMOVE_EMPTY_DIR_TMP=1
  set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.emptydir.%RANDOM%-%RANDOM%"
) else (
  set REMOVE_EMPTY_DIR_TMP=1
  set "EMPTY_DIR_TMP=%TEMP%\%?~n0%.emptydir.%RANDOM%-%RANDOM%"
)

if exist "\\?\EMPTY_DIR_TMP\*" (
  rem touch the temporary directory
  copy /B "%EMPTY_DIR_TMP%"+,, "%EMPTY_DIR_TMP%" >nul
) else mkdir "%EMPTY_DIR_TMP%" >nul

rem updates the modification file time if exists
"%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%DIR_PATH%" >nul

if %REMOVE_EMPTY_DIR_TMP% NEQ 0 rmdir /S /Q "%EMPTY_DIR_TMP%" >nul

if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
