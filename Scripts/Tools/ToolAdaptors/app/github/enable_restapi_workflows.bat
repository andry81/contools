@echo off

rem USAGE:
rem   enable_restapi_workflows.bat [<Flags>] [--] [<cmd> [<param0> [<param1>]]]

rem Description:
rem   Script to enable workflows using restapi request.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -exit-on-error
rem     Don't continue on error.

rem <cmd> [<param0> [<param1>]]
rem   Continue from specific command with parameters.
rem   Useful to continue after the last error after specific command.

setlocal

call "%%~dp0__init__/script_init.bat" workflow restapi %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || exit /b

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

set /A NEST_LVL-=1

exit /b %LAST_ERROR%

:MAIN
pushd "%?~dp0%" && (
  call :MAIN_IMPL %%* || ( popd & goto EXIT )
  popd
)

:EXIT
exit /b

:MAIN_IMPL
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

set WORKFLOW_LISTS="%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/workflows.lst"

for /F "usebackq eol=# tokens=1,* delims=:" %%i in (%WORKFLOW_LISTS%) do for /F "eol=# tokens=1,* delims=/" %%k in ("%%i") do (
  set "REPO_OWNER=%%k"
  set "REPO=%%l"
  set "WORKFLOW_ID=%%j"

  call "%%?~dp0%%.impl/update_skip_state.bat" "enable_restapi_user_repo_workflow.bat" "%%REPO_OWNER%%" "%%REPO%%"

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%enable_restapi_user_repo_workflow.bat" "%%REPO_OWNER%%" "%%REPO%%" "%%WORKFLOW_ID%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* enable_restapi_user_repo_workflow.bat "%%REPO_OWNER%%" "%%REPO%%" "%%WORKFLOW_ID%%"
)

exit /b 0
