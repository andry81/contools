@echo off & goto DOC_END

rem USAGE:
rem   load_config_dir.bat [<Flags>] [--] <InputDir> <OutputDir> [<Param0> [<Param1>]]

rem Description:
rem   Script to load input and output directory with configuration files using
rem   the `load_Config.bat` script.
rem
rem   A directory can contain a set of configuration files which loads in this
rem   order if exist:
rem     * config.system.vars[.in]
rem     * config.0.vars[.in]
rem     * ...
rem     * config.N.vars[.in]
rem
rem   The `.in` suffix basically related to the configuration files in the
rem   input directory.
rem   By default the script does load the system and the user configuration
rem   files from the input directory.
rem
rem   NOTE:
rem     All the rest description is in the `load_config.bat` script.

rem <Flags>:
rem   -gen_system_config
rem     Generates the system configuration file.
rem     Implies `-load_system_output_config` flag.
rem     Has no effect if `-no_load_system_config` flag is used.
rem
rem   -gen_user_config
rem     Generates the user configuration file.
rem     Implies `-load_user_output_config` flag.
rem     Has no effect if `-no_load_user_config` flag is used.
rem
rem   -load_system_output_config
rem     Loads the system configuration file from output directory.
rem     Has no effect if `-no_load_system_config` flag is used.
rem
rem   -load_user_output_config
rem     Loads the user configuration file(s) from output directory.
rem     Has no effect if `-no_load_user_config` flag is used.
rem
rem   -no_load_system_config
rem     Skips load the system configuration file.
rem     Has priority over `-gen_system_config` and `-load_system_output_config`
rem     flags.
rem
rem   -no_load_user_config
rem     Skips load the user configuration file(s).
rem     Has priority over `-gen_user_config` and `-load_user_output_config`
rem     flags.

rem --:
rem   Separator to stop parse flags.

rem <InputDir>:
rem   Input configuration file directory.
rem   Must be not empty and exist.

rem <OutputDir>:
rem   Output configuration file directory.
rem   Can be empty, then `<InputDir>` is used instead.

rem NOTE:
rem   All the rest parameters is in the `load_config.bat` script.
:DOC_END

set "__?~dp0=%~dp0"

rem script names call stack
if defined ?~ ( set "__?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "__?~=%?~nx0%-^>%~nx0" ) else set "__?~=%~nx0"

if defined NO_GEN set /A NO_GEN+=0

call "%%__?~dp0%%.load_config_dir/load_config_dir.read_flags.bat" %%* || exit /b

if %__?FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%__?FLAG_SHIFT%) do shift

if %NO_GEN%0 NEQ 0 (
  if %__?FLAG_GEN_SYSTEM_CONFIG% NEQ 0 (
    echo;%__?~%: error: can not generate system config while NO_GEN is set.
    exit /b 255
  ) >&2
  if %__?FLAG_GEN_USER_CONFIG% NEQ 0 (
    echo;%__?~%: error: can not generate user config while NO_GEN is set.
    exit /b 255
  ) >&2
)

set __?LOAD_USER_CONFIG_IN=0
set "__?SYSTEM_CONFIG_FILE_EXT="
set "__?USER_CONFIG_FILE_EXT="

if %__?FLAG_LOAD_SYSTEM_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_SYSTEM_CONFIG% EQU 0 set "__?SYSTEM_CONFIG_FILE_EXT=.in"
if %__?FLAG_LOAD_USER_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_USER_CONFIG% EQU 0 (
  set __?LOAD_USER_CONFIG_IN=1
  set "__?USER_CONFIG_FILE_EXT=.in"
)

if "%~2" == "" (
  call :MAIN "%%~1" "%%~1" "%%~3" "%%~4"
) else call :MAIN "%%~1" "%%~2" "%%~3" "%%~4"
set __?LAST_ERROR=%ERRORLEVEL%

rem drop all locals
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set __? 2^>nul`) do set "%%i="
exit /b

:MAIN
if %__?FLAG_NO_LOAD_SYSTEM_CONFIG% NEQ 0 goto LOAD_SYSTEM_CONFIG_END

call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_SYSTEM_FLAGS%% -- %%1 %%2 "config.system.vars%%__?SYSTEM_CONFIG_FILE_EXT%%" %%3 %%4 || exit /b

:LOAD_SYSTEM_CONFIG_END

if %__?FLAG_NO_LOAD_USER_CONFIG% NEQ 0 goto LOAD_USER_CONFIG_END

set __?CONFIG_INDEX=0

rem CAUTION:
rem   We must stop loading only when both input and output user config does not exist.
rem

:LOAD_CONFIG_LOOP
if %__?LOAD_USER_CONFIG_IN% NEQ 0 (
  if not exist "%~1/config.%__?CONFIG_INDEX%.vars%__?USER_CONFIG_FILE_EXT%" if not exist "%~1/config.%__?CONFIG_INDEX%.vars.in" goto LOAD_USER_CONFIG_END
) else if not exist "%~2/config.%__?CONFIG_INDEX%.vars%__?USER_CONFIG_FILE_EXT%" if not exist "%~1/config.%__?CONFIG_INDEX%.vars.in" goto LOAD_USER_CONFIG_END

call :LOAD_CONFIG %%* || exit /b

set /A __?CONFIG_INDEX+=1

goto LOAD_CONFIG_LOOP

:LOAD_CONFIG
call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_USER_FLAGS%% -- %%1 %%2 "config.%%__?CONFIG_INDEX%%.vars%%__?USER_CONFIG_FILE_EXT%%" %%3 %%4 || exit /b

:LOAD_USER_CONFIG_END

exit /b 0

:CMD
if %LOAD_CONFIG_VERBOSE%0 NEQ 0 echo ^>%*
(
  %*
)
exit /b
