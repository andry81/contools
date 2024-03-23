@echo off

if /i "%FLYLINK_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "FLYLINK_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" FLYLINK_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" FLYLINK_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%FLYLINK_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/flylink"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%FLYLINK_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%FLYLINK_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" APPDATA || (
  echo.%~nx0: error: APPDATA directory is not found: "%APPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" LOCALAPPDATA || (
  echo.%~nx0: error: LOCALAPPDATA directory is not found: "%LOCALAPPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" FLYLINKDC_INSTALL_PATH || (
  echo.%~nx0: error: FLYLINKDC_INSTALL_PATH directory is not found: "%FLYLINKDC_INSTALL_PATH%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" FLYLINKDC_SETTINGS_PATH || (
  echo.%~nx0: error: FLYLINKDC_SETTINGS_PATH directory is not found: "%FLYLINKDC_SETTINGS_PATH%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_INSTALL_PATH          "%%FLYLINKDC_INSTALL_PATH%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_SETTINGS_PATH         "%%FLYLINKDC_SETTINGS_PATH%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" FLYLINKDC_ADAPTOR_BACKUP_DIR    "%%FLYLINKDC_ADAPTOR_BACKUP_DIR%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%FLYLINK_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
