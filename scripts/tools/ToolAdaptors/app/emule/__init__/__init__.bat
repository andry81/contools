@echo off

if /i "%EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "EMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

rem cast to integer
set /A NEST_LVL+=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%EMULE_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/emule"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%EMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%EMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_file_vars.bat" EMULE_EXECUTABLE || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_dir_vars.bat" APPDATA LOCALAPPDATA EMULE_CONFIG_DIR EMULE_LOG_DIR EMULE_TEMP_DIR EMULE_ADAPTOR_BACKUP_DIR || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%EMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
