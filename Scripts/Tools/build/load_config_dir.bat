@echo off

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

rem script flags
set __?GEN_SYSTEM_CONFIG=0
set "__?BARE_SYSTEM_FLAGS="
set "__?BARE_USER_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-gen_system_config" (
    set __?GEN_SYSTEM_CONFIG=1
    set __?BARE_SYSTEM_FLAGS=%__?BARE_SYSTEM_FLAGS% -gen_config
  ) else if "%FLAG%" == "-gen_user_config" (
    set __?BARE_USER_FLAGS=%__?BARE_USER_FLAGS% -gen_config
  ) else if "%FLAG%" == "-gen_config" (
    rem ignore
  ) else (
    set __?BARE_SYSTEM_FLAGS=%__?BARE_SYSTEM_FLAGS% %FLAG%
    set __?BARE_USER_FLAGS=%__?BARE_USER_FLAGS% %FLAG%
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

call :MAIN %%1 %%2
set __?LASTERROR=%ERRORLEVEL%

(
  rem drop all locals
  for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set __? 2^>nul`) do set "%%i="

  exit /b %__?LASTERROR%
)

:MAIN
if %__?GEN_SYSTEM_CONFIG% EQU 0 (
  call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_SYSTEM_FLAGS%% "%%~1" "%%~1" "config.system.vars.in" || (
    echo.%__?~nx0%: error: `%~1/config.system.vars.in` is not loaded.
    exit /b 255
  ) >&2
) else (
  call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_SYSTEM_FLAGS%% "%%~1" "%%~2" "config.system.vars" || (
    echo.%__?~nx0%: error: `%~2/config.system.vars` is not loaded.
    exit /b 255
  ) >&2
)

set __?CONFIG_INDEX=0

:LOAD_CONFIG_LOOP
if not exist "%~1/config.%__?CONFIG_INDEX%.vars.in" goto LOAD_CONFIG_END
call :LOAD_CONFIG %%* || exit /b
set /A __?CONFIG_INDEX+=1
goto LOAD_CONFIG_LOOP

:LOAD_CONFIG
call :CMD "%%__?~dp0%%load_config.bat"%%__?BARE_USER_FLAGS%% "%%~1" "%%~2" "config.%%__?CONFIG_INDEX%%.vars" || (
  echo.%__?~nx0%: error: `%~2/config.%__?CONFIG_INDEX%.vars` is not loaded.
  exit /b 255
) >&2

:LOAD_CONFIG_END

exit /b 0

:CMD
echo ^>%*
(
  %*
)
exit /b
