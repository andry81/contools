@echo off

setlocal DISABLEDELAYEDEXPANSION

rem script flags
set FLAG_FULL_PARSE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-full_parse" (
    set FLAG_FULL_PARSE=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "__?CONFIG_IN_DIR=%~1"
set "__?CONFIG_OUT_DIR=%~2"
set "__?CONFIG_FILE=%~3"

if not defined __?CONFIG_IN_DIR (
  echo.%~nx0: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __?CONFIG_OUT_DIR (
  echo.%~nx0: error: output config directory is not defined.
  exit /b 2
) >&2

set "__?CONFIG_IN_DIR=%__?CONFIG_IN_DIR:\=/%"
set "__?CONFIG_OUT_DIR=%__?CONFIG_OUT_DIR:\=/%"

if "%__?CONFIG_IN_DIR:~-1%" == "/" set "__?CONFIG_IN_DIR=%__?CONFIG_IN_DIR:~0,-1%"
if "%__?CONFIG_OUT_DIR:~-1%" == "/" set "__?CONFIG_OUT_DIR=%__?CONFIG_OUT_DIR:~0,-1%"

if not exist "%__?CONFIG_IN_DIR%\" (
  echo.%~nx0: error: input config directory does not exist: "%__?CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%__?CONFIG_OUT_DIR%\" (
  echo.%~nx0: error: output config directory does not exist: "%__?CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%" ^
if exist "%__?CONFIG_IN_DIR%/%__?CONFIG_FILE%.in" (
  echo."%__?CONFIG_IN_DIR%/%__?CONFIG_FILE%.in" -^> "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%"
  type "%__?CONFIG_IN_DIR:/=\%\%__?CONFIG_FILE%.in" > "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%"
)

rem load configuration files
if not exist "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%" (
  echo.%~nx0: error: config file is not found: "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%".
  exit /b 20
) >&2

if %FLAG_FULL_PARSE% NEQ 0 goto FULL_PARSE

for /F "usebackq eol=# tokens=* delims=" %%i in ("%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%") do (
  endlocal
  setlocal DISABLEDELAYEDEXPANSION
  for /F "eol=# tokens=1,* delims==" %%j in ("%%i") do (
    set "__?VAR=%%j"
    set "__?VALUE=%%k"
    call :FAST_PARSE_EXPR && (
      setlocal ENABLEDELAYEDEXPANSION
      if defined __?VALUE for /F "tokens=* delims=" %%i in ("!__?VAR!") do for /F "tokens=* delims=" %%j in ("!__?VALUE!") do for /F "tokens=* delims=" %%k in ("%%j") do (
        endlocal
        endlocal
        set "%%i=%%k"
      ) else for /F "tokens=* delims=" %%i in ("!__?VAR!") do (
        endlocal
        endlocal
        set "%%i="
      )
      type nul>nul
    ) || endlocal
  )
)

exit /b 0

:FAST_PARSE_EXPR
if not defined __?VAR exit /b 1

rem CAUTION:
rem Inplace trim of surrounded white spaces ONLY from left and right sequences as a whole for performance reasons.
rem

:01_TRIM_VAR_NAME_LEFT_LOOP
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ goto 01_TRIM_VAR_NAME_RIGHT_LOOP
set "__?VAR=%__?VAR:~1%"
goto 01_TRIM_VAR_NAME_LEFT_LOOP

:01_TRIM_VAR_NAME_RIGHT_LOOP
if not ^%__?VAR:~-1%/ == ^ / if not ^%__?VAR:~-1%/ == ^	/ goto 01_TRIM_VAR_NAME_RIGHT_LOOP_END
set "__?VAR=%__?VAR:~0,-1%"
if not defined __?VAR exit /b 1
goto 01_TRIM_VAR_NAME_RIGHT_LOOP

:01_TRIM_VAR_NAME_RIGHT_LOOP_END
if not defined __?VALUE exit /b 0

rem Replace a value quote characters by the \x01 character.
set "__?VAR=%__?VAR:"=%"
set "__?VALUE=%__?VALUE:"=%"

:01_TRIM_VAR_VALUE_LEFT_LOOP
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~0,1%/ == ^ / if not ^%__?VALUE:~0,1%/ == ^	/ goto 01_TRIM_VAR_VALUE_RIGHT_LOOP
set "__?VALUE=%__?VALUE:~1%"
goto 01_TRIM_VAR_VALUE_LEFT_LOOP

:01_TRIM_VAR_VALUE_RIGHT_LOOP
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ goto 01_TRIM_VAR_VALUE_RIGHT_LOOP_END
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
goto 01_TRIM_VAR_VALUE_RIGHT_LOOP

:01_TRIM_VAR_VALUE_RIGHT_LOOP_END
rem check for old style expression quotes
if "%__?VAR:~0,1%" == "" if "%__?VALUE:~-1%" == "" (
  set "__?VAR=%__?VAR:~1%"
  set "__?VALUE=%__?VALUE:~0,-1%"
)

for /F "eol= tokens=1,* delims=:" %%i in ("%__?VAR%") do (
  set "__?VAR=%%i"
  set "__?PLATFORM=%%j"
)

if not defined __?VAR exit /b 1

if defined __?PLATFORM ^
if not "%__?PLATFORM%" == "BAT" ^
if not "%__?PLATFORM%" == "WIN" ^
if not "%__?PLATFORM%" == "OSWIN" exit /b 1

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__?VAR%") do (
  set "__?ATTR=%%i"
  set "__?VAR=%%j"
)

