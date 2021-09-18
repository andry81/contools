@echo off

if /i "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined CONTOOLS_PROJECT_ROOT                call :CANONICAL_PATH CONTOOLS_PROJECT_ROOT                "%%~dp0.."
if not defined CONTOOLS_PROJECT_EXTERNALS_ROOT      call :CANONICAL_PATH CONTOOLS_PROJECT_EXTERNALS_ROOT      "%%CONTOOLS_PROJECT_ROOT%%/_externals"

if not defined PROJECT_OUTPUT_ROOT                  call :CANONICAL_PATH PROJECT_OUTPUT_ROOT                  "%%CONTOOLS_PROJECT_ROOT%%/_out"
if not defined PROJECT_LOG_ROOT                     call :CANONICAL_PATH PROJECT_LOG_ROOT                     "%%CONTOOLS_PROJECT_ROOT%%/.log"

if not defined CONTOOLS_PROJECT_INPUT_CONFIG_ROOT   call :CANONICAL_PATH CONTOOLS_PROJECT_INPUT_CONFIG_ROOT   "%%CONTOOLS_PROJECT_ROOT%%/_config"
if not defined CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT  call :CANONICAL_PATH CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT  "%%PROJECT_OUTPUT_ROOT%%/config/contools"

if not defined CONTOOLS_ROOT                        call :CANONICAL_PATH CONTOOLS_ROOT                        "%%CONTOOLS_PROJECT_ROOT%%/Scripts/Tools"
if not defined CONTOOLS_BASH_ROOT                   call :CANONICAL_PATH CONTOOLS_BASH_ROOT                   "%%CONTOOLS_ROOT%%/bash"
if not defined CONTOOLS_BUILD_TOOLS_ROOT            call :CANONICAL_PATH CONTOOLS_BUILD_TOOLS_ROOT            "%%CONTOOLS_ROOT%%/build"
if not defined CONTOOLS_SQLITE_TOOLS_ROOT           call :CANONICAL_PATH CONTOOLS_SQLITE_TOOLS_ROOT           "%%CONTOOLS_ROOT%%/sqlite"
if not defined CONTOOLS_TESTLIB_ROOT                call :CANONICAL_PATH CONTOOLS_TESTLIB_ROOT                "%%CONTOOLS_ROOT%%/testlib"
if not defined CONTOOLS_XML_TOOLS_ROOT              call :CANONICAL_PATH CONTOOLS_XML_TOOLS_ROOT              "%%CONTOOLS_ROOT%%/xml"
if not defined CONTOOLS_VARS_ROOT                   call :CANONICAL_PATH CONTOOLS_VARS_ROOT                   "%%CONTOOLS_ROOT%%/vars"

if not defined CONTOOLS_UTILITIES_ROOT              call :CANONICAL_PATH CONTOOLS_UTILITIES_ROOT              "%%CONTOOLS_PROJECT_ROOT%%/Utilities"
if not defined CONTOOLS_UTILITIES_BIN_ROOT          call :CANONICAL_PATH CONTOOLS_UTILITIES_BIN_ROOT          "%%CONTOOLS_UTILITIES_ROOT%%/bin"
if not defined CONTOOLS_GNUWIN32_ROOT               call :CANONICAL_PATH CONTOOLS_GNUWIN32_ROOT               "%%CONTOOLS_UTILITIES_BIN_ROOT%%/gnuwin32"
if not defined CONTOOLS_UTILITIES_HASHDEEP_ROOT     call :CANONICAL_PATH CONTOOLS_UTILITIES_HASHDEEP_ROOT     "%%CONTOOLS_UTILITIES_BIN_ROOT%%/hashdeep"
if not defined CONTOOLS_UTILITIES_SQLITE_ROOT       call :CANONICAL_PATH CONTOOLS_UTILITIES_SQLITE_ROOT       "%%CONTOOLS_UTILITIES_BIN_ROOT%%/sqlite"

rem init external projects

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/tacklelib/__init__/__init__.bat" (
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/tacklelib/__init__/__init__.bat" || exit /b
)

if exist "%CONTOOLS_PROJECT_EXTERNALS_ROOT%/svncmd/__init__/__init__.bat" (
  call "%%CONTOOLS_PROJECT_EXTERNALS_ROOT%%/svncmd/__init__/__init__.bat" || exit /b
)

if not exist "%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%/config.system.vars.in" (
  echo.%~nx0: error: `%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%/config.system.vars.in` must exist.
  exit /b 255
) >&2

if not exist "%PROJECT_OUTPUT_ROOT%\" ( mkdir "%PROJECT_OUTPUT_ROOT%" || exit /b 10 )
if not exist "%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%\" ( mkdir "%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%" || exit /b 11 )

call "%%CONTOOLS_ROOT%%/build/load_config_dir.bat" -gen_user_config "%%CONTOOLS_PROJECT_INPUT_CONFIG_ROOT%%" "%%CONTOOLS_PROJECT_OUTPUT_CONFIG_ROOT%%" || exit /b

if defined CHCP chcp %CHCP%

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
