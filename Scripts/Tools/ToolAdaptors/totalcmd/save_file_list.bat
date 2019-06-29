@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

if %FLAG_TIMEOUT_TO_CLOSE_SEC%0 NEQ 0 timeout /T %FLAG_TIMEOUT_TO_CLOSE_SEC%

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_TIMEOUT_TO_CLOSE_SEC=0
set "FLAG_FILE_NAME_TO_SAVE=default.lst"

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-timeout_to_close_sec" (
    set "FLAG_TIMEOUT_TO_CLOSE_SEC=%~2"
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
