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

if %IMPL_MODE%0 NEQ 0 goto IMPL

if not defined PROJECT_LOG_ROOT set PROJECT_LOG_ROOT=.log

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -- %%*
set LASTERROR=%ERRORLEVEL%

rem ...

exit /b %LASTERROR%

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem ...

exit /b %LASTERROR%

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

if not exist "%XCOPY_FROM_DIR%" (
  echo.%~nx0: error: XCOPY_FROM_DIR does not exist: "%XCOPY_FROM_DIR%".
  exit /b 255
) >&2

if not defined XCOPY_TO_DIR (
  echo.%~nx0: error: XCOPY_TO_DIR is not defined.
  exit /b 255
) >&2

if not exist "%XCOPY_TO_DIR%" (
  echo.%~nx0: error: XCOPY_TO_DIR does not exist: "%XCOPY_TO_DIR%".
  exit /b 255
) >&2

if not defined FILE_PTTN_LIST (
  echo.%~nx0: error: FILE_PTTN_LIST is not defined.
  exit /b 255
) >&2

rem default values

if not defined XCOPY_SWITCHES set XCOPY_SWITCHES=/Y /D /H

rem Drop last error level
call;

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" XCOPY_FROM_DIR  "%XCOPY_FROM_DIR%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" XCOPY_TO_DIR    "%XCOPY_TO_DIR%"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v XCOPY_FROM_DIR
set /A XCOPY_FROM_DIR_OFFSET=%ERRORLEVEL%+1

pushd "%XCOPY_FROM_DIR%" && (
  for /F "usebackq eol= tokens=* delims=" %%i in (`@dir %FILE_PTTN_LIST% /A:-D /B /S /O:N`) do ( set "FILE_PATH=%%i" & call :PROCESS )
  popd
)
exit /b 0

:PROCESS
if not defined FILE_PATH exit /b 0

call set "FILE_REL_PATH=%%FILE_PATH:~%XCOPY_FROM_DIR_OFFSET%%%"

for /F "eol= tokens=* delims=" %%i in ("%XCOPY_FROM_DIR%\%FILE_REL_PATH%\..") do set "XCOPY_FROM_FILE_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%XCOPY_TO_DIR%\%FILE_REL_PATH%\..") do set "XCOPY_TO_FILE_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%FILE_REL_PATH%") do set "XCOPY_FILE_NAME=%%~nxi"

if not exist "%XCOPY_TO_FILE_DIR%\*" mkdir "%XCOPY_TO_FILE_DIR%"

call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" "%%XCOPY_FROM_FILE_DIR%%" "%%XCOPY_FILE_NAME%%" "%%XCOPY_TO_FILE_DIR%%" %%XCOPY_SWITCHES%%
