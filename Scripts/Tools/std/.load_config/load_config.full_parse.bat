
for /F "usebackq eol=# tokens=* delims=" %%i in ("%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%") do (
  endlocal
  setlocal DISABLEDELAYEDEXPANSION
  for /F "eol=# tokens=1,* delims==" %%j in ("%%i") do (
    set "__?VAR=%%j"
    set "__?VALUE=%%k"
    call :PARSE_EXPR && (
      setlocal ENABLEDELAYEDEXPANSION
      if defined __?VALUE for /F "tokens=* delims=" %%l in ("!__?VAR!") do for /F "tokens=* delims=" %%m in ("!__?VALUE!") do for /F "tokens=* delims=" %%n in ("%%m") do (
        endlocal
        endlocal
        set "%%l=%%n"
      ) else for /F "tokens=* delims=" %%l in ("!__?VAR!") do (
        endlocal
        endlocal
        set "%%l="
      )
      type nul>nul
    ) || endlocal
  )
)

exit /b 0

:PARSE_EXPR
if not defined __?VAR exit /b 1

rem Replace a value quote characters by the \x01 character.
set "__?VAR=%__?VAR:"=%"
if defined __?VALUE set "__?VALUE=%__?VALUE:"=%"
rem check for old style expression quotes
if defined __?VALUE if "%__?VAR:~0,1%" == "" if "%__?VALUE:~-1%" == "" (
  set "__?VAR=%__?VAR:~1%" & set "__?VALUE=%__?VALUE:~0,-1%"
)

rem CAUTION:
rem Inplace trim of surrounded white spaces ONLY from left and right sequences as a whole for performance reasons.
rem

call "%%~dp0load_config.trim_var_left.bat" || exit /b
call "%%~dp0load_config.trim_var_right.bat" || exit /b

if not defined __?VALUE exit /b 0

call "%%~dp0load_config.trim_value_left.bat" || exit /b
if not defined __?VALUE exit /b 0
call "%%~dp0load_config.trim_value_right.bat" || exit /b
if not defined __?VALUE exit /b 0

for /F "eol= tokens=1,* delims=:" %%i in ("%__?VAR%") do ( set "__?VAR=%%i" & set "__?PLATFORM=%%j" )

if not defined __?VAR exit /b 1

if defined __?PLATFORM if not "%__?PLATFORM%" == "BAT" if not "%__?PLATFORM%" == "WIN" if not "%__?PLATFORM%" == "OSWIN" exit /b 1

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__?VAR%") do ( set "__?ATTR=%%i" & set "__?VAR=%%j" )

if not defined __?VAR ( set "__?VAR=%__?ATTR%" & set "__?ATTR=" )

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

if %__?HAS_VALUE% EQU 0 ( set "__?VALUE=" & exit /b 0 )

goto PARSE_VALUE

:PREPARSE_VALUE
set __?HAS_VALUE=0
for /F "eol=# tokens=* delims=" %%i in ("%__?VALUE%") do set __?HAS_VALUE=1

if %__?HAS_VALUE% EQU 0 ( set "__?VALUE=" & exit /b 0 )

:PARSE_VALUE
rem apply variable substitutions and evaluate escapes
set "__?NEXT_CHAR=" & set __?VALUE_CHAR_INDEX=-1 & set __?IS_SUBST_OPEN=0
rem `$/<char>`, escape sequence does exist on a single line only
set __?IS_PREV_CHAR_ESCAPED=0 & set __?IS_NEXT_CHAR_TO_ESCAPE=0 & set __?VALUE_FROM_INDEX=0 & set "__?VALUE_SUBSTED="

call "%%~dp0load_config.full_parse.parse_value.bat"
exit /b 0
