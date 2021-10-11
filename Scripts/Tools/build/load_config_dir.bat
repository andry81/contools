@echo off

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

rem script flags
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

  rem read until no flags
  goto FLAGS_LOOP
)

if %__?FLAG_LOAD_SYSTEM_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_SYSTEM_CONFIG% EQU 0 set "__?SYSTEM_CONFIG_FILE_EXT=.in"
if %__?FLAG_LOAD_USER_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_USER_CONFIG% EQU 0 set "__?USER_CONFIG_FILE_EXT=.in"

call :MAIN %%1 %%2 %%3 %%4
set __?LASTERROR=%ERRORLEVEL%

(
  rem drop all locals
  for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set __? 2^>nul`) do set "%%i="

  exit /b %__?LASTERROR%
)

:MAIN
call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_SYSTEM_FLAGS%% %%1 %%2 "config.system.vars%%__?SYSTEM_CONFIG_FILE_EXT%%" %%3 %%4 || exit /b

set __?CONFIG_INDEX=0

:LOAD_CONFIG_LOOP
if not exist "%~1/config.%__?CONFIG_INDEX%.vars.in" goto LOAD_CONFIG_END
call :LOAD_CONFIG %%* || exit /b
set /A __?CONFIG_INDEX+=1
goto LOAD_CONFIG_LOOP

:LOAD_CONFIG
call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_USER_FLAGS%% %%1 %%2 "config.%%__?CONFIG_INDEX%%.vars%%__?USER_CONFIG_FILE_EXT%%" %%3 %%4 || exit /b

:LOAD_CONFIG_END

exit /b 0

:CMD
if %LOAD_CONFIG_VERBOSE%0 NEQ 0 echo ^>%*
(
  %*
)
exit /b
