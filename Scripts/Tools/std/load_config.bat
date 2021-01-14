@echo off

setlocal DISABLEDELAYEDEXPANSION

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

rem script flags
set __?FLAG_LITE_PARSE=0
set __?FLAG_NO_EXPAND=0
set __?FLAG_FULL_PARSE=0
set __?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-lite_parse" (
    set __?FLAG_LITE_PARSE=1
  ) else if "%FLAG%" == "-noexpand" (
    set __?FLAG_NO_EXPAND=1
  ) else if "%FLAG%" == "-full_parse" (
    set __?FLAG_FULL_PARSE=1
  ) else if "%FLAG%" == "-allow_not_known_class_as_var_name" (
    set __?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME=1
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
set "__?PARAM0=%~4"
set "__?PARAM1=%~5"

if not defined __?CONFIG_IN_DIR (
  echo.%?~nx0%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __?CONFIG_OUT_DIR (
  echo.%?~nx0%: error: output config directory is not defined.
  exit /b 2
) >&2

set "__?CONFIG_IN_DIR=%__?CONFIG_IN_DIR:\=/%"
set "__?CONFIG_OUT_DIR=%__?CONFIG_OUT_DIR:\=/%"

if "%__?CONFIG_IN_DIR:~-1%" == "/" set "__?CONFIG_IN_DIR=%__?CONFIG_IN_DIR:~0,-1%"
if "%__?CONFIG_OUT_DIR:~-1%" == "/" set "__?CONFIG_OUT_DIR=%__?CONFIG_OUT_DIR:~0,-1%"

if not exist "%__?CONFIG_IN_DIR%\" (
  echo.%?~nx0%: error: input config directory does not exist: "%__?CONFIG_IN_DIR%".
  exit /b 10
) >&2

if not exist "%__?CONFIG_OUT_DIR%\" (
  echo.%?~nx0%: error: output config directory does not exist: "%__?CONFIG_OUT_DIR%".
  exit /b 11
) >&2

if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%" ^
if exist "%__?CONFIG_IN_DIR%/%__?CONFIG_FILE%.in" (
  echo."%__?CONFIG_IN_DIR%/%__?CONFIG_FILE%.in" -^> "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%"
  type "%__?CONFIG_IN_DIR:/=\%\%__?CONFIG_FILE%.in" > "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%"
)

rem load configuration files
if not exist "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%" (
  echo.%?~nx0%: error: config file is not found: "%__?CONFIG_OUT_DIR%/%__?CONFIG_FILE%".
  exit /b 20
) >&2

if %__?FLAG_LITE_PARSE% NEQ 0 (
  "%__?~dp0%/.load_config/load_config.lite_parse.bat" "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%"
) else if %__?FLAG_FULL_PARSE% EQU 0 (
  "%__?~dp0%/.load_config/load_config.fast_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
) else "%__?~dp0%.load_config/load_config.full_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
