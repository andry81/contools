@echo off

if /i "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined CONTOOLS_PROJECT_ROOT                call "%%~dp0canonical_path.bat" CONTOOLS_PROJECT_ROOT                "%%~dp0.."
if not defined CONTOOLS_PROJECT_EXTERNALS_ROOT      call "%%~dp0canonical_path.bat" CONTOOLS_PROJECT_EXTERNALS_ROOT      "%%CONTOOLS_PROJECT_ROOT%%/_externals"

if not defined PROJECT_OUTPUT_ROOT                  call "%%~dp0canonical_path.bat" PROJECT_OUTPUT_ROOT                  "%%CONTOOLS_PROJECT_ROOT%%/_out"
if not defined PROJECT_LOG_ROOT                     call "%%~dp0canonical_path.bat" PROJECT_LOG_ROOT                     "%%CONTOOLS_PROJECT_ROOT%%/.log"

if not defined CONTOOLS_PROJECT_INPUT_CONFIG_ROOT   call "%%~dp0canonical_path.bat" CONTOOLS_PROJECT_INPUT_CONFIG_ROOT   "%%CONTOOLS_PROJECT_ROOT%%/_config"
if not defined CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT  call "%%~dp0canonical_path.bat" CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools"

if not defined CONTOOLS_ROOT                        call "%%~dp0canonical_path.bat" CONTOOLS_ROOT                        "%%CONTOOLS_PROJECT_ROOT%%/Scripts/Tools"

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b 10

if not defined LOAD_CONFIG_VERBOSE if %INIT_VERBOSE%0 NEQ 0 set LOAD_CONFIG_VERBOSE=1

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" %%* -lite_parse -gen_user_config "%%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%%" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

rem init external projects

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/tacklelib/__init__/__init__.bat" (
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/tacklelib/__init__/__init__.bat" %%* || exit /b
)

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/svncmd/__init__/__init__.bat" (
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/svncmd/__init__/__init__.bat" %%* || exit /b
)

call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%PROJECT_OUTPUT_ROOT%%" || exit /b 11
call "%%CONTOOLS_ROOT%%/std/mkdir_if_notexist.bat" "%%PROJECT_LOG_ROOT%%" || exit /b 12

if defined CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CHCP%%

exit /b 0
