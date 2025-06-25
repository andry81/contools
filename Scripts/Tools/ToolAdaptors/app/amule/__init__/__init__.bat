@echo off

if /i "%AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "AMULE_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

rem cast to integer
set /A NEST_LVL+=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%AMULE_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/amule"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%AMULE_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%AMULE_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_file_vars.bat" AMULE_CMD_EXECUTABLE AMULE_GUI_EXECUTABLE || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_dir_vars.bat" APPDATA LOCALAPPDATA AMULE_CONFIG_DIR AMULE_LOG_DIR AMULE_ADAPTOR_BACKUP_DIR || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%AMULE_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
