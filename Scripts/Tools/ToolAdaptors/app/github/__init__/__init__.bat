@echo off

if /i "%GITHUB_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "GITHUB_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined GITHUB_ADAPTOR_PROJECT_ROOT                call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" GITHUB_ADAPTOR_PROJECT_ROOT                 "%%~dp0.."

if not defined GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT   call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT    "%%GITHUB_ADAPTOR_PROJECT_ROOT%%/_config"
if not defined GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT   "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/github"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b 10

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" %%* -lite_parse -gen_user_config "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

if not exist "%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-user.lst"  call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" accounts-user.lst.in  accounts-user.lst || exit /b
if not exist "%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-org.lst"   call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" accounts-org.lst.in   accounts-org.lst || exit /b
if not exist "%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/repos.lst"          call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" repos.lst.in          repos.lst || exit /b

call :IF_DEFINED_AND_FILE_EXIST CURL_EXECUTABLE || (
  echo.%~nx0: error: CURL_EXECUTABLE file path is not found: "%EMULE_EXECUTABLE%"
  exit /b 255
) >&2

call :IF_DEFINED_AND_FILE_EXIST JQ_EXECUTABLE || (
  echo.%~nx0: error: JQ_EXECUTABLE file path is not found: "%JQ_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" GH_ADAPTOR_BACKUP_DIR   "%%GH_ADAPTOR_BACKUP_DIR%%"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%GH_ADAPTOR_BACKUP_DIR%%" || exit /b 11

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
