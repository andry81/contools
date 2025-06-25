@echo off

if /i "%QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

rem cast to integer
set /A NEST_LVL+=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%QBITTORRENT_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/qbittorrent"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/canonical_file_vars.bat" QBITTORRENT_EXECUTABLE || exit /b
call "%%CONTOOLS_ROOT%%/std/canonical_dir_vars.bat" APPDATA LOCALAPPDATA ROAMINGAPPDATA QBITTORRENT_LOCAL_CONFIG_DIR QBITTORRENT_ROAMING_CONFIG_DIR QBITTORRENT_ADAPTOR_BACKUP_DIR || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
