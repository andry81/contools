@echo off

setlocal

set "BUILD_CONFIG_ROOT=%~1"
set "BUILD_SCRIPTS_ROOT=%~2"
set "BUILD_USER_VARS_ROOT=%~3"

if defined BUILD_CONFIG_ROOT (
  if "\" == "%BUILD_CONFIG_ROOT:~0,1%" exit /b 1
  if "\" == "%BUILD_CONFIG_ROOT:~-1%" set "BUILD_CONFIG_ROOT=%BUILD_CONFIG_ROOT:~0,-1%"
)

if not defined BUILD_CONFIG_ROOT (
  echo.%~nx0: error: BUILD_CONFIG_ROOT must be defined.
  exit /b 1
) >&2

if defined BUILD_SCRIPTS_ROOT (
  if "\" == "%BUILD_SCRIPTS_ROOT:~0,1%" exit /b 2
  if "\" == "%BUILD_SCRIPTS_ROOT:~-1%" set "BUILD_SCRIPTS_ROOT=%BUILD_SCRIPTS_ROOT:~0,-1%"
)

if not defined BUILD_SCRIPTS_ROOT (
  echo.%~nx0: error: BUILD_SCRIPTS_ROOT must be defined.
  exit /b 2
) >&2

if defined BUILD_USER_VARS_ROOT (
  if "\" == "%BUILD_USER_VARS_ROOT:~0,1%" exit /b 3
  if "\" == "%BUILD_USER_VARS_ROOT:~-1%" set "BUILD_USER_VARS_ROOT=%BUILD_USER_VARS_ROOT:~0,-1%"
)

if not defined PROJECT_NAME (
  echo.%~nx0: error: PROJECT_NAME must be defined.
  exit /b 3
) >&2

if not defined APP_SETUP_FILE_NAME (
  echo.%~nx0: error: APP_SETUP_FILE_NAME must be defined.
  exit /b 4
) >&2

rem cleanup all STAGE_IN.PROJECT_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "STAGE_IN.PROJECT_" 2^>nul`) do set "%%i="

call :CANONICAL_PATH PROJECT_ROOT "%%PROJECT_ROOT%%"
set "PROJECT_ROOT=%PROJECT_ROOT:/=\%"

call :CANONICAL_PATH APP_ROOT "%%APP_ROOT%%"
set "APP_ROOT=%APP_ROOT:/=\%"

call :CANONICAL_PATH APP_INTEGRATION_ROOT "%%APP_INTEGRATION_ROOT%%"
set "APP_INTEGRATION_ROOT=%APP_INTEGRATION_ROOT:/=\%"

if not defined PROJECT_ROOT goto :NO_PROJECT_ROOT
if not exist "%PROJECT_ROOT%" goto :NO_PROJECT_ROOT
goto PROJECT_ROOT_END

:NO_PROJECT_ROOT
echo.%~nx0: PROJECT_ROOT does not exist or not defined: "%PROJECT_ROOT%">&2
exit /b 10

:PROJECT_ROOT_END

if not defined APP_TARGET_NAME goto :NO_APP_TARGET_NAME
goto APP_TARGET_NAME_END

:NO_APP_TARGET_NAME
echo.%~nx0: APP_TARGET_NAME is not defined: "%APP_TARGET_NAME%">&2
exit /b 11

:APP_TARGET_NAME_END

if "%PROJECT_TYPE%" == "debug" (
  set "NSIS_EXTRA_FLAGS=/DDEBUG"
) else (
  set "NSIS_EXTRA_FLAGS="
)

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
