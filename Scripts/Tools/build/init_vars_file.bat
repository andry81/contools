@echo off

setlocal

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

set "INIT_VARS_FILE="

if %NO_GEN%0 NEQ 0 exit /b 0
if %NO_LOG%0 NEQ 0 exit /b 0

if defined PROJECT_LOG_DIR if exist "%PROJECT_LOG_DIR%\*" goto USE_INIT_VARS

(
  echo.%~nx0%: error: can not use initial variables file while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

:USE_INIT_VARS

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

(
  endlocal

  set "INIT_VARS_FILE=%INIT_VARS_FILE%"

  rem register all environment variables
  set 2>nul > "%INIT_VARS_FILE%"

  exit /b 0
)
