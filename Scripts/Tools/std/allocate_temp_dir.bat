@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "TASK_NAME=%~1"
set "TEMP_DIR_NAME_TOKEN=%~2"
set "TEMP_PARENT_PATH=%~3"
set "TEMP_BASE_PATH=%~4"

rem default values
if not defined TASK_NAME set TASK_NAME=.
if not defined TEMP_PARENT_PATH set TEMP_PARENT_PATH=.
if not defined TEMP_BASE_PATH set "TEMP_BASE_PATH=%TEMP%"

set "TEMP_PARENT_PATH_DIR="
if defined TEMP_PARENT_PATH set "TEMP_PARENT_PATH_DIR=%TEMP_PARENT_PATH%\"

set "TEMP_PARENT_PATH=%TEMP_PARENT_PATH:/=\%"
set "TEMP_BASE_PATH=%TEMP_BASE_PATH:/=\%"

if not defined SCRIPT_TEMP_NEST_LVL set SCRIPT_TEMP_NEST_LVL=0

if %SCRIPT_TEMP_NEST_LVL% NEQ 0 if defined SCRIPT_TEMP_CURRENT_DIR if exist "\\?\%SCRIPT_TEMP_CURRENT_DIR%\*" goto ALLOC_NESTED_TEMP

set "SCRIPT_TEMP_CURRENT_TASK_NAME=%TASK_NAME%"

call "%%CONTOOLS_WMI_ROOT%%\get_wmic_local_datetime.bat"
set "SCRIPT_TEMP_ROOT_DATE=%RETURN_VALUE:~0,4%'%RETURN_VALUE:~4,2%'%RETURN_VALUE:~6,2%"
set "SCRIPT_TEMP_ROOT_TIME=%RETURN_VALUE:~8,2%'%RETURN_VALUE:~10,2%'%RETURN_VALUE:~12,2%''%RETURN_VALUE:~15,3%"

set "SCRIPT_TEMP_BASE_DIR_LIST=%TEMP_BASE_PATH%|%SCRIPT_TEMP_BASE_DIR_LIST%"

if not defined TEMP_DIR_NAME_TOKEN set TEMP_DIR_NAME_TOKEN=undefined

set "SCRIPT_TEMP_DIR_NAME=%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%.%TEMP_DIR_NAME_TOKEN%"
set "SCRIPT_TEMP_ROOT_DIR=%TEMP_BASE_PATH%\%TEMP_PARENT_PATH_DIR%%SCRIPT_TEMP_DIR_NAME%"

rem make absolute path
for /F "eol= tokens=* delims=" %%i in ("%SCRIPT_TEMP_ROOT_DIR%\.") do set "SCRIPT_TEMP_ROOT_DIR=%%~fi"

set "SCRIPT_TEMP_BASE_DIR=%SCRIPT_TEMP_ROOT_DIR%"
set "SCRIPT_TEMP_CURRENT_DIR=%SCRIPT_TEMP_BASE_DIR%"

set SCRIPT_TEMP_TASK_COUNT=0
set /A SCRIPT_TEMP_NEST_LVL+=1

set "SCRIPT_TEMP_TASK_COUNT_LIST=%SCRIPT_TEMP_TASK_COUNT%|%SCRIPT_TEMP_TASK_COUNT_LIST%"

goto ALLOC_NESTED_TEMP_END

:ALLOC_NESTED_TEMP
if "%SCRIPT_TEMP_CURRENT_TASK_NAME%" == "%TASK_NAME%" goto INCREMENT_TASK_COUNT

set "SCRIPT_TEMP_BASE_DIR=%SCRIPT_TEMP_CURRENT_DIR%"

:INCREMENT_TASK_COUNT
set "SCRIPT_TEMP_BASE_DIR_LIST=%SCRIPT_TEMP_BASE_DIR%|%SCRIPT_TEMP_BASE_DIR_LIST%"

set /A SCRIPT_TEMP_NEST_LVL+=1

