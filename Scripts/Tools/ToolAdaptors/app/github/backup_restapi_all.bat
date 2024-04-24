@echo off

rem USAGE:
rem   backup_restapi_all.bat [<Flags>]

rem Description:
rem   Script to request all restapi responses including request of private
rem   repositories with credentials.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -skip-auth-repo-list
rem     Skip request to private repositories in the auth repo list file.
rem   -skip-account-lists
rem     Skip request to accounts in the account list file.
rem   -skip-forks-list
rem     Skip request to forked repositories in the fork list file.
rem     Note:
rem       All forked repositories must be properly synchronized with the parent
rem       repository before each new backup.
rem   -query-repo-info-only
rem     Request only repository information (including parent repository
rem     address) avoding repository else like repo stargazers, subscribers,
rem     forks and releases.
rem   -exit-on-error
rem     Don't continue on error.
rem   -from-cmd
rem     Continue from specific command with parameters.
rem     Useful to continue after the last error after specific command.

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
set FLAG_SKIP_ACCOUNT_LISTS=0
set FLAG_SKIP_FORKS_LIST=0
set FLAG_QUERY_REPO_INFO_ONLY=0
set FLAG_EXIT_ON_ERROR=0
set "FLAG_FROM_CMD_NAME="
set "FLAG_FROM_CMD_PARAM0="
set "FLAG_FROM_CMD_PARAM1="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-skip-auth-repo-list" (
    set FLAG_SKIP_AUTH_REPO_LIST=1
  ) else if "%FLAG%" == "-skip-account-lists" (
    set FLAG_SKIP_ACCOUNT_LISTS=1
  ) else if "%FLAG%" == "-skip-forks-list" (
    set FLAG_SKIP_FORKS_LIST=1
  ) else if "%FLAG%" == "-query-repo-info-only" (
    set FLAG_QUERY_REPO_INFO_ONLY=1
  ) else if "%FLAG%" == "-exit-on-error" (
    set FLAG_EXIT_ON_ERROR=1
  ) else if "%FLAG%" == "-from-cmd" (
    set "FLAG_FROM_CMD=%~2"
    set "FLAG_FROM_CMD_PARAM0=%~3"
    set "FLAG_FROM_CMD_PARAM1=%~4"
    shift
    shift
    shift
  ) else if "%FLAG%" == "--" (
    shift
    set "FLAG="
    goto FLAGS_LOOP_END
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

:FLAGS_LOOP_END

if %FLAG_SKIP_AUTH_REPO_LIST% NEQ 0 goto SKIP_AUTH_REPO_LIST

set HAS_AUTH_USER=0

if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" ^
if defined GH_AUTH_PASS if not "%GH_AUTH_PASS%" == "{{PASS}}" set HAS_AUTH_USER=1

rem must be empty
if defined FLAG_FROM_CMD (
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

if %FLAG_SKIP_ACCOUNT_LISTS% NEQ 0 goto SKIP_ACCOUNT_LISTS

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

for /F "usebackq eol=# tokens=* delims=" %%i in ("%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-org.lst") do (
  set "REPO_OWNER=%%i"

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" sources

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" sources || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_org_repos_list.bat "%%REPO_OWNER%%" sources

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" all

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" all || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_org_repos_list.bat "%%REPO_OWNER%%" all

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%"

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_starred_repos_list.bat "%%REPO_OWNER%%"
)

:SKIP_ACCOUNT_LISTS

set REPO_LISTS="%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/repos.lst"

if %FLAG_SKIP_FORKS_LIST% EQU 0 (
  set REPO_LISTS=%REPO_LISTS% "%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/repos-forks.lst"
)

for /F "usebackq eol=# tokens=1,* delims=/" %%i in (%REPO_LISTS%) do (
  set "REPO_OWNER=%%i"
  set "REPO=%%j"

  call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_user_repo_info.bat" "%%REPO_OWNER%%" "%%REPO%%"

  if not defined SKIPPING_CMD (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_user_repo_info.bat" "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
    echo.---
  ) else call echo.* backup_restapi_user_repo_info.bat "%%REPO_OWNER%%" "%%REPO%%"

  if %FLAG_QUERY_REPO_INFO_ONLY% EQU 0 (
    call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_repo_stargazers_list.bat" "%%REPO_OWNER%%" "%%REPO%%"

    if not defined SKIPPING_CMD (
      call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_repo_stargazers_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
      echo.---
    ) else call echo.* backup_restapi_repo_stargazers_list.bat "%%REPO_OWNER%%" "%%REPO%%"

    call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_repo_subscribers_list.bat" "%%REPO_OWNER%%" "%%REPO%%"

    if not defined SKIPPING_CMD (
      call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_repo_subscribers_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
      echo.---
    ) else call echo.* backup_restapi_repo_subscribers_list.bat "%%REPO_OWNER%%" "%%REPO%%"

    call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_repo_forks_list.bat" "%%REPO_OWNER%%" "%%REPO%%"

    if not defined SKIPPING_CMD (
      call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_repo_forks_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
      echo.---
    ) else call echo.* backup_restapi_repo_forks_list.bat "%%REPO_OWNER%%" "%%REPO%%"

    call "%%?~dp0%%.impl/update_skip_state.bat" "backup_restapi_repo_releases_list.bat" "%%REPO_OWNER%%" "%%REPO%%"

    if not defined SKIPPING_CMD (
      call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%?~dp0%%backup_restapi_repo_releases_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || if %FLAG_EXIT_ON_ERROR% NEQ 0 exit /b 255
      echo.---
    ) else call echo.* backup_restapi_repo_releases_list.bat "%%REPO_OWNER%%" "%%REPO%%"
  )
)

exit /b 0
