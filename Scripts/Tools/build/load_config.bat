@echo off

setlocal DISABLEDELAYEDEXPANSION

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

call "%%__?~dp0%%.load_config/load_config.read_flags.bat" %%* || exit /b

if %NO_GEN%0 NEQ 0 if %__?FLAG_GEN_CONFIG% NEQ 0 (
  echo.%__?~nx0%: error: can not generate config while NO_GEN is set.
  exit /b 255
) >&2

if %__?FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%__?FLAG_SHIFT%) do shift

set "__?CONFIG_IN_DIR=%~1"
set "__?CONFIG_OUT_DIR=%~2"
set "__?CONFIG_FILE=%~3"
set "__?PARAM0=%~4"
set "__?PARAM1=%~5"

if not defined __?CONFIG_IN_DIR (
  echo.%__?~nx0%: error: input config directory is not defined.
  exit /b 1
) >&2

if not defined __?CONFIG_OUT_DIR (
  echo.%__?~nx0%: error: output config directory is not defined.
  exit /b 2
) >&2

for /F "eol= tokens=* delims=" %%i in ("%__?CONFIG_IN_DIR%\.") do set "__?CONFIG_IN_DIR=%%~fi"
for /F "eol= tokens=* delims=" %%i in ("%__?CONFIG_OUT_DIR%\.") do set "__?CONFIG_OUT_DIR=%%~fi"

if not exist "%__?CONFIG_IN_DIR%\" (
  echo.%__?~nx0%: error: input config directory does not exist: "%__?CONFIG_IN_DIR%".
  exit /b 10
) >&2

if %__?FLAG_GEN_CONFIG% EQU 0 if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 goto SKIP_CONFIG_OUT_DIR_CHECK

if not exist "%__?CONFIG_OUT_DIR%\" (
  echo.%__?~nx0%: error: output config directory does not exist: "%__?CONFIG_OUT_DIR%".
  exit /b 11
) >&2

:SKIP_CONFIG_OUT_DIR_CHECK

set "__?CONFIG_FILE_DIR=%__?CONFIG_OUT_DIR%"
if %__?FLAG_GEN_CONFIG% EQU 0 ( if %__?FLAG_LOAD_OUTPUT_CONFIG% EQU 0 set "__?CONFIG_FILE_DIR=%__?CONFIG_IN_DIR%" )

if %NO_GEN%0 EQU 0 (
  if %__?FLAG_GEN_CONFIG% NEQ 0 (
    if not exist "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%" if exist "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" (
      echo."%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" -^> "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%"
      type "%__?CONFIG_IN_DIR%\%__?CONFIG_FILE%.in" > "%__?CONFIG_OUT_DIR%\%__?CONFIG_FILE%"
    )
  )
)

rem load configuration files
if not exist "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%" (
  echo.%__?~nx0%: error: config file is not found: "%__?CONFIG_FILE_DIR%\%__?CONFIG_FILE%".
  exit /b 20
) >&2

if %__?FLAG_LITE_PARSE% NEQ 0 (
  "%__?~dp0%/.load_config/load_config.lite_parse.bat" "%__?FLAG_NO_EXPAND%" "%__?PARAM0%" "%__?PARAM1%"
) else if %__?FLAG_FULL_PARSE% EQU 0 (
  "%__?~dp0%/.load_config/load_config.fast_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
) else "%__?~dp0%.load_config/load_config.full_parse.bat" %__?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME%
