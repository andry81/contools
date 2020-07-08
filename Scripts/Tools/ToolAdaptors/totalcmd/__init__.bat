@echo off

if /i "%TACKLEBAR_SCRIPTS_INIT0_DIR%" == "%~dp0" exit /b

set "TACKLEBAR_SCRIPTS_INIT0_DIR=%~dp0"

if not defined COMMANDER_SCRIPTS_ROOT (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT environment variable is not defined.
  exit /b 1
) >&2

if not exist "%COMMANDER_SCRIPTS_ROOT%\" (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT directory does not exist: "%COMMANDER_SCRIPTS_ROOT%".
  exit /b 2
) >&2

call "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar/Tools/std/load_config.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar/profile.vars" || exit /b

call "%%~dp0Tools\__init__.bat" || exit /b
