@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

rem register all environment variables
set 2>nul > "%INIT_VARS_FILE%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPEC}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL

rem load initialization environment variables
for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
pushd "%?~dp0%" && (
  call :MAIN_IMPL %%* || ( popd & goto EXIT )
  popd
)

:EXIT
exit /b

:MAIN_IMPL
set HAS_AUTH_USER=0

if defined GH_AUTH_USER if not "%GH_AUTH_PASS%" == "{{USER}}" ^
if defined GH_AUTH_PASS if not "%GH_AUTH_PASS%" == "{{PASS}}" set HAS_AUTH_USER=1

if %HAS_AUTH_USER% NEQ 0 (
  rem including private repos
  call :CMD "backup_restapi_auth_user_repos_list.bat" owner || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_auth_user_repos_list.bat" all || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
)

rem including private repos if authentication is declared
for /F "usebackq eol=# tokens=* delims=" %%i in ("%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-user.lst") do (
  set "REPO_OWNER=%%i"
  call :CMD "backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" owner || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_user_repos_list.bat" "%%REPO_OWNER%%" all || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%" || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
)

for /F "usebackq eol=# tokens=* delims=" %%i in ("%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/accounts-org.lst") do (
  set "REPO_OWNER=%%i"
  call :CMD "backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" sources || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_org_repos_list.bat" "%%REPO_OWNER%%" all || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_starred_repos_list.bat" "%%REPO_OWNER%%" || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
)

for /F "usebackq eol=# tokens=1,* delims=/" %%i in ("%GITHUB_ADAPTOR_PROJECT_OUTPUT_CONFIG_ROOT%/repos.lst") do (
  set "REPO_OWNER=%%i"
  set "REPO=%%j"
  call :CMD "backup_restapi_repo_stargazers_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || exit /b 255
  echo.---
  call :CMD "backup_restapi_repo_subscribers_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_repo_forks_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
  call :CMD "backup_restapi_repo_releases_list.bat" "%%REPO_OWNER%%" "%%REPO%%" || exit /b 255
  echo.---
  if defined GH_RESTAPI_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GH_RESTAPI_BACKUP_USE_TIMEOUT_MS%%"
)

exit /b 0

:CMD
echo.^>%*
(
  %*
)
exit /b
