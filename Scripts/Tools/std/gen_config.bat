@echo off

setlocal

set "CONFIG_IN_DIR=%~1"
set "CONFIG_OUT_DIR=%~2"
set "CONFIG_FILE=%~3"

if not defined CONFIG_IN_DIR (
  echo.%~nx0: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined CONFIG_OUT_DIR (
  echo.%~nx0: error: output config directory is not defined.
  exit /b 2
) >&2

set "CONFIG_IN_DIR=%CONFIG_IN_DIR:\=/%"
set "CONFIG_OUT_DIR=%CONFIG_OUT_DIR:\=/%"

if "%CONFIG_IN_DIR:~-1%" == "/" set "CONFIG_IN_DIR=%CONFIG_IN_DIR:~0,-1%"
if "%CONFIG_OUT_DIR:~-1%" == "/" set "CONFIG_OUT_DIR=%CONFIG_OUT_DIR:~0,-1%"

if not exist "%CONFIG_IN_DIR%\" (
  echo.%~nx0: error: input config directory does not exist: "%CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%CONFIG_OUT_DIR%\" (
  echo.%~nx0: error: output config directory does not exist: "%CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if not exist "%CONFIG_OUT_DIR%\%CONFIG_FILE%" ^
if exist "%CONFIG_IN_DIR%/%CONFIG_FILE%.in" (
  echo."%CONFIG_IN_DIR%/%CONFIG_FILE%.in" -^> "%CONFIG_OUT_DIR%/%CONFIG_FILE%"
  type "%CONFIG_IN_DIR:/=\%\%CONFIG_FILE%.in" > "%CONFIG_OUT_DIR%/%CONFIG_FILE%"
)
