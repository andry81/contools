@echo off

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

call "%%__?~dp0%%.load_config_dir/load_config_dir.read_flags.bat" %%* || exit /b

if %__?FLAG_SHIFT% GTR 0 for /L %%i in (1,1,%__?FLAG_SHIFT%) do shift

if %__?FLAG_LOAD_SYSTEM_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_SYSTEM_CONFIG% EQU 0 set "__?SYSTEM_CONFIG_FILE_EXT=.in"
if %__?FLAG_LOAD_USER_OUTPUT_CONFIG% EQU 0 if %__?FLAG_GEN_USER_CONFIG% EQU 0 set "__?USER_CONFIG_FILE_EXT=.in"

if "%~2" == "" (
  call :MAIN "%%~1" "%%~1" "%%~3" "%%~4"
) else call :MAIN "%%~1" "%%~2" "%%~3" "%%~4"
set __?LASTERROR=%ERRORLEVEL%

call "%%__?~dp0%%.load_config_dir/load_config_dir.exit.bat"
exit /b

:MAIN
call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_SYSTEM_FLAGS%% %%1 %%2 "config.system.vars%%__?SYSTEM_CONFIG_FILE_EXT%%" %%3 %%4 || exit /b

if %__?FLAG_NO_LOAD_USER_CONFIG% NEQ 0 goto LOAD_CONFIG_END

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
