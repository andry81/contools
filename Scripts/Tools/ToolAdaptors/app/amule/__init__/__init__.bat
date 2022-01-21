@echo off

if /i "%AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined AMULE_ADAPTOR_PROJECT_ROOT               call :CANONICAL_PATH AMULE_ADAPTOR_PROJECT_ROOT               "%%~dp0.."

if not defined AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  call :CANONICAL_PATH AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  "%%AMULE_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT call :CANONICAL_PATH AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/amule"

if not exist "%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_FILE_EXIST AMULE_CMD_EXECUTABLE || (
  echo.%~nx0: error: AMULE_CMD_EXECUTABLE file path is not found: "%AMULE_CMD_EXECUTABLE%"
  exit /b 255
) >&2

call :IF_DEFINED_AND_FILE_EXIST AMULE_GUI_EXECUTABLE || (
  echo.%~nx0: error: AMULE_GUI_EXECUTABLE file path is not found: "%AMULE_GUI_EXECUTABLE%"
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST APPDATA || (
  echo.%~nx0: error: APPDATA directory is not found: "%APPDATA%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST AMULE_CONFIG_DIR || (
  echo.%~nx0: error: AMULE_CONFIG_DIR directory is not found: "%AMULE_CONFIG_DIR%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST AMULE_LOG_DIR || (
  echo.%~nx0: error: AMULE_LOG_DIR directory is not found: "%AMULE_LOG_DIR%".
  exit /b 255
) >&2

call :CANONICAL_PATH AMULE_CONFIG_DIR           "%%AMULE_CONFIG_DIR%%"

call :CANONICAL_PATH AMULE_LOG_DIR              "%%AMULE_LOG_DIR%%"

call :CANONICAL_PATH AMULE_ADAPTOR_BACKUP_DIR   "%%AMULE_ADAPTOR_BACKUP_DIR%%"

if not exist "%AMULE_ADAPTOR_BACKUP_DIR%\" ( mkdir "%AMULE_ADAPTOR_BACKUP_DIR%" || exit /b 11 )

exit /b 0

:IF_DEFINED_AND_FILE_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "FILE_PATH=%%%~1%%"
if not defined FILE_PATH exit /b 1
if not exist "%FILE_PATH%" exit /b 1
exit /b 0

:IF_DEFINED_AND_DIR_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%\" exit /b 1
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
