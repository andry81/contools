
rem script flags
set __?FLAG_SHIFT=0
set __?FLAG_GEN_CONFIG=0
set __?FLAG_LOAD_OUTPUT_CONFIG=0
set __?FLAG_LITE_PARSE=0
set __?FLAG_NO_EXPAND=0
set __?FLAG_FULL_PARSE=0
set __?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME=0

:FLAGS_LOOP

rem flags always at first
set "__?FLAG=%~1"

if defined __?FLAG ^
if not "%__?FLAG:~0,1%" == "-" set "__?FLAG="

if defined __?FLAG (
  if "%__?FLAG%" == "-gen_config" (
    set __?FLAG_GEN_CONFIG=1
  ) else if "%__?FLAG%" == "-load_output_config" (
    set __?FLAG_LOAD_OUTPUT_CONFIG=1
  ) else if "%__?FLAG%" == "-lite_parse" (
    set __?FLAG_LITE_PARSE=1
  ) else if "%__?FLAG%" == "-noexpand" (
    set __?FLAG_NO_EXPAND=1
  ) else if "%__?FLAG%" == "-full_parse" (
    set __?FLAG_FULL_PARSE=1
  ) else if "%__?FLAG%" == "-allow_not_known_class_as_var_name" (
    set __?FLAG_ALLOW_NOT_KNOWN_CLASS_AS_VAR_NAME=1
  ) else (
    echo.%__?~nx0%: error: invalid flag: %__?FLAG%
    exit /b -255
  ) >&2

  shift
  set /A __?FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)
