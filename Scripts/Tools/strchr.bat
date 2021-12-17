@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script searches characters in string and returns offset of the first
rem   found.
rem   If the characters doesn't found in the string, then returns -1.
rem   If string empty or doesn't exist, then returns -1.
rem   If the characters argument is empty or doesn't exist, then returns
rem   length of string only.
rem
rem   WARNING:
rem     Avoid usage of the "!" character if the delayed expansion is on,
rem     use then replacement for it (for example "?2" as described below) that
rem     initializes BEFORE the expansion is enabled!

rem OVERALL SCRIPT OPTIMIZATIONS:
rem 1. Iteration over a for-loop is made by peaces to avoid the script slowdown,
rem    because the cmd interpreter runs a for-loop to the end even if a goto
rem    out of a for-loop scope is occured!
rem 2. Double expansion is made over the delayed expansion, that is faster than
rem    over the "call" command prefix.

rem Command arguments:
rem %1 - Type of search flags:
rem   <none>  - (Default) use arguments for search string and characters to find
rem   /v      - use variable %2 as search string and variable %3 as characters
rem             to find. If %2 is empty, then the variable name is
rem             __STRING__. If %3 is empty, then the variable name is
rem             __CHARS__.
rem %2 - Searching string in default search mode, otherwise it is the name of a
rem   variable which stores it if /v flag is used.
rem %3 - Searching characters in default search mode, otherwise it is the name
rem   of a variable which stores them if /v flag is used.
rem %4 - Search flags:
rem   <None>  - (Default) case sensitive
rem   /i      - case insensitive
rem You should use special variables in the string/file to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful when -e flag defined)
rem   %?1% - expands to " (Should always be used instead)
rem   !?2! - expands to ! (Should always be used inside
rem          "setlocal ENABLEDELAYEDEXPANSION")

rem Examples:
rem 1. call strchr.bat "" "Hello world!" W /i
rem    echo ERRORLEVEL=%ERRORLEVEL%

rem Drop last error level
call;

rem Create local variable's stack with disabled of delayed expansion (to avoid ! characters expansion)
setlocal DisableDelayedExpansion

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

rem Create local variable's stack with enabled of delayed expansion (to workaround the script slowdown)
setlocal EnableDelayedExpansion

set __COUNTER1=0
set __FOR10_STEP=32
set __FOR20_STEP=32

rem Safe and fast string check on empty values
set "__EMPTY_FIELD1=~0,1"
set "__CHAR1=!%__STRING_VAR__%:%__EMPTY_FIELD1%!"

rem Check on empty value
if not defined __CHAR1 ( set "__COUNTER1=-1" && goto EXIT )
rem Check on quote character first
if not "!__CHAR1!^" == ""^" (
  rem Check on empty value (specific cmd bug case)
  if "!__CHAR1!" == "!__EMPTY_FIELD1!" ( set "__COUNTER1=-1" && goto EXIT )
)

rem Safe and fast string check on empty values
set "__EMPTY_FIELD2=~0,1"
set "__CHAR2=!%__CHARS_VAR__%:%__EMPTY_FIELD2%!"

rem Check on empty value
if not defined __CHAR2 ( call :STRLEN && goto EXIT )
rem Check on quote character first
if not "!__CHAR2!^" == ""^" (
  rem Check on empty value (specific cmd bug case)
  if "!__CHAR2!" == "!__EMPTY_FIELD2!" ( call :STRLEN && goto EXIT )
)

:LOOP10
set __FOR10_BEGIN_FROM=0
set __FOR10_END_TO=%__FOR10_STEP%

:SUBLOOP10
for /L %%i in (%__FOR10_BEGIN_FROM%,1,%__FOR10_END_TO%) do (
  set "__EMPTY_FIELD1=~%%i,1"
  set "__CHAR1=!%__STRING_VAR__%:~%%i,1!"

  rem Check on empty value
  if not defined __CHAR1 ( set "__COUNTER1=-1" && goto EXIT )
  rem Check on quote character first
  if not "!__CHAR1!^" == ""^" (
    rem Check on out of bounds (specific cmd bug case)
    if "!__CHAR1!" == "!__EMPTY_FIELD1!" ( set "__COUNTER1=-1" && goto EXIT )
  )

  call :LOOP20 %%4
  if !ERRORLEVEL! EQU 0 ( set "__COUNTER1=%%i" && goto EXIT )
)

set /A __FOR10_BEGIN_FROM+=%__FOR10_STEP%
set /A __FOR10_END_TO+=%__FOR10_STEP%

goto SUBLOOP10

:LOOP20
set __FOR20_BEGIN_FROM=0
set __FOR20_END_TO=%__FOR20_STEP%

:SUBLOOP20
for /L %%j in (%__FOR20_BEGIN_FROM%,1,%__FOR20_END_TO%) do (
  set "__EMPTY_FIELD2=~%%j,1"
  set "__CHAR2=!%__CHARS_VAR__%:~%%j,1!"

  rem Check on empty value
  if not defined __CHAR2 exit /b 1
  rem Check on quote character first
  if not "!__CHAR2!^" == ""^" (
    rem Check on out of bounds (specific cmd bug case)
    if "!__CHAR2!" == "!__EMPTY_FIELD2!" exit /b 1
  )

  rem Uniform comparison including quote character
  if %~1 "!__CHAR1!^" == "!__CHAR2!^" exit /b 0
)

set /A __FOR20_BEGIN_FROM+=%__FOR20_STEP%
set /A __FOR20_END_TO+=%__FOR20_STEP%

goto SUBLOOP20

:STRLEN
set __FOR10_BEGIN_FROM=0
set __FOR10_END_TO=%__FOR10_STEP%

:SUBLOOP50
for /L %%i in (%__FOR10_BEGIN_FROM%,1,%__FOR10_END_TO%) do (
  set "__EMPTY_FIELD1=~%%i,1"
  set "__CHAR1=!%__STRING_VAR__%:~%%i,1!"

  rem Check on empty value
  if not defined __CHAR1 ( set "__COUNTER1=%%i" && exit /b )
  rem Check on quote character first
  if not "!__CHAR1!^" == ""^" (
    rem Check on out of bounds (specific cmd bug case)
    if "!__CHAR1!" == "!__EMPTY_FIELD1!" ( set "__COUNTER1=%%i" && exit /b )
  )
)

set /A __FOR10_BEGIN_FROM+=%__FOR10_STEP%
set /A __FOR10_END_TO+=%__FOR10_STEP%

goto SUBLOOP50

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  exit /b %__COUNTER1%
)
