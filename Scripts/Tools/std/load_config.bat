@echo off

setlocal DISABLEDELAYEDEXPANSION

set "__CONFIG_IN_DIR=%~1"
set "__CONFIG_OUT_DIR=%~2"
set "__CONFIG_FILE=%~3"

if not defined __CONFIG_IN_DIR (
  echo.%~nx0: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __CONFIG_OUT_DIR (
  echo.%~nx0: error: output config directory is not defined.
  exit /b 2
) >&2

set "__CONFIG_IN_DIR=%__CONFIG_IN_DIR:\=/%"
set "__CONFIG_OUT_DIR=%__CONFIG_OUT_DIR:\=/%"

if "%__CONFIG_IN_DIR:~-1%" == "/" set "__CONFIG_IN_DIR=%__CONFIG_IN_DIR:~0,-1%"
if "%__CONFIG_OUT_DIR:~-1%" == "/" set "__CONFIG_OUT_DIR=%__CONFIG_OUT_DIR:~0,-1%"

if not exist "%__CONFIG_IN_DIR%\" (
  echo.%~nx0: error: input config directory does not exist: "%__CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%__CONFIG_OUT_DIR%\" (
  echo.%~nx0: error: output config directory does not exist: "%__CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if not exist "%__CONFIG_OUT_DIR%\%__CONFIG_FILE%" ^
if exist "%__CONFIG_IN_DIR%/%__CONFIG_FILE%.in" (
  echo."%__CONFIG_IN_DIR%/%__CONFIG_FILE%.in" -^> "%__CONFIG_OUT_DIR%/%__CONFIG_FILE%"
  type "%__CONFIG_IN_DIR:/=\%\%__CONFIG_FILE%.in" > "%__CONFIG_OUT_DIR%/%__CONFIG_FILE%"
)

rem load configuration files
if not exist "%__CONFIG_OUT_DIR%/%__CONFIG_FILE%" (
  echo.%~nx0: error: config file is not found: "%__CONFIG_OUT_DIR%/%__CONFIG_FILE%".
  exit /b 20
) >&2

for /F "usebackq eol=# tokens=* delims=" %%i in ("%__CONFIG_OUT_DIR%/%__CONFIG_FILE%") do (
  endlocal
  setlocal DISABLEDELAYEDEXPANSION
  for /F "eol=# tokens=1,* delims==" %%j in ("%%i") do (
    set "__VAR=%%j"
    set "__VALUE=%%k"
    call :PARSE_EXPR && (
      setlocal ENABLEDELAYEDEXPANSION
      for /F "tokens=1,* delims==" %%i in ("!__VAR!=!__VALUE!") do (
        endlocal
        endlocal
        set "%%i=%%j"
      )
      type nul>nul
    ) || endlocal
  )
)

exit /b 0

:PARSE_EXPR
if not defined __VAR exit /b 1

rem CAUTION:
rem Inplace trim of surrounded white spaces ONLY from left and right sequences as a whole for performance reasons.
rem

:TRIM_VAR_NAME
:TRIM_VAR_NAME_LEFT_LOOP
if not defined __VAR exit /b 1
if not ^%__VAR:~0,1%/ == ^ / if not ^%__VAR:~0,1%/ == ^	/ goto TRIM_VAR_NAME_RIGHT_LOOP
set "__VAR=%__VAR:~1%"
goto TRIM_VAR_NAME_LEFT_LOOP

:TRIM_VAR_NAME_RIGHT_LOOP
if not ^%__VAR:~-1%/ == ^ / if not ^%__VAR:~-1%/ == ^	/ goto TRIM_VAR_NAME_RIGHT_LOOP_END
set "__VAR=%__VAR:~0,-1%"
if not defined __VAR exit /b 1
goto TRIM_VAR_NAME_RIGHT_LOOP

:TRIM_VAR_NAME_RIGHT_LOOP_END

if not defined __VALUE exit /b 0

rem Replace a value quote characters by the \x01 character.
set "__VALUE=%__VALUE:"=%"

:TRIM_VAR_VALUE
setlocal DISABLEDELAYEDEXPANSION

:TRIM_VAR_VALUE_LEFT_LOOP
if not defined __VALUE exit /b 0
if not ^%__VALUE:~0,1%/ == ^ / if not ^%__VALUE:~0,1%/ == ^	/ goto TRIM_VAR_VALUE_RIGHT_LOOP
set "__VALUE=%__VALUE:~1%"
goto TRIM_VAR_VALUE_LEFT_LOOP

:TRIM_VAR_VALUE_RIGHT_LOOP
if not ^%__VALUE:~-1%/ == ^ / if not ^%__VALUE:~-1%/ == ^	/ goto TRIM_VAR_VALUE_RIGHT_LOOP_END
set "__VALUE=%__VALUE:~0,-1%"
if not defined __VALUE exit /b 0
goto TRIM_VAR_VALUE_RIGHT_LOOP

:TRIM_VAR_VALUE_RIGHT_LOOP_END
(
  endlocal
  set "__VALUE=%__VALUE%"
)

for /F "eol=	 tokens=1,* delims=:" %%i in ("%__VAR%") do (
  set "__VAR=%%i"
  set "__PLATFORM=%%j"
)

if not defined __VAR exit /b 1

if defined __PLATFORM ^
if not "%__PLATFORM%" == "BAT" ^
if not "%__PLATFORM%" == "WIN" ^
if not "%__PLATFORM%" == "OSWIN" exit /b 1

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__VAR%") do (
  set "__ATTR=%%i"
  set "__VAR=%%j"
)

if not defined __VAR (
  set "__VAR=%__ATTR%"
  set "__ATTR="
)

if not defined __VAR exit /b 1

if ^/ == ^%__VALUE:~1,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__VALUE:~0,1%/ goto PREPARSE_VALUE
if not ^/ == ^%__VALUE:~-1%/ goto PREPARSE_VALUE

:REMOVE_QUOTES
for /F "tokens=* delims=" %%i in ("%__VALUE:~1,-1%") do set "__VALUE=%%i"

if not defined __VALUE exit /b 0

goto PARSE_VALUE

:PREPARSE_VALUE
set __HAS_VALUE=0
for /F "eol=# tokens=* delims=" %%i in ("%__VALUE%") do set "__HAS_VALUE=1"

if %__HAS_VALUE% EQU 0 (
  set "__VALUE="
  exit /b 0
)

:PARSE_VALUE
rem recode quote and exclamation characters
set "__ESC__=^"
set __QUOT__=^"
set "__EXCL__=!"
set "__VALUE=%__VALUE:!=!__EXCL__!%"
set "__VALUE=%__VALUE:^=!__ESC__!%"
set "__VALUE=%__VALUE:=!__QUOT__!%"

exit /b 0
