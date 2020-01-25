@echo off

set "__CONFIG_DIR=%~1"
set "__CONFIG_FILE=%~2"

if not defined __CONFIG_DIR (
  echo.%~nx0: error: config directory is not defined.
  exit /b 1
) >&2

if "%__CONFIG_DIR:~-1%" == "\" set "__CONFIG_DIR=%__CONFIG_DIR:~0,-1%"

if not exist "%__CONFIG_DIR%\" (
  echo.%~nx0: error: config directory does not exist: "%__CONFIG_DIR%".
  exit /b 2
) >&2

if not exist "%__CONFIG_DIR%\%__CONFIG_FILE%" ^
if exist "%__CONFIG_DIR%\%__CONFIG_FILE%.in" (
  echo."%__CONFIG_DIR%\%__CONFIG_FILE%.in" -^> "%__CONFIG_DIR%\%__CONFIG_FILE%"
  type "%__CONFIG_DIR%\%__CONFIG_FILE%.in" > "%__CONFIG_DIR%\%__CONFIG_FILE%"
)

rem load configuration files
if exist "%__CONFIG_DIR%\%__CONFIG_FILE%" (
  for /F "usebackq eol=# tokens=* delims=" %%i in ("%__CONFIG_DIR%\%__CONFIG_FILE%") do (
    call set %%i
  )
) else (
  echo.%~nx0: error: config file is not found: "%__CONFIG_DIR%\%__CONFIG_FILE%".
  exit /b 3
) >&2

rem drop local variables
(
  set "__CONFIG_DIR="
  set "__CONFIG_FILE="
)

exit /b 0
