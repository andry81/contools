@echo off

call "%%~dp0..\__init__.bat" || exit /b

if /i "%DOWNLOAD_SCRIPTS_INIT0_DIR%" == "%~dp0" exit /b

set "DOWNLOAD_SCRIPTS_INIT0_DIR=%~dp0"

if defined CONFIGURE_DIR goto IGNORE_CONFIGURE_DIR

set "CONFIGURE_DIR=%~dp0"
set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

:IGNORE_CONFIGURE_DIR
if not defined CONTOOLS_ROOT set "CONTOOLS_ROOT=%CONFIGURE_DIR%\tools"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%\std\load_config.bat" "%%CONFIGURE_DIR%%" "config.vars" || (
  echo.%~nx0: error: config.vars is not loaded.
  exit /b 255
) >&2

exit /b 0
