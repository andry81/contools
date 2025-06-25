@echo off

setlocal

set "INIT_VARS_FILE_NAME=%~1"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

set "INIT_VARS_FILE="

if %NO_GEN%0 NEQ 0 exit /b 0
if %NO_LOG%0 NEQ 0 exit /b 0

if defined PROJECT_LOG_DIR if exist "%PROJECT_LOG_DIR%\*" goto USE_INIT_VARS

(
  echo;%?~%%: error: can not use environment variables initialization file while PROJECT_LOG_DIR does not exist: "%PROJECT_LOG_DIR%".
  exit /b 255
) >&2

:USE_INIT_VARS

if not defined INIT_VARS_FILE_NAME set "INIT_VARS_FILE_NAME=init.vars"

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\%INIT_VARS_FILE_NAME%"

if exist "%INIT_VARS_FILE%" (
  echo;%?~%: error: environment variables initialization file already exists: "%INIT_VARS_FILE%".
  exit /b 255
) >&2

(
  endlocal

  set "INIT_VARS_FILE=%INIT_VARS_FILE%"
  set "INIT_VARS_FILE_NAME=%INIT_VARS_FILE_NAME%"

  rem register all environment variables
  set; 2>nul > "%INIT_VARS_FILE%"

  exit /b 0
)
