@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads and escapes string to a variable.
rem   Script additionally reads length of escaping string and returns it.
rem   Script replaces characters found in string with escape sequence -
rem   "^<Char>". Script searches and escapes all control characters including
rem   the "^" character and the "%" character.
rem

rem OVERALL SCRIPT OPTIMIZATIONS:
rem 1. Iteration over a for-loop is made by peaces to avoid the script slowdown,
rem    because the cmd interpreter runs a for-loop to the end even if a goto
rem    out of a for-loop scope is occured!
rem 2. Double expansion is made over the delayed expansion, that is faster than
rem    over the "call" command prefix.

rem Command arguments:
rem %1 - Type of search flags:
rem   <none>  - (Default) use %2 for input string
rem   /v      - use variable %2 and %4 as input string. If %2 is empty, then the
rem             variable name is __STRING__. If %4 is empty, then the variable
rem             name is __CHARS__.
rem %2 - Searching string in default search mode, otherwise it is the name of a
rem   variable which stores it if /v flag is used.
rem %3 - Variable which would store escaped string.
rem %4 - Either characters set or name of variable with characters set which
rem      should be prefixed and suffixed with below strings.
rem %5 - String to be inserted before prefixed character.
rem %6 - String to be inserted after suffixed character.
rem You should use special variables in the string/file to avoid problems with
rem respective characters:
rem   %?0% - expands to ^ (Useful where expansion take a place)
rem   %?1% - expands to " (Should always be used instead)
rem   !?2! - expands to ! (Should always be used inside
rem          "setlocal ENABLEDELAYEDEXPANSION")

rem Examples:
rem 1. stresc.bat "" "a&|\c" a
rem    rem a="a^&^|\c"
rem 2. stresc.bat "" a^^>>" a
rem    rem a="a^^^^^>^>"
rem 3. stresc.bat "" "%%a%%\!b!" a
rem    rem a="%a%\!b!"

if "%~3" == "" exit /b 1

rem Drop output variable
set "%~3="

rem Drop last error level
cd .

rem Create local variable's stack with disabled of delayed expansion (to avoid ! characters expansion)
setlocal DisableDelayedExpansion

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set "__PREFIX_STR=%~5"
set "__SUFFIX_STR=%~6"

set __STRING_VAR__=__STRING__
set __CHARS_VAR__=__CHARS__
if not "%~1" == "/v" (
  rem Unsafe strings assign, values can has control characters like quote character!
  set "__STRING__=%~2"
  if not "%~4" == "" (
    set "__CHARS__=%~4"
  ) else (
    set __CHARS_VAR__=
  )
) else (
  if not "%~2" == "" (
    rem Unsafe strings assign, values can has control characters like quote character!
    set "__STRING_VAR__=%~2"
  )
  if not "%~4" == "" (
    rem Unsafe strings assign, values can has control characters like quote character!
    set "__CHARS_VAR__=%~4"
  ) else (
    set __CHARS_VAR__=
  )
)

set ?0=^^
set ?1=^"
set ?2=!
set ?3=^?
set ?4=^*
set ?5=^&
set ?6=^|
set ?7=^<
set ?8=^>
set ?9=^(
set ?A=^)

rem Create local variable's stack with enabled of delayed expansion (to workaround the script slowdown)
setlocal EnableDelayedExpansion

set __QUOTE=0
set __COUNTER1=0
set __FOR10_STEP=32
set __FOR20_STEP=32

rem Safe and fast string check on empty value
set "__EMPTY_FIELD=~0,1"
set "__CHAR=!%__STRING_VAR__%:~0,1!"

rem Check on quote character first
if not "!__CHAR!^" == ""^" (
  rem Check on empty value
  if "!__CHAR!" == "" exit /b 0
  rem Check on empty value (specific cmd bug case)
  if "!__CHAR!" == "!__EMPTY_FIELD!" exit /b 0
)

:LOOP10
set __FOR10_BEGIN_FROM=0
set __FOR10_END_TO=%__FOR10_STEP%

