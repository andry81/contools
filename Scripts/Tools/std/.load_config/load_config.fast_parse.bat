
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

set "__?ATTR="

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__?VAR%") do ( if "%%j" == "" goto ATTR_PARSE_END ) & ( if defined __?ATTR ( call set "__?ATTR=%%__?ATTR%% %%%%i" ) else set "__?ATTR=%%i" ) & set "__?VAR=%%j"
for /F "eol= tokens=1,* delims=	 " %%i in ("%__?VAR%") do ( if "%%j" == "" goto ATTR_PARSE_END ) & ( if defined __?ATTR ( call set "__?ATTR=%%__?ATTR%% %%%%i" ) else set "__?ATTR=%%i" ) & set "__?VAR=%%j"
for /F "eol= tokens=1,* delims=	 " %%i in ("%__?VAR%") do ( if "%%j" == "" goto ATTR_PARSE_END ) & ( if defined __?ATTR ( call set "__?ATTR=%%__?ATTR%% %%%%i" ) else set "__?ATTR=%%i" ) & set "__?VAR=%%j"
for /F "eol= tokens=1,* delims=	 " %%i in ("%__?VAR%") do ( if "%%j" == "" goto ATTR_PARSE_END ) & ( if defined __?ATTR ( call set "__?ATTR=%%__?ATTR%% %%%%i" ) else set "__?ATTR=%%i" ) & set "__?VAR=%%j"

:ATTR_PARSE_END
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
rem recode exclamation, quote characters and etc
set __?QUOT__=^"
set "__?EXCL__=!" & set "__?ESC__=^" & set "__?01__=$" & set "__?02__=/" & set "__?03__=\" & set "__?04__=}" & set "__?05__=*:$/{}"
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
