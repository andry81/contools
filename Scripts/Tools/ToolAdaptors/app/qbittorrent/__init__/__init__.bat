@echo off

if /i "%QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "QBITTORRENT_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined QBITTORRENT_ADAPTOR_PROJECT_ROOT               call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ADAPTOR_PROJECT_ROOT                "%%~dp0.."

if not defined QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   "%%QBITTORRENT_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/qbittorrent"

if not exist "%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 10 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%QBITTORRENT_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%QBITTORRENT_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call :IF_DEFINED_AND_DIR_EXIST LOCALAPPDATA || (
  echo.%~nx0: error: LOCALAPPDATA directory is not found: "%LOCALAPPDATA%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST QBITTORRENT_LOCAL_CONFIG_DIR || (
  echo.%~nx0: error: QBITTORRENT_LOCAL_CONFIG_DIR directory is not found: "%QBITTORRENT_LOCAL_CONFIG_DIR%".
  exit /b 255
) >&2

call :IF_DEFINED_AND_DIR_EXIST QBITTORRENT_ROAMING_CONFIG_DIR || (
  echo.%~nx0: error: QBITTORRENT_ROAMING_CONFIG_DIR directory is not found: "%QBITTORRENT_ROAMING_CONFIG_DIR%".
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" LOCALAPPDATA                          "%%LOCALAPPDATA%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" ROAMINGAPPDATA                        "%%ROAMINGAPPDATA%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_LOCAL_CONFIG_DIR          "%%QBITTORRENT_LOCAL_CONFIG_DIR%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ROAMING_CONFIG_DIR        "%%QBITTORRENT_ROAMING_CONFIG_DIR%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" QBITTORRENT_ADAPTOR_BACKUP_DIR        "%%QBITTORRENT_ADAPTOR_BACKUP_DIR%%"

if not exist "%QBITTORRENT_ADAPTOR_BACKUP_DIR%\" ( mkdir "%QBITTORRENT_ADAPTOR_BACKUP_DIR%" || exit /b 11 )

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
