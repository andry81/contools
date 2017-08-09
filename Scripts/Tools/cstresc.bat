@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads and escapes string to a variable.
rem   Script additionally reads length of escaping string and returns it.
rem   Script replaces characters found in string with escape sequence -
rem   "\<Char>". So, if you want to pass characters which should be
rem   escaped and you want to escape character "\" itself, then you should pass
rem   it with others too, otherwise it wouldn't be escaped.

rem Command arguments:
rem %1 - Escaping string.
rem %2 - Variable which would store escaped string.
rem %3 - Set of characters which should be escaped.

rem Examples:
rem 1. cstresc.bat "a\b\.c" a "\."
rem    rem a="a\\b\\\.c"
rem 2. cstresc.bat "a\b\.c" a "."
rem    rem a="a\b\\.c"
rem 3. cstresc.bat "a\b\.c" a
rem    rem a="a\\b\\.c"

rem KNOWN ISSUES:
rem  1. Too slow implementation.
rem

if "%~2" == "" exit /b 65

rem Drop output variable
set "%~2="

if "%~1" == "" exit /b 0

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "__STR=%~1"
set __COUNTER1=0
if not "%~3" == "" goto LOOP20
:LOOP10
set "__EMPTY_FIELD=~%__COUNTER1%,1"
call set "__CHAR=%%__STR:%__EMPTY_FIELD%%%"
if not defined __CHAR goto EXIT
if "%__CHAR%^" == ""^" goto EXIT
if "%__CHAR%" == "%__EMPTY_FIELD%" goto EXIT
  if not "%__CHAR%" == "\" (
    call set "%%~2=%%%~2%%%%__CHAR%%"
  ) else (
    call set "%%~2=%%%~2%%\\"
  )
  set /A __COUNTER1+=1
  goto LOOP10

:LOOP20
set "__EMPTY_FIELD=~%__COUNTER1%,1"
call set "__CHAR=%%__STR:%__EMPTY_FIELD%%%"
if not defined __CHAR goto EXIT
if "%__CHAR%^" == ""^" goto EXIT
if "%__CHAR%" == "%__EMPTY_FIELD%" goto EXIT
  call "%%CONTOOLS_ROOT%%/strchr.bat" "" "%%~3" "%%__CHAR%%"
  if "%ERRORLEVEL%" == "-1" (
    call set "%%~2=%%%~2%%%%__CHAR%%"
  ) else (
    call set "%%~2=%%%~2%%\%%__CHAR%%"
  )
  set /A __COUNTER1+=1
  goto LOOP20

:EXIT
rem Drop internal variables but use some changed value(s) for the return
call set "__ARGS__=%%~2=%%%~2%%"
(
  endlocal
  set "%__ARGS__%"
  exit /b %__COUNTER1%
)
