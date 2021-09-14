@echo off

set "__?~dp0=%~dp0"
set "__?~n0=%~n0"
set "__?~nx0=%~nx0"

rem script flags
set "__?BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  set __?BARE_FLAGS=%__?BARE_FLAGS% %FLAG%

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

call :MAIN %%1 %%2

rem drop all locals
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set __? 2^>nul`) do set "%%i="

exit /b 0

:MAIN
set __?CONFIG_INDEX=system
call :LOAD_CONFIG %%* || exit /b

set __?CONFIG_INDEX=0

:LOAD_CONFIG_LOOP
if not exist "%~1/config.%__?CONFIG_INDEX%.vars.in" goto LOAD_CONFIG_END
call :LOAD_CONFIG %%* || exit /b
set /A __?CONFIG_INDEX+=1
goto LOAD_CONFIG_LOOP

:LOAD_CONFIG
call echo "%%__?~dp0%%load_config.bat"%%__?BARE_FLAGS%% "%%~1" "%%~2" "config.%__?CONFIG_INDEX%%.vars"
call "%%__?~dp0%%load_config.bat"%%__?BARE_FLAGS%% "%%~1" "%%~2" "config.%__?CONFIG_INDEX%%.vars"
if %ERRORLEVEL% NEQ 0 (
  echo.%__?~nx0%: error: `%~2/config.%__?CONFIG_INDEX%.vars` is not loaded.
  exit /b 255
) >&2

:LOAD_CONFIG_END

exit /b 0