if not defined __?VAR (
  set "__?VAR=%__?ATTR%"
  set "__?ATTR="
)

if not defined __?VAR exit /b 1

if not defined __?ATTR goto IGNORE_ATTR

if not "%__?ATTR:once=%" == "%__?ATTR%" if defined %__?VAR% exit /b 1

:IGNORE_ATTR
if ^/ == ^%__?VALUE:~1,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__?VALUE:~0,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__?VALUE:~-1%/ goto PREPARSE_VALUE

:REMOVE_QUOTES
set __?HAS_VALUE=0
for /F "tokens=* delims=" %%i in ("%__?VALUE:~1,-1%") do ( set "__?VALUE=%%i" & set "__?HAS_VALUE=1" )

if %__?HAS_VALUE% EQU 0 (
  set "__?VALUE="
  exit /b 0
)

goto PARSE_VALUE

:PREPARSE_VALUE
set __?HAS_VALUE=0
for /F "eol=# tokens=* delims=" %%i in ("%__?VALUE%") do set __?HAS_VALUE=1

if %__?HAS_VALUE% EQU 0 (
  set "__?VALUE="
  exit /b 0
)

:PARSE_VALUE
rem recode exclamation, quote characters and etc
set "__?EXCL__=!"
set __?QUOT__=^"
set "__?ESC__=^"
set "__?01__=$"
set "__?02__=/"
set "__?03__=\"
set "__?04__=}"
set "__?05__=*:$/{}"
set "__?VALUE=%__?VALUE:!=!__?EXCL__!%"
set "__?VALUE=%__?VALUE:$/=!__?QUOT__!%"
set "__?VALUE=%__?VALUE:=!__?QUOT__!%"
set "__?VALUE=%__?VALUE:^=!__?ESC__!%"
set "__?VALUE=%__?VALUE:$/$=!__?01__!%"
set "__?VALUE=%__?VALUE:$//=!__?02__!%"
set "__?VALUE=%__?VALUE:$/\=!__?03__!%"
set "__?VALUE=%__?VALUE:$/}=!__?04__!%"
set "__?VALUE=%__?VALUE:$/{}=!__?05__!%"
set "__?VALUE=%__?VALUE:$/{=!%"
set "__?VALUE=%__?VALUE:}=!%"

exit /b 0

:FULL_PARSE
for /F "usebackq eol=# tokens=* delims=" %%i in ("%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%") do (
  endlocal
  setlocal DISABLEDELAYEDEXPANSION
  for /F "eol=# tokens=1,* delims==" %%j in ("%%i") do (
    set "__?VAR=%%j"
    set "__?VALUE=%%k"
    call :FULL_PARSE_EXPR && (
      setlocal ENABLEDELAYEDEXPANSION
      if defined __?VALUE for /F "tokens=* delims=" %%i in ("!__?VAR!") do for /F "tokens=* delims=" %%j in ("!__?VALUE!") do for /F "tokens=* delims=" %%k in ("%%j") do (
        endlocal
        endlocal
        set "%%i=%%k"
      ) else for /F "tokens=* delims=" %%i in ("!__?VAR!") do (
        endlocal
        endlocal
        set "%%i="
      )
      type nul>nul
    ) || endlocal
  )
)

exit /b 0

:FULL_PARSE_EXPR
if not defined __?VAR exit /b 1

rem CAUTION:
rem Inplace trim of surrounded white spaces ONLY from left and right sequences as a whole for performance reasons.
rem

:02_TRIM_VAR_NAME_LEFT_LOOP
if not defined __?VAR exit /b 1
if not ^%__?VAR:~0,1%/ == ^ / if not ^%__?VAR:~0,1%/ == ^	/ goto 02_TRIM_VAR_NAME_LEFT_LOOP
set "__?VAR=%__?VAR:~1%"
goto 02_TRIM_VAR_NAME_LEFT_LOOP

:02_TRIM_VAR_NAME_LEFT_LOOP
if not ^%__?VAR:~-1%/ == ^ / if not ^%__?VAR:~-1%/ == ^	/ goto 02_TRIM_VAR_NAME_RIGHT_LOOP_END
set "__?VAR=%__?VAR:~0,-1%"
if not defined __?VAR exit /b 1
goto 02_TRIM_VAR_NAME_LEFT_LOOP

