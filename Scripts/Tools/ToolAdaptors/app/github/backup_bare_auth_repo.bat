@echo off

rem USAGE:
rem   backup_bare_auth_repo.bat [<Flags>] <OWNER> <REPO>

rem Description:
rem   Script to backup a private repository with credentials.
rem   Backup by default includes only a bare repository backup.

rem <Flags>:
rem   --
rem     Stop flags parse.
rem   -checkout
rem     Additionally execute git checkout with recursion to backup submodules.
rem   -exit-on-error
rem     Don't continue on error.
rem   -from-cmd
rem     Continue from specific command with parameters.
rem     Useful to continue after the last error after specific command.

rem <OWNER>:
rem   Owner name of a repository.
rem <REPO>:
rem   Repository name.

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/check_vars.bat" CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT || exit /b

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -- %%*
set LASTERROR=%ERRORLEVEL%

if %NEST_LVL% EQU 0 if %LASTERROR% EQU 0 (
  rem copy log into backup directory
  call :XCOPY_DIR "%%PROJECT_LOG_DIR%%" "%%GH_ADAPTOR_BACKUP_DIR%%/bare/.log/%%PROJECT_LOG_DIR_NAME%%" /E /Y /D
)

pause

exit /b %LASTERROR%

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

set /A NEST_LVL+=1

if %NEST_LVL% EQU 1 (
  rem load initialization environment variables
  if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"
)

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

set /A NEST_LVL-=1

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_CHECKOUT=0
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
  if "%FLAG%" == "-checkout" (
    set FLAG_CHECKOUT=1
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

set "OWNER=%~1"
set "REPO=%~2"

if not defined OWNER (
  echo.%?~n0%: error: OWNER is not defined.
  exit /b 255
) >&2

if not defined REPO (
  echo.%?~n0%: error: REPO is not defined.
  exit /b 255
) >&2

set "EMPTY_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\emptydir"
set "QUERY_TEMP_FILE=%SCRIPT_TEMP_CURRENT_DIR%\query.txt"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

set "GH_ADAPTOR_BACKUP_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\backup\bare"

set "GH_REPOS_BACKUP_TEMP_DIR=%GH_ADAPTOR_BACKUP_TEMP_DIR%/repo/user/%OWNER%/%REPO%"
set "GH_REPOS_BACKUP_DIR=%GH_ADAPTOR_BACKUP_DIR%/bare/repo/user/%OWNER%/%REPO%"

mkdir "%GH_REPOS_BACKUP_TEMP_DIR%" || (
  echo.%?~n0%: error: could not create a directory: "%GH_REPOS_BACKUP_TEMP_DIR%".
  exit /b 255
) >&2

set HAS_AUTH_USER=0

if defined GH_AUTH_USER if not "%GH_AUTH_USER%" == "{{USER}}" ^
if defined GH_AUTH_PASS if not "%GH_AUTH_PASS%" == "{{PASS}}" set HAS_AUTH_USER=1

if %HAS_AUTH_USER% EQU 0 (
  echo.%~nx0: error: GH_AUTH_USER or GH_AUTH_PASS is not defined.
  exit /b 255
) >&2

if defined GIT_BARE_REPO_BACKUP_USE_TIMEOUT_MS call "%%CONTOOLS_ROOT%%/std/sleep.bat" "%%GIT_BARE_REPO_BACKUP_USE_TIMEOUT_MS%%"

call :GIT clone -v --bare --mirror --recurse-submodules --progress "https://%%GH_AUTH_PASS%%@github.com/%%OWNER%%/%%REPO%%" "%%GH_REPOS_BACKUP_TEMP_DIR%%/db" || goto MAIN_EXIT
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
if not exist "%GH_REPOS_BACKUP_DIR%\*" mkdir "%GH_REPOS_BACKUP_DIR%"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%GH_ADAPTOR_BACKUP_TEMP_DIR%%" "*" "%%GH_REPOS_BACKUP_DIR%%/auth-%%REPO_TYPE_STR%%-repo--[%%OWNER%%][%%REPO%%]--%%PROJECT_LOG_FILE_NAME_DATE_TIME%%.7z" -sdel || exit /b 20
echo.

:SKIP_ARCHIVE

:MAIN_EXIT
set LASTERROR=%ERRORLEVEL%

echo.

exit /b %LASTERROR%

:GIT
echo.^>git.exe %GIT_BARE_FLAGS% %*
git.exe %GIT_BARE_FLAGS% %*
exit /b

:XCOPY_FILE
if not exist "\\?\%~f3" (
  echo.^>mkdir "%~3"
  call :MAKE_DIR "%%~3" || (
    echo.%?~nx0%: error: could not create a target file directory: "%~3".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%*
exit /b

:XCOPY_DIR
if not exist "\\?\%~f2" (
  echo.^>mkdir "%~2"
  call :MAKE_DIR "%%~2" || (
    echo.%?~nx0%: error: could not create a target directory: "%~2".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%*
exit /b

:MAKE_DIR
for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

mkdir "%FILE_PATH%" 2>nul || if exist "%SystemRoot%\System32\robocopy.exe" ( "%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul ) else type 2>nul || (
  echo.%?~nx0%: error: could not create a target file directory: "%FILE_PATH%".
  exit /b 1
) >&2
exit /b
