@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script xcopy files from a directory preserving relative paths to each file.
rem   Script automatically does self logging.

rem Usage:
rem  <Command arguments>

rem Command arguments:
rem %1 - Path to directory with files including subdirectories.
rem %2 - Path to directory with going to be copied files.
rem %3 - Additional arguments for `xcopy.bat` script.
rem %4-%N - Optional file pattern list for the `dir` command, ex: `"*.txt" "*.md"

setlocal

if not defined PROJECT_LOG_ROOT set PROJECT_LOG_ROOT=.log

call "%%~dp0../__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem ...

exit /b %LAST_ERROR%

:MAIN
set "XCOPY_FROM_DIR=%~1"
set "XCOPY_TO_DIR=%~2"
set "XCOPY_SWITCHES=%~3"

rem read archive file pattern list
call "%%CONTOOLS_ROOT%%/std/setshift.bat" 3 FILE_PTTN_LIST %%*

if not defined XCOPY_FROM_DIR (
  echo.%~nx0: error: XCOPY_FROM_DIR is not defined.
  exit /b 255
) >&2

if not exist "%XCOPY_FROM_DIR%\*" (
  echo.%~nx0: error: XCOPY_FROM_DIR does not exist: "%XCOPY_FROM_DIR%".
  exit /b 255
) >&2

if not defined XCOPY_TO_DIR (
  echo.%~nx0: error: XCOPY_TO_DIR is not defined.
  exit /b 255
) >&2

if not exist "%XCOPY_TO_DIR%\*" (
  echo.%~nx0: error: XCOPY_TO_DIR does not exist: "%XCOPY_TO_DIR%".
  exit /b 255
) >&2

if not defined FILE_PTTN_LIST (
  echo.%~nx0: error: FILE_PTTN_LIST is not defined.
  exit /b 255
) >&2

rem default values

if not defined XCOPY_SWITCHES set XCOPY_SWITCHES=/Y /D /H

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" XCOPY_FROM_DIR  "%XCOPY_FROM_DIR%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" XCOPY_TO_DIR    "%XCOPY_TO_DIR%"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v XCOPY_FROM_DIR
set /A XCOPY_FROM_DIR_OFFSET=%ERRORLEVEL%+1

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir %FILE_PTTN_LIST% /A:-D /B /O:N /S

pushd "%XCOPY_FROM_DIR%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do set "FILE_PATH=%%i" & call :PROCESS
  popd
)
exit /b 0

:PROCESS
if not defined FILE_PATH exit /b 0

call set "FILE_REL_PATH=%%FILE_PATH:~%XCOPY_FROM_DIR_OFFSET%%%"

for /F "eol= tokens=* delims=" %%i in ("%XCOPY_FROM_DIR%\%FILE_REL_PATH%\..") do set "XCOPY_FROM_FILE_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%XCOPY_TO_DIR%\%FILE_REL_PATH%\..") do set "XCOPY_TO_FILE_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%FILE_REL_PATH%") do set "XCOPY_FILE_NAME=%%~nxi"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%XCOPY_FROM_FILE_DIR%%" "%%XCOPY_FILE_NAME%%" "%%XCOPY_TO_FILE_DIR%%" %%XCOPY_SWITCHES%%
