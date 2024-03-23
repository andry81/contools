@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script searches substring in string and returns it's offset.
rem   If substring didn't found in the string, then returns -1.
rem   If string is empty or doesn't exist, then returns -1.
rem   If substring argument is empty or doesn't exist, then returns -1.

rem Command arguments:
rem %1 - Searching string.
rem %2 - Searching substring.
rem %3 - Search flags:
rem   <None>  - (Default) case sensitive
rem   /i      - case insensitive

rem Examples:
rem 1. call strstr.bat "Hello world!" "World" /i
rem    echo ERRORLEVEL=%ERRORLEVEL%

if "%~1" == "" exit /b -1

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/strlen.bat" "" "%%~2"
set __STRLEN=%ERRORLEVEL%
if %__STRLEN% EQU 0 exit /b -1

set "__STR=%~1"
set __COUNTER1=0

:LOOP10
call set "__SUBSTR=%%__STR:~%__COUNTER1%,%__STRLEN%%%"
if defined __SUBSTR (
  if %~3 not "%__SUBSTR%" == "%~2" (
    set /A __COUNTER1+=1
    goto LOOP10
  )
) else if not "%~2" == "" (
  set __COUNTER1=-1
)

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  exit /b %__COUNTER1%
)
