@echo off

rem USAGE:
rem   backup_bare_repo.bat [<Flags>] <OWNER> <REPO>

rem Description:
rem   Script to backup any repository including private repository with
rem   credentials.
rem   Backup by default includes only a bare repository backup.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -checkout
rem     Additionally execute git checkout with recursion to backup submodules.

rem <OWNER>:
rem   Owner name of a repository.
rem <REPO>:
rem   Repository name.

setlocal

call "%%~dp0__init__/script_init.bat" backup bare %%0 %%* || exit /b
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
rem script flags
set FLAG_CHECKOUT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-checkout" (
    set FLAG_CHECKOUT=1
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

set "OWNER=%~1"
set "REPO=%~2"

if not defined OWNER (
  echo.%?~nx0%: error: OWNER is not defined.
  exit /b 255
) >&2

if not defined REPO (
  echo.%?~nx0%: error: REPO is not defined.
  exit /b 255
) >&2

set "QUERY_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\query.txt"

set "GH_ADAPTOR_BACKUP_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\backup\bare"

set "GH_REPOS_BACKUP_TEMP_DIR=%GH_ADAPTOR_BACKUP_TEMP_DIR%/repo/user/%OWNER%/%REPO%"
set "GH_REPOS_BACKUP_DIR=%GH_ADAPTOR_BACKUP_DIR%/bare/repo/user/%OWNER%/%REPO%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%GH_REPOS_BACKUP_TEMP_DIR%%" >nul || exit /b 255

if defined GIT_BARE_REPO_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GIT_BARE_REPO_BACKUP_USE_TIMEOUT_MS%%"

call :GIT clone -v --bare --mirror --recurse-submodules --progress "https://github.com/%%OWNER%%/%%REPO%%" "%%GH_REPOS_BACKUP_TEMP_DIR%%/db" || goto MAIN_EXIT
echo.

if %FLAG_CHECKOUT% EQU 0 goto SKIP_CHECKOUT

pushd "%GH_REPOS_BACKUP_TEMP_DIR%/db" && (
  call :GIT config --bool core.bare false
  echo.

  call :GIT clone -v --recurse-submodules --progress "%%GH_REPOS_BACKUP_TEMP_DIR%%/db" "%%GH_REPOS_BACKUP_TEMP_DIR%%/wc" || goto MAIN_EXIT
  echo.

  popd
)

:SKIP_CHECKOUT

set REPO_TYPE_STR=bare

if %FLAG_CHECKOUT% NEQ 0 set REPO_TYPE_STR=bared-checkout

echo.Archiving backup directory...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%GH_REPOS_BACKUP_DIR%%" && ^
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%GH_ADAPTOR_BACKUP_TEMP_DIR%%" "*" "%%GH_REPOS_BACKUP_DIR%%/nonauth-%%REPO_TYPE_STR%%-repo--[%%OWNER%%][%%REPO%%]--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo.

:MAIN_EXIT
set LAST_ERROR=%ERRORLEVEL%

echo.

exit /b %LAST_ERROR%

:GIT
echo.^>git.exe %GIT_BARE_FLAGS% %*
git.exe %GIT_BARE_FLAGS% %*
exit /b
