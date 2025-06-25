@echo off

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem cast to integer
set /A SCRIPT_TEMP_NEST_LVL+=0

if %SCRIPT_TEMP_NEST_LVL% EQU 0 goto NEST_LVL_0

for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_CURRENT_TASK_NAME_LIST%") do (
  set "SCRIPT_TEMP_CURRENT_TASK_NAME=%%i"
  set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST=%%j"
)
for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_CURRENT_DIR_LIST%") do (
  set "SCRIPT_TEMP_CURRENT_DIR=%%i"
  set "SCRIPT_TEMP_CURRENT_DIR_LIST=%%j"
)
for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_BASE_DIR_LIST%") do (
  set "SCRIPT_TEMP_BASE_DIR=%%i"
  set "SCRIPT_TEMP_BASE_DIR_LIST=%%j"
)
for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_PARENT_PATH_DIR_LIST%") do (
  set "SCRIPT_TEMP_PARENT_PATH_DIR=%%i"
  set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST=%%j"
)
for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_DIR_NAME_TOKEN_LIST%") do (
  set "SCRIPT_TEMP_DIR_NAME_TOKEN=%%i"
  set "SCRIPT_TEMP_DIR_NAME_TOKEN_LIST=%%j"
)
for /F "tokens=1,* delims=|"eol^= %%i in ("%SCRIPT_TEMP_TASK_COUNT_LIST%") do (
  set "SCRIPT_TEMP_TASK_COUNT=%%i"
  set "SCRIPT_TEMP_TASK_COUNT_LIST=%%j"
)

set /A SCRIPT_TEMP_NEST_LVL-=1

:NEST_LVL_0
rem remove \.\ occurrences
setlocal
set "SCRIPT_TEMP_PARENT_PATH_DIR_DECORATED=\%SCRIPT_TEMP_PARENT_PATH_DIR%\"
set "SCRIPT_TEMP_PARENT_PATH_DIR_DECORATED=%SCRIPT_TEMP_PARENT_PATH_DIR_DECORATED:\.\=\%"
endlocal & set "SCRIPT_TEMP_PARENT_PATH_DIR=%SCRIPT_TEMP_PARENT_PATH_DIR_DECORATED:~1,-1%"

if not defined SCRIPT_TEMP_PARENT_PATH_DIR (
  rem remove current dir
  if exist "\\?\%SCRIPT_TEMP_CURRENT_DIR%\*" rmdir /S /Q "%SCRIPT_TEMP_CURRENT_DIR%"
  goto IGNORE_REMOVE_PARENT_PATH
)

set "SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX=%SCRIPT_TEMP_TASK_COUNT%"
if "%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX:~1,1%" == "" set "SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX=0%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%"

rem echo =%SCRIPT_TEMP_BASE_DIR%=%SCRIPT_TEMP_PARENT_PATH_DIR%%SCRIPT_TEMP_DIR_NAME_TOKEN%.%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%=

rem remove parent directory
for /F "tokens=1,* delims=\"eol^= %%i in ("%SCRIPT_TEMP_PARENT_PATH_DIR%%SCRIPT_TEMP_DIR_NAME_TOKEN%.%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%") do (
  if exist "\\?\%SCRIPT_TEMP_BASE_DIR%\%%i\*" rmdir /S /Q "%SCRIPT_TEMP_BASE_DIR%\%%i" || (
    echo;%?~%: error: could not free temporary directory: "%SCRIPT_TEMP_BASE_DIR%\%%i".
    echo;
  ) >&2
)

:IGNORE_REMOVE_PARENT_PATH
if %SCRIPT_TEMP_NEST_LVL% NEQ 0 exit /b 0

set "SCRIPT_TEMP_CURRENT_TASK_NAME="
set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST="
set "SCRIPT_TEMP_CURRENT_DIR="
set "SCRIPT_TEMP_CURRENT_DIR_LIST="
set "SCRIPT_TEMP_BASE_DIR="
set "SCRIPT_TEMP_BASE_DIR_LIST="
set "SCRIPT_TEMP_PARENT_PATH_DIR="
set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST="
set "SCRIPT_TEMP_DIR_NAME_TOKEN="
set "SCRIPT_TEMP_DIR_NAME_TOKEN_LIST="
set "SCRIPT_TEMP_TASK_COUNT="
set "SCRIPT_TEMP_TASK_COUNT_LIST="

set "SCRIPT_TEMP_NEST_LVL="

set "SCRIPT_TEMP_ROOT_DIR="
set "SCRIPT_TEMP_ROOT_TIME="
set "SCRIPT_TEMP_ROOT_DATE="

exit /b 0
