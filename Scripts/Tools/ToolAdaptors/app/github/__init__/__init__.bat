@echo off

if /i "%GITHUB_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "GITHUB_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" GITHUB_ADAPTOR_PROJECT_ROOT                 "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT    "%%GITHUB_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT   "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/github"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" %%* -gen_user_config "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" accounts-user.lst.in    accounts-user.lst || exit /b
call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" accounts-org.lst.in     accounts-org.lst || exit /b
call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" repos.lst.in            repos.lst || exit /b
call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" repos-auth.lst.in       repos-auth.lst || exit /b
call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" repos-forks.lst.in      repos-forks.lst || exit /b

call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" -if_not_exist "%%GITHUB_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" repos-to-delete.lst.in  repos-to-delete.lst || exit /b

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" CURL_EXECUTABLE || (
  echo.%~nx0: error: CURL_EXECUTABLE file path is not found: "%EMULE_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" JQ_EXECUTABLE || (
  echo.%~nx0: error: JQ_EXECUTABLE file path is not found: "%JQ_EXECUTABLE%"
  exit /b 255
) >&2

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" GH_ADAPTOR_BACKUP_DIR   "%%GH_ADAPTOR_BACKUP_DIR%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%GH_ADAPTOR_BACKUP_DIR%%" || exit /b

exit /b 0