:SUBLOOP10
for /L %%i in (%__FOR10_BEGIN_FROM%,1,%__FOR10_END_TO%) do (
  set "__EMPTY_FIELD=~%%i,1"
  set "__CHAR=!%__STRING_VAR__%:~%%i,1!"

  rem Check on quote character first
  if not "!__CHAR!^" == ""^" (
    rem Check on empty value
    if "!__CHAR!" == "" set __COUNTER1=%%i&& goto CHECK_ON_EXIT
    rem Check on out of bounds (specific cmd bug case)
    if "!__CHAR!" == "!__EMPTY_FIELD!" set __COUNTER1=%%i&& goto CHECK_ON_EXIT

    if not "!__CHAR!" == "!?2!" (
      rem echo =^!__CHAR!= - %%i
      set __CHAR_TO_APPEND=
      rem Check on " character
      if !__QUOTE! EQU 0 (
        if "!__CHAR!" == "^" set __CHAR_TO_APPEND=%%?0%%%%?0%%
        if "!__CHAR!" == "?" set __CHAR_TO_APPEND=%%?0%%%%?3%%
        if "!__CHAR!" == "*" set __CHAR_TO_APPEND=%%?0%%%%?4%%
        if "!__CHAR!" == "&" set __CHAR_TO_APPEND=%%?0%%%%?5%%
        if "!__CHAR!" == "|" set __CHAR_TO_APPEND=%%?0%%%%?6%%
        if "!__CHAR!" == "<" set __CHAR_TO_APPEND=%%?0%%%%?7%%
        if "!__CHAR!" == ">" set __CHAR_TO_APPEND=%%?0%%%%?8%%
        if "!__CHAR!" == "(" set __CHAR_TO_APPEND=%%?0%%%%?9%%
        if "!__CHAR!" == ")" set __CHAR_TO_APPEND=%%?0%%%%?A%%
      ) else (
        if "!__CHAR!" == "^" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%
        if "!__CHAR!" == "?" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?3%%
        if "!__CHAR!" == "*" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?4%%
        if "!__CHAR!" == "&" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?5%%
        if "!__CHAR!" == "|" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?6%%
        if "!__CHAR!" == "<" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?7%%
        if "!__CHAR!" == ">" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?8%%
        if "!__CHAR!" == "(" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?9%%
        if "!__CHAR!" == ")" set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?0%%%%?A%%
      )
      if "!__CHAR!" == "%%" set __CHAR_TO_APPEND=%%%%
      if "!__CHAR_TO_APPEND!" == "" set "__CHAR_TO_APPEND=!__CHAR!"
    ) else (
      rem echo =!?2!= - %%i
      set __CHAR_TO_APPEND=%%?2%%
    )
  ) else (
    rem Switch quote state variable
    rem echo =^"= - %%i
    if !__QUOTE! EQU 0 (
      set __CHAR_TO_APPEND=%%?0%%%%?1%%
      set __QUOTE=1
    ) else (
      set __CHAR_TO_APPEND=%%?0%%%%?0%%%%?0%%%%?1%%
      set __QUOTE=0
    )
  )

  call :APPEND %%3
)

set /A __FOR10_BEGIN_FROM+=%__FOR10_STEP%
set /A __FOR10_END_TO+=%__FOR10_STEP%

goto SUBLOOP10

:APPEND
set __DO_PREFIX=0
if not "%__CHARS_VAR__%" == "" (
  call "%%TOOLS_PATH%%\strchr.bat" /v %%__CHARS_VAR__%% __CHAR
  if !ERRORLEVEL! GEQ 0 set __DO_PREFIX=1
)

if !__DO_PREFIX!0 NEQ 00 (
  set "%~1=!%~1!!__PREFIX_STR!!__CHAR_TO_APPEND!!__SUFFIX_STR!"
) else (
  set "%~1=!%~1!!__CHAR_TO_APPEND!"
)

goto :EOF

:CHECK_ON_EXIT
if not %__COUNTER1% GTR 0 goto EXIT

:EXPAND_AND_EXIT
rem 1. Drop internal variables but use some changed value(s) for the return
rem 2. Expand all internal variables to insert quotes at the last step of the
rem    variables expansion
rem 3. Avoid usage the "call" after the endlocal, otherwise a call will
rem    set an old version of variable (that before the setlocal).
rem    Do use pure "set" instead of "call set"!
set "__ARGS__=%~3=!%~3!"
call set "__ARGS__=%__ARGS__%"

(
  endlocal
  endlocal
  set "%__ARGS__%"
  exit /b %__COUNTER1%
)

:EXIT
exit /b 0
