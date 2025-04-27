@echo off

if /i "%EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%EMULE_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/emule"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" EMULE_EXECUTABLE || (
  echo;%~nx0: error: EMULE_EXECUTABLE file path is not found: "%EMULE_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" APPDATA || (
  echo;%~nx0: error: APPDATA directory is not found: "%APPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" LOCALAPPDATA || (
  echo;%~nx0: error: LOCALAPPDATA directory is not found: "%LOCALAPPDATA%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" EMULE_CONFIG_DIR || (
  echo;%~nx0: error: EMULE_CONFIG_DIR directory is not found: "%EMULE_CONFIG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" EMULE_LOG_DIR || (
  echo;%~nx0: error: EMULE_LOG_DIR directory is not found: "%EMULE_LOG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" EMULE_TEMP_DIR || (
  echo;%~nx0: error: EMULE_TEMP_DIR directory is not found: "%EMULE_TEMP_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" EMULE_CONFIG_DIR                "%%EMULE_CONFIG_DIR%%" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" EMULE_LOG_DIR                   "%%EMULE_LOG_DIR%%" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" EMULE_TEMP_DIR                  "%%EMULE_TEMP_DIR%%" || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" EMULE_ADAPTOR_BACKUP_DIR        "%%EMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