set "SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX=%SCRIPT_TEMP_TASK_COUNT%"
if "%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX:~1,1%" == "" set "SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX=0%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%"

set "SCRIPT_TEMP_CURRENT_DIR=%SCRIPT_TEMP_BASE_DIR%\%TEMP_PARENT_PATH_DIR%%TEMP_DIR_NAME_TOKEN%.%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%"

set "SCRIPT_TEMP_TASK_COUNT_LIST=%SCRIPT_TEMP_TASK_COUNT%|%SCRIPT_TEMP_TASK_COUNT_LIST%"
set /A SCRIPT_TEMP_TASK_COUNT+=1

:ALLOC_NESTED_TEMP_END
rem echo --%SCRIPT_TEMP_BASE_DIR%--%TEMP_PARENT_PATH_DIR%%TEMP_DIR_NAME_TOKEN%.%SCRIPT_TEMP_TASK_COUNT_FILE_SUFFIX%--

set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST=%SCRIPT_TEMP_CURRENT_TASK_NAME%|%SCRIPT_TEMP_CURRENT_TASK_NAME_LIST%"
set "SCRIPT_TEMP_CURRENT_DIR_LIST=%SCRIPT_TEMP_CURRENT_DIR%|%SCRIPT_TEMP_CURRENT_DIR_LIST%"
set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST=%TEMP_PARENT_PATH_DIR%|%SCRIPT_TEMP_PARENT_PATH_DIR_LIST%"
set "SCRIPT_TEMP_DIR_NAME_TOKEN_LIST=%TEMP_DIR_NAME_TOKEN%|%SCRIPT_TEMP_DIR_NAME_TOKEN_LIST%"

mkdir "%SCRIPT_TEMP_CURRENT_DIR%"
set LASTERROR=%ERRORLEVEL%

rem return values
(
  endlocal
  set "SCRIPT_TEMP_CURRENT_TASK_NAME=%SCRIPT_TEMP_CURRENT_TASK_NAME%"
  set "SCRIPT_TEMP_NEST_LVL=%SCRIPT_TEMP_NEST_LVL%"
  set "SCRIPT_TEMP_ROOT_DATE=%SCRIPT_TEMP_ROOT_DATE%"
  set "SCRIPT_TEMP_ROOT_TIME=%SCRIPT_TEMP_ROOT_TIME%"
  set "SCRIPT_TEMP_ROOT_DIR=%SCRIPT_TEMP_ROOT_DIR%"
  set "SCRIPT_TEMP_DIR_NAME=%SCRIPT_TEMP_DIR_NAME%"
  set "SCRIPT_TEMP_BASE_DIR=%SCRIPT_TEMP_BASE_DIR%"
  set "SCRIPT_TEMP_CURRENT_DIR=%SCRIPT_TEMP_CURRENT_DIR%"
  set "SCRIPT_TEMP_TASK_COUNT=%SCRIPT_TEMP_TASK_COUNT%"

  set "SCRIPT_TEMP_CURRENT_TASK_NAME_LIST=%SCRIPT_TEMP_CURRENT_TASK_NAME_LIST%"
  set "SCRIPT_TEMP_CURRENT_DIR_LIST=%SCRIPT_TEMP_CURRENT_DIR_LIST%"
  set "SCRIPT_TEMP_BASE_DIR_LIST=%SCRIPT_TEMP_BASE_DIR_LIST%"
  set "SCRIPT_TEMP_PARENT_PATH_DIR_LIST=%SCRIPT_TEMP_PARENT_PATH_DIR_LIST%"
  set "SCRIPT_TEMP_DIR_NAME_TOKEN_LIST=%SCRIPT_TEMP_DIR_NAME_TOKEN_LIST%"
  set "SCRIPT_TEMP_TASK_COUNT_LIST=%SCRIPT_TEMP_TASK_COUNT_LIST%"

  exit /b %LASTERROR%
)
