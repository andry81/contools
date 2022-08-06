@echo off

if /i "%FLYLINK_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "FLYLINK_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined FLYLINK_ADAPTOR_PROJECT_ROOT               call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINK_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

if not defined FLYLINK_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINK_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%FLYLINK_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/flylink"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b 10

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%FLYLINK_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_DIR_EXIST FLYLINKDC_INSTALL_PATH || (
  echo.%~nx0: error: FLYLINKDC_INSTALL_PATH directory is not found: "%FLYLINKDC_INSTALL_PATH%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST FLYLINKDC_SETTINGS_PATH || (
  echo.%~nx0: error: FLYLINKDC_SETTINGS_PATH directory is not found: "%FLYLINKDC_SETTINGS_PATH%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_INSTALL_PATH          "%%FLYLINKDC_INSTALL_PATH%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_SETTINGS_PATH         "%%FLYLINKDC_SETTINGS_PATH%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_ADAPTOR_BACKUP_DIR    "%%FLYLINKDC_ADAPTOR_BACKUP_DIR%%"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%FLYLINK_ADAPTOR_BACKUP_DIR%%" || exit /b 10

exit /b 0

:IF_DEFINED_AND_DIR_EXIST
setlocal
if "%~1" == "" exit /b 1
if not defined %~1 exit /b 1
call set "DIR_PATH=%%%~1%%"
if not defined DIR_PATH exit /b 1
if not exist "%DIR_PATH%\" exit /b 1
exit /b 0
