@echo off

if /i "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_PROJECT_ROOT_INIT0_DIR=%~dp0"

rem cast to integer
set /A NEST_LVL+=0

rem Do not make a file or a directory
if defined NO_GEN set /A NO_GEN+=0

rem Do not make a log directory or a log file
if defined NO_LOG set /A NO_LOG+=0

rem Do not make a log output or stdio duplication into files
if defined NO_LOG_OUTPUT set /A NO_LOG_OUTPUT+=0

rem Do not change code page
if defined NO_CHCP set /A NO_CHCP+=0

call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_PROJECT_ROOT                   "%%~dp0.."
call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_PROJECT_EXTERNALS_ROOT         "%%CONTOOLS_PROJECT_ROOT%%/_externals"

if not exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%\*" (
  echo;%~nx0: error: CONTOOLS_PROJECT_EXTERNALS_ROOT directory does not exist: "%CONTOOLS_PROJECT_EXTERNALS_ROOT%".
  exit /b 255
) >&2

call "%%~dp0canonical_path_if_ndef.bat" PROJECT_OUTPUT_ROOT                     "%%CONTOOLS_PROJECT_ROOT%%/_out"
call "%%~dp0canonical_path_if_ndef.bat" PROJECT_LOG_ROOT                        "%%CONTOOLS_PROJECT_ROOT%%/.log"

call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_PROJECT_INPUT_CONFIG_ROOT      "%%CONTOOLS_PROJECT_ROOT%%/_config"
call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT     "%%PROJECT_OUTPUT_ROOT%%/config/contools"

rem retarget externals of an external project

call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_UTILS_PROJECT_EXTERNALS_ROOT   "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"
call "%%~dp0canonical_path_if_ndef.bat" TACKLELIB_PROJECT_EXTERNALS_ROOT        "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"
call "%%~dp0canonical_path_if_ndef.bat" SVNCMD_PROJECT_EXTERNALS_ROOT           "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%"

rem CAUTION:
rem   Only `CONTOOLS_ROOT` variable is available from here.
rem
call "%%~dp0canonical_path_if_ndef.bat" CONTOOLS_ROOT                           "%%CONTOOLS_PROJECT_ROOT%%/scripts/tools"

call "%%CONTOOLS_ROOT%%/std/get_windows_version.bat" || exit /b

rem Windows XP is minimal
call "%%CONTOOLS_ROOT%%/std/check_windows_version.bat" 5 1 || exit /b

if %NO_GEN%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/build/mkdir_if_notexist.bat" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b
)

if not defined LOAD_CONFIG_VERBOSE if %INIT_VERBOSE%0 NEQ 0 set LOAD_CONFIG_VERBOSE=1

rem NOTE:
rem   After the config load, all the variables additionally to the `CONTOOLS_ROOT` variable would be available from here.
rem
if %NO_GEN%0 EQU 0 (
  call "%%CONTOOLS_PROJECT_ROOT%%/tools/load_config_dir.bat" %%* -gen_user_config -- "%%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%%" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b
) else call "%%CONTOOLS_PROJECT_ROOT%%/tools/load_config_dir.bat" %%* -- "%%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%%" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

rem init external projects

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/contools--utils/__init__/__init__.bat" (
  rem disable code page change in nested __init__
  set /A NO_CHCP+=1
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/contools--utils/__init__/__init__.bat" %%* || exit /b
  set /A NO_CHCP-=1
)

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/tacklelib/__init__/__init__.bat" (
  rem disable code page change in nested __init__
  set /A NO_CHCP+=1
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/tacklelib/__init__/__init__.bat" %%* || exit /b
  set /A NO_CHCP-=1
)

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/svncmd/__init__/__init__.bat" (
  rem disable code page change in nested __init__
  set /A NO_CHCP+=1
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/svncmd/__init__/__init__.bat" %%* || exit /b
  set /A NO_CHCP-=1
)

if %NO_GEN%0 EQU 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_OUTPUT_ROOT%%" || exit /b
)

if %NO_CHCP%0 EQU 0 (
  if defined CHCP call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CHCP%%
)

exit /b 0
