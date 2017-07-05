@echo off

if "%SCRIPT_TEMP_NEST_LVL%" == "" set SCRIPT_TEMP_NEST_LVL=0

if %SCRIPT_TEMP_NEST_LVL% GTR 0 (
  rem remove current dir
  rmdir /S /Q "%SCRIPT_TEMP_CURRENT_DIR%"

  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_CURRENT_TASK_NAME_LIST%") do (
    set "SCRIPT_TEMP_CURRENT_TASK_NAME=%%i"
    set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST=%%j"
  )
  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_CURRENT_DIR_LIST%") do (
    set "SCRIPT_TEMP_CURRENT_DIR=%%i"
    set "SCRIPT_TEMP_CURRENT_DIR_LIST=%%j"
  )
  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_BASE_DIR_LIST%") do (
    set "SCRIPT_TEMP_BASE_DIR=%%i"
    set "SCRIPT_TEMP_BASE_DIR_LIST=%%j"
  )
  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_PARENT_PATH_DIR_LIST%") do (
    set "SCRIPT_TEMP_PARENT_PATH_DIR=%%i"
    set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST=%%j"
  )
  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_DIR_NAME_PREFIX_LIST%") do (
    set "SCRIPT_TEMP_DIR_NAME_PREFIX=%%i"
    set "SCRIPT_TEMP_DIR_NAME_PREFIX_LIST=%%j"
  )
  for /F "eol=	 tokens=1,* delims=|" %%i in ("%SCRIPT_TEMP_TASK_COUNT_LIST%") do (
    set "SCRIPT_TEMP_TASK_COUNT=%%i"
    set "SCRIPT_TEMP_TASK_COUNT_LIST=%%j"
  )

  set /A SCRIPT_TEMP_NEST_LVL-=1
)

if %SCRIPT_TEMP_NEST_LVL% EQU 0 (
  rem remove root dir
  if exist "%SCRIPT_TEMP_ROOT_DIR%\" rmdir /S /Q "%SCRIPT_TEMP_ROOT_DIR%"

  set "SCRIPT_TEMP_CURRENT_TASK_NAME="
  set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST="
  set "SCRIPT_TEMP_CURRENT_DIR="
  set "SCRIPT_TEMP_CURRENT_DIR_LIST="
  set "SCRIPT_TEMP_BASE_DIR="
  set "SCRIPT_TEMP_BASE_DIR_LIST="
  set "SCRIPT_TEMP_PARENT_PATH_DIR="
  set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST="
  set "SCRIPT_TEMP_DIR_NAME_PREFIX="
  set "SCRIPT_TEMP_DIR_NAME_PREFIX_LIST="
  set "SCRIPT_TEMP_TASK_COUNT="
  set "SCRIPT_TEMP_TASK_COUNT_LIST="

  set "SCRIPT_TEMP_NEST_LVL="

  set "SCRIPT_TEMP_ROOT_DIR="
  set "SCRIPT_TEMP_ROOT_TIME="
  set "SCRIPT_TEMP_ROOT_DATE="
)

exit /b 0
