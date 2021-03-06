@echo off

if /i "%DOWNLOAD_TOOLS_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0__init__.bat" || exit /b

set "DOWNLOAD_TOOLS_ROOT_INIT0_DIR=%~dp0"

for %%i in (CONTOOLS_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call :CANONICAL_PATH CONFIGURE_DIR        "%%~dp0"
call :CANONICAL_PATH DOWNLOAD_TOOLS_ROOT  "%%CONFIGURE_DIR%%"

call "%%CONTOOLS_ROOT%%\std\load_config.bat" "%%CONFIGURE_DIR%%" "config.vars" || (
  echo.%~nx0: error: config.vars is not loaded.
  exit /b 255
) >&2

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
