@echo off

if %__TACKLEBAR_INIT__%0 NEQ 0 exit /b 0

if not defined COMMANDER_SCRIPTS_ROOT (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT environment variable is not defined
  exit /b 1
) >&2

if not exist "%COMMANDER_SCRIPTS_ROOT%\" (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT directory does not exist: "%COMMANDER_SCRIPTS_ROOT%"
  exit /b 2
) >&2

call "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar/loadvars.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar/profile.vars" || exit /b

call "%%~dp0Tools\__init__.bat" || exit /b

set __TACKLEBAR_INIT__=1
