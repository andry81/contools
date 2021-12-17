@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads and replaces characters in the string to a variable.
rem   Script additionally reads length of the string and returns it.
rem   Script searches characters in the string defined by even offsets
rem   in another string with characters for replacement and replaces
rem   them by characters with odd offsets from the same string

rem Command arguments:
rem %1 - Type of search flags:
rem   <none>  - (Default) use arguments for search string and characters to find
rem   /v      - use variable %2 as search string and variable %3 as characters
rem             to find. If %2 is empty, then the variable name is
rem             __STRING__. If %3 is empty, then the variable name is
rem             __CHARS__.
rem %2 - Escaping string in default search mode, otherwise it is the name of a
rem      variable which stores it if /v flag is used.
rem %3 - Set of characters which should be found and replaced.
rem %4 - Variable which would store replaced string.

rem Examples:
rem 1. rem would be evaluated as: a="a\b\,c"
rem    strrep.bat "" "a/b/.c" "/\.," a
rem 2. rem would be evaluated as: a="b\a\.c"
rem    strrep.bat "" "a\b\.c" "abba" a

if "%~4" == "" exit /b 1

rem Drop output variable
set "%~4="

rem Drop last error level
call;

rem Create local variable's stack
setlocal

set __STRING_VAR__=__STRING__
set __CHARS_VAR__=__CHARS__
if not "%~1" == "/v" (
  rem Unsafe strings assign, values can has control characters!
  set "__STRING__=%~2"
  set "__CHARS__=%~3"
) else (
  if not "%~2" == "" (
    set "__STRING_VAR__=%~2"
    set "__CHARS_VAR__=%~3"
  )
)

set __COUNTER1=0

:LOOP10
set "__EMPTY_FIELD=~%__COUNTER1%,1"
call set "__CHAR=%%%__STRING_VAR__%:%__EMPTY_FIELD%%%"
if not defined __CHAR goto EXIT
if "%__CHAR%^" == ""^" goto EXIT
if "%__CHAR%" == "%__EMPTY_FIELD%" goto EXIT

set __COUNTER2=0

:LOOP20
set "__EMPTY_FIELD1=~%__COUNTER2%,1"
call set "__CHAR1=%%%__CHARS_VAR__%:%__EMPTY_FIELD1%%%"
if not defined __CHAR1 goto LOOP30
if "%__CHAR1%^" == ""^" goto EXIT2
if "%__CHAR1%" == "%__EMPTY_FIELD1%" goto LOOP30
set /A __COUNTER2+=1

set "__EMPTY_FIELD2=~%__COUNTER2%,1"
call set "__CHAR2=%%%__CHARS_VAR__%:%__EMPTY_FIELD2%%%"
if not defined __CHAR2 goto LOOP30
if "%__CHAR2%^" == ""^" goto EXIT2
if "%__CHAR2%" == "%__EMPTY_FIELD2%" LOOP30
set /A __COUNTER2+=1

if "%__CHAR%" == "%__CHAR1%" (
  call set "%%~4=%%%~4%%%%__CHAR2%%"
  set /A __COUNTER1+=1
  goto LOOP10
)
goto LOOP20

:LOOP30
call set "%%~4=%%%~4%%%%__CHAR%%"
set /A __COUNTER1+=1
goto LOOP10

:EXIT2
call set "%%~4=%%%~4%%%%__CHAR%%"

:EXIT
rem Drop internal variables but use some changed value(s) for the return
call set "__ARGS__=%%~4=%%%~4%%"
(
  endlocal
  set "%__ARGS__%"
  exit /b %__COUNTER1%
)
