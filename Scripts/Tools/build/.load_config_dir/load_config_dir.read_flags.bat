
rem script flags
set __?FLAG_SHIFT=0
set __?FLAG_GEN_SYSTEM_CONFIG=0
set __?FLAG_GEN_USER_CONFIG=0
set __?FLAG_LOAD_SYSTEM_OUTPUT_CONFIG=0
set __?FLAG_LOAD_USER_OUTPUT_CONFIG=0
set "__?BARE_SYSTEM_FLAGS="
set "__?BARE_USER_FLAGS="

set "__?SYSTEM_CONFIG_FILE_EXT="
set "__?USER_CONFIG_FILE_EXT="

:FLAGS_LOOP

rem flags always at first
set "__?FLAG=%~1"

if defined __?FLAG ^
if not "%__?FLAG:~0,1%" == "-" set "__?FLAG="

if defined __?FLAG (
  if "%__?FLAG%" == "-gen_system_config" (
    set __?FLAG_GEN_SYSTEM_CONFIG=1
    set __?BARE_SYSTEM_FLAGS=%__?BARE_SYSTEM_FLAGS% -gen_config
  ) else if "%__?FLAG%" == "-gen_user_config" (
    set __?FLAG_GEN_USER_CONFIG=1
    set __?BARE_USER_FLAGS=%__?BARE_USER_FLAGS% -gen_config
  ) else if "%__?FLAG%" == "-load_system_output_config" (
    set __?FLAG_LOAD_SYSTEM_OUTPUT_CONFIG=1
    set __?BARE_SYSTEM_FLAGS=%__?BARE_SYSTEM_FLAGS% -load_output_config
  ) else if "%__?FLAG%" == "-load_user_output_config" (
    set __?FLAG_LOAD_USER_OUTPUT_CONFIG=1
    set __?BARE_USER_FLAGS=%__?BARE_USER_FLAGS% -load_output_config
  ) else if "%__?FLAG%" == "-gen_config" (
    rem ignore
  ) else (
    set __?BARE_SYSTEM_FLAGS=%__?BARE_SYSTEM_FLAGS% %__?FLAG%
    set __?BARE_USER_FLAGS=%__?BARE_USER_FLAGS% %__?FLAG%
  )

  shift
  set /A __?FLAG_SHIFT+=1

  rem read until no flags
  goto FLAGS_LOOP
)