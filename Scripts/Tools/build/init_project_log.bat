@echo off

setlocal

set "SUFFIX_NAME=%~1"

for %%i in (CONTOOLS_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_ROOT%%\wmi\get_wmic_local_datetime.bat"
set "PROJECT_LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "PROJECT_LOG_DIR=%PROJECT_LOG_ROOT%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%SUFFIX_NAME%"
set "PROJECT_LOG_FILE=%PROJECT_LOG_DIR%\%PROJECT_LOG_FILE_NAME_SUFFIX%.%SUFFIX_NAME%.log"

if not exist "%PROJECT_LOG_DIR%" ( mkdir "%PROJECT_LOG_DIR%" || exit /b )

(
  endlocal
  set "PROJECT_LOG_FILE_NAME_SUFFIX=%PROJECT_LOG_FILE_NAME_SUFFIX%"
  set "PROJECT_LOG_DIR=%PROJECT_LOG_DIR%"
  set "PROJECT_LOG_FILE=%PROJECT_LOG_FILE%"
  exit /b 0
)