:02_TRIM_VAR_NAME_RIGHT_LOOP_END
if not defined __?VALUE exit /b 0

rem Replace a value quote characters by the \x01 character.
set "__?VAR=%__?VAR:"=%"
set "__?VALUE=%__?VALUE:"=%"

:02_TRIM_VAR_VALUE_LEFT_LOOP
if not defined __?VALUE exit /b 0
if not ^%__?VALUE:~0,1%/ == ^ / if not ^%__?VALUE:~0,1%/ == ^	/ goto 02_TRIM_VAR_VALUE_RIGHT_LOOP
set "__?VALUE=%__?VALUE:~1%"
goto 02_TRIM_VAR_VALUE_LEFT_LOOP

:02_TRIM_VAR_VALUE_RIGHT_LOOP
if not ^%__?VALUE:~-1%/ == ^ / if not ^%__?VALUE:~-1%/ == ^	/ goto 02_TRIM_VAR_VALUE_RIGHT_LOOP_END
set "__?VALUE=%__?VALUE:~0,-1%"
if not defined __?VALUE exit /b 0
goto 02_TRIM_VAR_VALUE_RIGHT_LOOP

:02_TRIM_VAR_VALUE_RIGHT_LOOP_END
rem check for old style expression quotes
if "%__?VAR:~0,1%" == "" if "%__?VALUE:~-1%" == "" (
  set "__?VAR=%__?VAR:~1%"
  set "__?VALUE=%__?VALUE:~0,-1%"
)

for /F "eol= tokens=1,* delims=:" %%i in ("%__?VAR%") do (
  set "__?VAR=%%i"
  set "__?PLATFORM=%%j"
)

if not defined __?VAR exit /b 1

if defined __?PLATFORM ^
if not "%__?PLATFORM%" == "BAT" ^
if not "%__?PLATFORM%" == "WIN" ^
if not "%__?PLATFORM%" == "OSWIN" exit /b 1

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__?VAR%") do (
  set "__?ATTR=%%i"
  set "__?VAR=%%j"
)

if not defined __?VAR (
  set "__?VAR=%__?ATTR%"
  set "__?ATTR="
)

if not defined __?VAR exit /b 1

if not defined __?ATTR goto IGNORE_ATTR

if not "%__?ATTR:once=%" == "%__?ATTR%" if defined %__?VAR% exit /b 1

:IGNORE_ATTR
if ^/ == ^%__?VALUE:~1,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__?VALUE:~0,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__?VALUE:~-1%/ goto PREPARSE_VALUE

:REMOVE_QUOTES
set __?HAS_VALUE=0
for /F "tokens=* delims=" %%i in ("%__?VALUE:~1,-1%") do ( set "__?VALUE=%%i" & set "__?HAS_VALUE=1" )

if %__?HAS_VALUE% EQU 0 (
  set "__?VALUE="
  exit /b 0
)

goto PARSE_VALUE

:PREPARSE_VALUE
set __?HAS_VALUE=0
for /F "eol=# tokens=* delims=" %%i in ("%__?VALUE%") do set __?HAS_VALUE=1

if %__?HAS_VALUE% EQU 0 (
  set "__?VALUE="
  exit /b 0
)

:PARSE_VALUE
rem apply variable substitutions and evaluate escapes
set "__?NEXT_CHAR="
set __?VALUE_CHAR_INDEX=-1
set __?IS_SUBST_OPEN=0
rem `$/<char>`, escape sequence does exist on a single line only
set __?IS_PREV_CHAR_ESCAPED=0
set __?IS_NEXT_CHAR_TO_ESCAPE=0
set __?VALUE_FROM_INDEX=0
set "__?VALUE_SUBSTED="

:PARSE_VALUE_CHAR_LOOP
set /A __?VALUE_CHAR_INDEX+=1
set "__?PREV_CHAR=%__?NEXT_CHAR%"
call set "__?NEXT_CHAR=%%__?VALUE:~%__?VALUE_CHAR_INDEX%,1%%"
if not defined __?NEXT_CHAR goto PARSE_VALUE_CHAR_LOOP_END

if %__?IS_NEXT_CHAR_TO_ESCAPE% NEQ 0 goto ESCAPE_NEXT_CHAR

if %__?IS_SUBST_OPEN% EQU 0 (
  if ^%__?NEXT_CHAR%/ == ^// (
    if %__?IS_PREV_CHAR_ESCAPED% EQU 0 (
      if "%__?PREV_CHAR%" == "$" (
        set "__?IS_NEXT_CHAR_TO_ESCAPE=1"
      ) else set "__?VALUE_SUBSTED=%__?VALUE_SUBSTED%%__?NEXT_CHAR%"
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
