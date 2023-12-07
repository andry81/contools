@echo off

setlocal

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

if %NO_GEN%0 NEQ 0 exit /b 0
if %NO_LOG%0 NEQ 0 exit /b 0

set "SUFFIX_NAME=%~1"

for %%i in (CONTOOLS_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

if defined PROJECT_LOG_DIR exit /b 0
if defined PROJECT_LOG_FILE exit /b 0

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_WMI_ROOT%%\get_wmic_local_datetime.bat"
set "PROJECT_LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "PROJECT_LOG_DIR_NAME=%PROJECT_LOG_FILE_NAME_SUFFIX%.%SUFFIX_NAME%"
set "PROJECT_LOG_DIR=%PROJECT_LOG_ROOT%\%PROJECT_LOG_DIR_NAME%"

set "PROJECT_LOG_FILE_NAME="
set "PROJECT_LOG_FILE="

if %NO_LOG_OUTPUT%0 NEQ 0 goto SKIP_LOG_OUTPUT

set "PROJECT_LOG_FILE_NAME=%PROJECT_LOG_FILE_NAME_SUFFIX%.%SUFFIX_NAME%.log"
set "PROJECT_LOG_FILE=%PROJECT_LOG_DIR%\%PROJECT_LOG_FILE_NAME%"

:SKIP_LOG_OUTPUT

if %NO_LOG%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%PROJECT_LOG_DIR%%" || exit /b 255
)

(
  endlocal
  set "PROJECT_LOG_FILE_NAME_SUFFIX=%PROJECT_LOG_FILE_NAME_SUFFIX%"
  set "PROJECT_LOG_DIR_NAME=%PROJECT_LOG_DIR_NAME%"
  set "PROJECT_LOG_FILE_NAME=%PROJECT_LOG_FILE_NAME%"
  set "PROJECT_LOG_DIR=%PROJECT_LOG_DIR%"
  set "PROJECT_LOG_FILE=%PROJECT_LOG_FILE%"
  exit /b 0
)
