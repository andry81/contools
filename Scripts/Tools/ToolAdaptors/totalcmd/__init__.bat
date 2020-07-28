@echo off

if /i "%TACKLEBAR_SCRIPTS_INIT0_DIR%" == "%~dp0" exit /b 0

set "TACKLEBAR_SCRIPTS_INIT0_DIR=%~dp0"

if not defined COMMANDER_SCRIPTS_ROOT (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT environment variable is not defined.
  exit /b 1
) >&2

if not exist "%COMMANDER_SCRIPTS_ROOT%\" (
  echo.%~nx0: error: COMMANDER_SCRIPTS_ROOT directory does not exist: "%COMMANDER_SCRIPTS_ROOT%".
  exit /b 2
) >&2

if %TACKLEBAR_SCRIPTS_INSTALL%0 EQU 0 (
  call :CANONICAL_PATH CONTOOLS_ROOT      "%%~dp0Tools"
)

call "%%~dp0__init__\__init__.bat" || exit /b

rem load configuration file if installed
if exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar\" ^
if exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar\profile.vars" (
  call "%%CONTOOLS_ROOT%%/std/load_config.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" "profile.vars" || exit /b
)

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
set "RETURN_VALUE=%~dpf2"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
if "%RETURN_VALUE:~-1%" == "/" set "RETURN_VALUE=%RETURN_VALUE:~0,-1%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
