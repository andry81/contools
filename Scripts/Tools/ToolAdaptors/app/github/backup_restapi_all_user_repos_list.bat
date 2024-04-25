@echo off

rem USAGE:
rem   backup_restapi_all_user_repos_list.bat [<Flags>] [--] [<cmd> [<param0> [<param1>]]]

rem Description:
rem   Script to request all restapi responses from all user accounts in
rem   the user accounts file.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -skip-auth-repo-list
rem     Skip request to private repositories in the auth repo list file.
rem   -exit-on-error
rem     Don't continue on error.

rem <cmd> [<param0> [<param1>]]
rem   Continue from specific command with parameters.
rem   Useful to continue after the last error after specific command.

setlocal

call "%%~dp0__init__/script_init.bat" backup restapi %%0 %%* || exit /b
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
set FLAG_SKIP_AUTH_REPO_LIST=0
set FLAG_EXIT_ON_ERROR=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-skip-auth-repo-list" (
    set FLAG_SKIP_AUTH_REPO_LIST=1
  ) else if "%FLAG%" == "-exit-on-error" (
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

if %FLAG_SKIP_AUTH_REPO_LIST% NEQ 0 goto SKIP_AUTH_REPO_LIST

set HAS_AUTH_USER=0

if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" ^
if defined GH_AUTH_PASS if not "%GH_AUTH_PASS%" == "{{PASS}}" set HAS_AUTH_USER=1

rem must be empty
if defined FROM_CMD (
  if not defined SKIPPING_CMD echo.Skipping commands:
  set SKIPPING_CMD=1
)

if %HAS_AUTH_USER% EQU 0 goto SKIP_AUTH_USER

rem including private repos

call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_auth_user_repos_list.bat" owner

if not defined SKIPPING_CMD (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_auth_user_repos_list.bat" owner || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
  echo.---
) else call echo.* backup_restapi_auth_user_repos_list.bat owner

call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_auth_user_repos_list.bat" all

if not defined SKIPPING_CMD (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_auth_user_repos_list.bat" all || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
  echo.---
) else call echo.* backup_restapi_auth_user_repos_list.bat all

:SKIP_AUTH_USER
:SKIP_AUTH_REPO_LIST

rem including private repos if authentication is declared
for /F "usebackq eol=# tokens=* delims=" %%i in ("%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-user.lst") do (
  set "REPO_OWNER=%%i"

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" owner

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" owner || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_user_repos_list.bat "%%REPO_OWNER%%" owner

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" all

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" all || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_user_repos_list.bat "%%REPO_OWNER%%" all

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%"

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_starred_repos_list.bat "%%REPO_OWNER%%"
)

exit /b 0
