@echo off

:PARSE_VALUE_CHAR_LOOP
set /A __?VALUE_CHAR_INDEX+=1 & set "__?PREV_CHAR=%__?NEXT_CHAR%"
call set "__?NEXT_CHAR=%%__?VALUE:~%__?VALUE_CHAR_INDEX%,1%%"
if not defined __?NEXT_CHAR goto PARSE_VALUE_CHAR_LOOP_END

if %__?IS_NEXT_CHAR_TO_ESCAPE% NEQ 0 goto ESCAPE_NEXT_CHAR

if %__?IS_SUBST_OPEN% EQU 0 (
  if ^%__?NEXT_CHAR%/ == ^// (
    if %__?IS_PREV_CHAR_ESCAPED% EQU 0 (
      if "%__?PREV_CHAR%" == "$" ( set "__?IS_NEXT_CHAR_TO_ESCAPE=1" ) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?NEXT_CHAR%"
    ) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?NEXT_CHAR%"
  ) else if ^%__?NEXT_CHAR%/ == ^$/ (
    if %__?IS_PREV_CHAR_ESCAPED% EQU 0 if ^%__?PREV_CHAR%/ == ^$/ set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%$"
  ) else if ^%__?PREV_CHAR%/ == ^$/ (
    set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%$%__?NEXT_CHAR%"
  ) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?NEXT_CHAR%"
) else if ^%__?NEXT_CHAR%/ == ^}/ goto SUBST_VAR

set __?IS_PREV_CHAR_ESCAPED=0

goto PARSE_VALUE_CHAR_LOOP

:SUBST_VAR
set __?IS_SUBST_OPEN=0
set /A __?VAR_NAME_LEN=%__?VALUE_CHAR_INDEX%-%__?VALUE_FROM_INDEX%
call set "__?SUBST_VAR_NAME=%%__?VALUE:~%__?VALUE_FROM_INDEX%,%__?VAR_NAME_LEN%%%"

set "__?SUBST_VAR_VALUE="
if defined __?SUBST_VAR_NAME call set "__?SUBST_VAR_VALUE=%%%__?SUBST_VAR_NAME%%%"
if defined __?SUBST_VAR_VALUE (
  set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?SUBST_VAR_VALUE%"
) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%*:$/{%__?SUBST_VAR_NAME%}"

set __?IS_PREV_CHAR_ESCAPED=0

goto PARSE_VALUE_CHAR_LOOP

:ESCAPE_NEXT_CHAR

set __?IS_NEXT_CHAR_TO_ESCAPE=0

if ^%__?NEXT_CHAR%/ == ^{/ goto SUBST_BEGIN

set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?NEXT_CHAR%"

set __?IS_PREV_CHAR_ESCAPED=1

goto PARSE_VALUE_CHAR_LOOP

:SUBST_BEGIN

set __?IS_SUBST_OPEN=1
set /A __?VALUE_FROM_INDEX=%__?VALUE_CHAR_INDEX%+1

set __?IS_PREV_CHAR_ESCAPED=0

goto PARSE_VALUE_CHAR_LOOP

:PARSE_VALUE_CHAR_LOOP_END
if %__?IS_SUBST_OPEN% NEQ 0 goto UNCLOSED_SUBST_VAR

if %__?IS_NEXT_CHAR_TO_ESCAPE% EQU 0 (
  if %__?IS_PREV_CHAR_ESCAPED% EQU 0 if ^%__?PREV_CHAR%/ == ^$/ set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%$"
) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%$/"

goto PARSE_VALUE_END

:UNCLOSED_SUBST_VAR
set /A __?VAR_NAME_LEN=%__?VALUE_CHAR_INDEX%-%__?VALUE_FROM_INDEX%
call set "__?SUBST_VAR_NAME=%%__?VALUE:~%__?VALUE_FROM_INDEX%,%__?VAR_NAME_LEN%%%"
set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%*:$/{%__?SUBST_VAR_NAME%"

:PARSE_VALUE_END
set "__?VALUE=%__?VALUE_SUBSTED%"

if not defined __?VALUE exit /b 0

rem recode quote and exclamation characters
set "__?ESC__=^"
set __?QUOT__=^"
set "__?EXCL__=!"
set "__?VALUE=%__?VALUE:!=!__?EXCL__!%"
set "__?VALUE=%__?VALUE:^=!__?ESC__!%"
set "__?VALUE=%__?VALUE:=!__?QUOT__!%"

exit /b 0
