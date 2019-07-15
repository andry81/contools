@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

rem script flags
set PAUSE_ON_EXIT=0
set PAUSE_ON_ERROR=0
set PAUSE_TIMEOUT_SEC=0

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

if %PAUSE_ON_EXIT% NEQ 0 (
  if %PAUSE_TIMEOUT_SEC% NEQ 0 (
    timeout /T %PAUSE_TIMEOUT_SEC%
  ) else pause
) else if %LASTERROR% NEQ 0 if %PAUSE_ON_ERROR% NEQ 0 (
  if %PAUSE_TIMEOUT_SEC% NEQ 0 (
    timeout /T %PAUSE_TIMEOUT_SEC%
  ) else pause
)

exit /b %LASTERROR%

:MAIN
rem script flags
set "FLAG_FILE_NAME_TO_SAVE=default.lst"

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-pause_on_error" (
    set PAUSE_ON_ERROR=1
  ) else if "%FLAG%" == "-pause_timeout_sec" (
    set "PAUSE_TIMEOUT_SEC=%~2"
    shift
  ) else if "%FLAG%" == "-to_file_name" (
    set "FLAG_FILE_NAME_TO_SAVE=%~2"
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

set "LIST_FILE_PATH=%~1"

if not defined LIST_FILE_PATH exit /b 0

set "LIST_FILE_PATH=%LIST_FILE_PATH:/=\%"

echo."%LIST_FILE_PATH%" -^> "%CD:\=/%/%FLAG_FILE_NAME_TO_SAVE%"
copy "%LIST_FILE_PATH%" "%FLAG_FILE_NAME_TO_SAVE%" /B /Y

exit /b 0
