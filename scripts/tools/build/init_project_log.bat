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

call "%%~dp0__init__.bat" || exit /b

set "SUFFIX_NAME=%~1"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_ROOT SUFFIX_NAME || exit /b

if defined PROJECT_LOG_DIR exit /b 0
if defined PROJECT_LOG_FILE exit /b 0

rem use stdout/stderr redirection with logging
call "%%CONTOOLS_WMI_ROOT%%\get_wmi_local_datetime.vbs.bat"
set "PROJECT_LOG_FILE_NAME_DATE_TIME=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "PROJECT_LOG_DIR_NAME=%PROJECT_LOG_FILE_NAME_DATE_TIME%.%SUFFIX_NAME%"
set "PROJECT_LOG_DIR=%PROJECT_LOG_ROOT%\%PROJECT_LOG_DIR_NAME%"

set "PROJECT_LOG_FILE_NAME="
set "PROJECT_LOG_FILE="

if %NO_LOG_OUTPUT%0 NEQ 0 goto SKIP_LOG_OUTPUT

set "PROJECT_LOG_FILE_NAME=%PROJECT_LOG_FILE_NAME_DATE_TIME%.%SUFFIX_NAME%.log"
set "PROJECT_LOG_FILE=%PROJECT_LOG_DIR%\%PROJECT_LOG_FILE_NAME%"

:SKIP_LOG_OUTPUT

if %NO_LOG%0 EQU 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_LOG_DIR%%" || exit /b 255
)

(
  endlocal
  set "PROJECT_LOG_FILE_NAME_DATE_TIME=%PROJECT_LOG_FILE_NAME_DATE_TIME%"
  set "PROJECT_LOG_DIR_NAME=%PROJECT_LOG_DIR_NAME%"
  set "PROJECT_LOG_FILE_NAME=%PROJECT_LOG_FILE_NAME%"
  set "PROJECT_LOG_DIR=%PROJECT_LOG_DIR%"
  set "PROJECT_LOG_FILE=%PROJECT_LOG_FILE%"
  exit /b 0
)
