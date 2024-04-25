@echo off

rem USAGE:
rem   delete_restapi_user_repos.bat [<Flags>] [--] [<cmd> [<param0> [<param1>]]]

rem Description:
rem   Script to delete list of repositories using restapi.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -exit-on-error
rem     Don't continue on error.

rem <cmd> [<param0> [<param1>]]
rem   Continue from specific command with parameters.
rem   Useful to continue after the last error after specific command.

setlocal

call "%%~dp0__init__/script_init.bat" delete restapi %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem :FREE_TEMP_DIR
rem rem cleanup temporary files
rem call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

set /A NEST_LVL-=1

exit /b %LAST_ERROR%

:MAIN
rem script flags
set FLAG_EXIT_ON_ERROR=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-exit-on-error" (
    set FLAG_EXIT_ON_ERROR=1
  ) else if not "%FLAG%" == "--" (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP
)

set "FROM_CMD=%~1"
set "FROM_CMD_PARAM0=%~2"
set "FROM_CMD_PARAM1=%~3"

rem must be empty
if defined FROM_CMD (
  if not defined SKIPPING_CMD echo.Skipping commands:
  set SKIPPING_CMD=1
)

set REPO_LISTS_TO_DELETE="%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/repos-to-delete.lst"

for /F "usebackq eol=# tokens=1,* delims=/" %%i in (%REPO_LISTS_TO_DELETE%) do (
  set "REPO_OWNER=%%i"
  set "REPO=%%j"

  call "%%?~dp0%%.impl/update_skip_state.bat" "delete_restapi_user_repo.bat" "%%REPO_OWNER%%" "%%REPO%%"

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%delete_restapi_user_repo.bat"%%BARE_FLAGS%% "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* delete_restapi_user_repo.bat "%%REPO_OWNER%%" "%%REPO%%"
)

exit /b 0
