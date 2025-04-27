@echo off

if /i "%QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%QBITTORRENT_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/qbittorrent"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" -gen_user_config "%%QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/if_defined_and_file_exist.bat" QBITTORRENT_EXECUTABLE || (
  echo;%~nx0: error: QBITTORRENT_EXECUTABLE file path is not found: "%QBITTORRENT_EXECUTABLE%"
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

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" QBITTORRENT_LOCAL_CONFIG_DIR || (
  echo;%~nx0: error: QBITTORRENT_LOCAL_CONFIG_DIR directory is not found: "%QBITTORRENT_LOCAL_CONFIG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_dir_exist.bat" QBITTORRENT_ROAMING_CONFIG_DIR || (
  echo;%~nx0: error: QBITTORRENT_ROAMING_CONFIG_DIR directory is not found: "%QBITTORRENT_ROAMING_CONFIG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" LOCALAPPDATA                          "%%LOCALAPPDATA%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" ROAMINGAPPDATA                        "%%ROAMINGAPPDATA%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_LOCAL_CONFIG_DIR          "%%QBITTORRENT_LOCAL_CONFIG_DIR%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ROAMING_CONFIG_DIR        "%%QBITTORRENT_ROAMING_CONFIG_DIR%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ADAPTOR_BACKUP_DIR        "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
