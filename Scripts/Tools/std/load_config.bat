@echo off

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

for /F "usebackq eol=# tokens=* delims=" %%i in ("%__CONFIG_OUT_DIR%/%__CONFIG_FILE%") do for /F "eol=	 tokens=1,* delims==" %%j in ("%%i") do (
  set __VAR=%%j
  set __VALUE=%%k
  call :PARSE
)

rem drop local variables
(
  set "__VAR="
  set "__PLATFORM="
  set "__VALUE="
  set "__CONFIG_IN_DIR="
  set "__CONFIG_OUT_DIR="
  set "__CONFIG_FILE="
)

exit /b 0

:PARSE
for /F "eol=	 tokens=1,* delims=:" %%i in ("%__VAR%") do (
  set "__VAR=%%i"
  set "__PLATFORM=%%j"
)

rem trim surrounded white spaces
call :TRIM_VAR __VAR
call :TRIM_VAR __PLATFORM
call :TRIM_VAR __VALUE

if defined __PLATFORM ^
if not "%__PLATFORM%" == "BAT" ^
if not "%__PLATFORM%" == "WIN" ^
if not "%__PLATFORM%" == "OSWIN" exit /b 0

for /F "eol=# tokens=1,* delims=	 " %%i in ("%__VAR%") do (
  set "__ATTR=%%i"
  set "__VAR=%%j"
)

if not defined __VAR (
  set "__VAR=%__ATTR%"
  set "__ATTR="
)

if not defined __VALUE (
  set "%__VAR%="
  exit /b 0
)

if ^/ == ^%__VALUE:~1,1%/ goto DONT_REMOVE_QUOTES
if not ^"/ == ^%__VALUE:~0,1%/ goto DONT_REMOVE_QUOTES
if not ^"/ == ^%__VALUE:~-1%/ goto DONT_REMOVE_QUOTES

setlocal ENABLEDELAYEDEXPANSION
for /F "eol=	 tokens=* delims=" %%i in ("!__VALUE:~1,-1!") do (
  endlocal
  set %__VAR%=%%i
)
exit /b

:DONT_REMOVE_QUOTES
setlocal ENABLEDELAYEDEXPANSION
for /F "eol=	 tokens=* delims=" %%i in ("!__VALUE!") do (
  endlocal
  set %__VAR%=%%i
)
exit /b

:TRIM_VAR
rem drop the output variable value
if not "%~2" == "" if not "%~1" == "%~2" set "%~2="

if not defined %~1 exit /b 0

setlocal DISABLEDELAYEDEXPANSION

rem Load and replace a value quote characters by the \x01 character.
call set "RETURN_VALUE=%%%~1:"=%%"

rem Encode value to remove exclamation characters.
set "RETURN_VALUE=%RETURN_VALUE:?=?00%"
set "RETURN_VALUE=%RETURN_VALUE:!=?01%"

if not defined RETURN_VALUE exit /b 0

rem safe to enable
setlocal ENABLEDELAYEDEXPANSION

:TRIM_LEFT_LOOP
if not "!RETURN_VALUE:~0,1!" == " " if not "!RETURN_VALUE:~0,1!" == "	" goto TRIM_LEFT_LOOP_END
set "RETURN_VALUE=!RETURN_VALUE:~1!"
goto TRIM_LEFT_LOOP

:TRIM_LEFT_LOOP_END
if not defined RETURN_VALUE exit /b 0

:TRIM_RIGHT_LOOP
if not "!RETURN_VALUE:~-1!" == " " if not "!RETURN_VALUE:~-1!" == "	" goto TRIM_END
set "RETURN_VALUE=!RETURN_VALUE:~0,-1!"
goto TRIM_RIGHT_LOOP

:TRIM_END
if not defined RETURN_VALUE exit /b 0

rem restore value
(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE:?01=!%"
)

rem restore value
set "RETURN_VALUE=%RETURN_VALUE:?00=?%"

rem recode quote and exclamation characters
set "__ESC__=^"
set __QUOT__=^"
set "__EXCL__=!"
set "RETURN_VALUE=%RETURN_VALUE:!=!__EXCL__!%"
set "RETURN_VALUE=%RETURN_VALUE:^=!__ESC__!%"
set "RETURN_VALUE=%RETURN_VALUE:=!__QUOT__!%"

rem safe set
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=* delims=" %%i in ("!RETURN_VALUE!") do for /F "tokens=* delims=" %%j in ("%%i") do (
  endlocal
  endlocal
  if not "%~2" == "" (
    set "%~2=%%j"
  ) else (
    set "%~1=%%j"
  )
)

exit /b 0
