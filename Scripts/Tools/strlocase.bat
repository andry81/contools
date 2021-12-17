@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script converts ANSI string into lower case string. Return 0 if string is
rem   not empty and not zero if is empty.

rem Command arguments:
rem %1 - Type of function:
rem   <none>  - (Default) use %2 for input string
rem   /v      - use variable %2 as input string. If %2 is empty, then the
rem             variable name is __STRING__.
rem %2 - String in default search mode, otherwise it is the name of a variable
rem      which stores string if /v flag is used.

rem Examples:
rem 1. call strlocase.bat "" "Hello world!"
rem    echo ERRORLEVEL=%ERRORLEVEL%

rem Drop last error level
call;

rem Drop return value
set "RETURN_VALUE="

setlocal

set __STRING_VAR__=__STRING__
if not "%~1" == "/v" (
  rem Unsafe strings assign, values can has control characters!
  set "__STRING__=%~2"
) else if not "%~2" == "" (
  set "__STRING_VAR__=%~2"
)

if "%~1" == "/v" ^
if not "%~2" == "" (
  call set "__STRING__=%%%__STRING_VAR__%%%"
)

if not defined __STRING__ exit /b 1

for %%i in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do ^
call :IMPL %%i

goto EXIT

:IMPL
call set "__STRING__=%%__STRING__:%~1%%"
exit /b 0

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set "RETURN_VALUE=%__STRING__%"
  exit /b 0
)
