@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to exclusively write a file from a variable value.

setlocal

call "%%~dp0__init__.bat" || exit /b

set "__VAR_NAME=%~1"
set "__LOCK_FILE0=%~2"
set "__WRITE_FILE0=%~3"

if not defined __VAR_NAME (
  echo.%~nx0: error: VAR_NAME is not defined.
  exit /b 1
) >&2

if not defined __LOCK_FILE0 (
  echo.%~nx0: error: LOCK_FILE0 is not defined.
  exit /b 2
) >&2

call set "__VAR__=%%%__VAR_NAME%%%"

:REPEAT_READ_LOOP
rem lock via redirection to file
set __LOCK_FILE0_ACQUIRE=0
(
  (
    rem if lock is acquired, then we are in...
    rem safe echo call
    for /F "eol= tokens=* delims=" %%i in ("%__VAR__%") do (echo.%%i) > "%__WRITE_FILE0%"

    rem Drop error level to 0 to avoid interference with the error level from the redirection command below.
    call;
  ) 9> "%__LOCK_FILE0%" && set __LOCK_FILE0_ACQUIRE=1
) 2>nul

rem has lock been acquired and counter updated?
if %__LOCK_FILE0_ACQUIRE% NEQ 0 goto EXIT

rem improvised sleep of 20 msec wait
call "%%CONTOOLS_ROOT%%/std/sleep.bat" 20

goto REPEAT_READ_LOOP

:EXIT
rem cleanup files
del /F /Q /A:-D "%__LOCK_FILE0%" >nul 2>nul

exit /b 0
