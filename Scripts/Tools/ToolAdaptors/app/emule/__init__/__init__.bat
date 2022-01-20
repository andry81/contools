@echo off

if /i "%EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined EMULE_ADAPTOR_PROJECT_ROOT               call :CANONICAL_PATH EMULE_ADAPTOR_PROJECT_ROOT               "%%~dp0.."

if not defined EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  call :CANONICAL_PATH EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  "%%EMULE_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT call :CANONICAL_PATH EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/emule"

if not exist "%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_FILE_EXIST EMULE_EXECUTABLE || (
  echo.%~nx0: error: EMULE_EXECUTABLE file path is not found: "%EMULE_EXECUTABLE%"
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST LOCALAPPDATA || (
  echo.%~nx0: error: LOCALAPPDATA directory is not found: "%LOCALAPPDATA%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST EMULE_CONFIG_DIR || (
  echo.%~nx0: error: EMULE_CONFIG_DIR directory is not found: "%EMULE_CONFIG_DIR%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST EMULE_LOG_DIR || (
  echo.%~nx0: error: EMULE_LOG_DIR directory is not found: "%EMULE_LOG_DIR%".
  exit /b 255
) >&2

call :CANONICAL_PATH EMULE_CONFIG_DIR           "%%EMULE_CONFIG_DIR%%"

call :CANONICAL_PATH EMULE_LOG_DIR              "%%EMULE_LOG_DIR%%"

call :CANONICAL_PATH EMULE_ADAPTOR_BACKUP_DIR   "%%EMULE_ADAPTOR_BACKUP_DIR%%"

if not exist "%EMULE_ADAPTOR_BACKUP_DIR%\" ( mkdir "%EMULE_ADAPTOR_BACKUP_DIR%" || exit /b 11 )

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
