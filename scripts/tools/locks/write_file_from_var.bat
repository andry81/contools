@echo off & goto DOC_END

rem Description:
rem   Script to exclusively write a file from a variable value.
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "__VAR_NAME=%~1"
set "__LOCK_FILE0=%~2"
set "__WRITE_FILE0=%~3"

if not defined __VAR_NAME (
  echo;%?~%: error: VAR_NAME is not defined.
  exit /b 1
) >&2

if not defined __LOCK_FILE0 (
  echo;%?~%: error: LOCK_FILE0 is not defined.
  exit /b 2
) >&2

call set "__VAR__=%%%__VAR_NAME%%%"

:REPEAT_READ_LOOP
rem lock via redirection to file
set __LOCK_FILE0_ACQUIRE=0
( ( rem if lock is acquired, then we are in...
    set __LOCK_FILE0_ACQUIRE=1
    rem safe echo call
    for /F "tokens=* delims="eol^= %%i in ("%__VAR__%") do (echo;%%i) > "%__WRITE_FILE0%"
) 9> "%__LOCK_FILE0%" ) 2>nul

rem has lock been acquired and counter updated?
if %__LOCK_FILE0_ACQUIRE% NEQ 0 goto EXIT

rem busy wait for 20 msec
call "%%~dp0busy_wait.bat" 20

goto REPEAT_READ_LOOP

:EXIT
rem cleanup files
del /F /Q /A:-D "%__LOCK_FILE0%" >nul 2>nul

exit /b 0
