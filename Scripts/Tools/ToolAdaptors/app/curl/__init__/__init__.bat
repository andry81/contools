@echo off

if /i "%CURL_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "CURL_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined CURL_ADAPTOR_PROJECT_ROOT                        call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" CURL_ADAPTOR_PROJECT_ROOT                 "%%~dp0.."

if not defined CURL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT           call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" CURL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT    "%%CURL_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT          call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT   "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/curl"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b 10

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" %%* -lite_parse -gen_user_config "%%CURL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_FILE_EXIST CURL_EXECUTABLE || (
  echo.%~nx0: error: CURL_EXECUTABLE file path is not found: "%CURL_EXECUTABLE%"
  exit /b 255
) >&2

exit /b 0

:IF_DEFINED_AND_FILE_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%" exit /b 1
exit /b 0

:IF_DEFINED_AND_DIR_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%\" exit /b 1
exit /b 0
