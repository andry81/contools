@echo off

if /i "%CURL_ADAPTOR_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

call "%%~dp0..\..\__init__\__init__.bat" || exit /b

set "CURL_ADAPTOR_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CURL_ADAPTOR_PROJECT_ROOT                 "%%~dp0.."

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CURL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT    "%%CURL_ADAPTOR_PROJECT_ROOT%%/_config"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT   "%%PROJECT_OUTPUT_ROOT%%/config/contools/tool_adaptors/curl"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/load_config_dir.bat" %%* -gen_user_config "%%CURL_ADAPTOR_PROJECT_INPUT_CONFIG_ROOT%%" "%%CURL_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

call "%%CONTOOLS_ROOT%%/std/if_var_defined_and_file_exist.bat" CURL_EXECUTABLE || (
  echo.%~nx0: error: CURL_EXECUTABLE file path is not found: "%CURL_EXECUTABLE%"
  exit /b 255
) >&2

exit /b 0
