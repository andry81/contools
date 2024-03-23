@echo off

if /i "%AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%AMULE_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/amule"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" AMULE_CMD_EXECUTABLE || (
  echo.%~nx0: error: AMULE_CMD_EXECUTABLE file path is not found: "%AMULE_CMD_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" AMULE_GUI_EXECUTABLE || (
  echo.%~nx0: error: AMULE_GUI_EXECUTABLE file path is not found: "%AMULE_GUI_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" APPDATA || (
  echo.%~nx0: error: APPDATA directory is not found: "%APPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" LOCALAPPDATA || (
  echo.%~nx0: error: LOCALAPPDATA directory is not found: "%LOCALAPPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" AMULE_CONFIG_DIR || (
  echo.%~nx0: error: AMULE_CONFIG_DIR directory is not found: "%AMULE_CONFIG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" AMULE_LOG_DIR || (
  echo.%~nx0: error: AMULE_LOG_DIR directory is not found: "%AMULE_LOG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" AMULE_CONFIG_DIR                "%%AMULE_CONFIG_DIR%%" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" AMULE_LOG_DIR                   "%%AMULE_LOG_DIR%%" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" AMULE_ADAPTOR_BACKUP_DIR        "%%AMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
