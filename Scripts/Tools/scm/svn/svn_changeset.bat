@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script requests piece of wc.db (NODES_BASE/NODES_CURRENT tables) paths
rem   with revisions range in format:
rem      -r "- | [!]FromRevision[-] | [!]FromRevisionExcluding[:[-] | :ToRevisionIncluding[-]]"
rem   All together it reperesents a changeset for a given revisions range.

rem Examples:
rem 1. rem Read files of 66 revision only.
rem    pushd "..." && ( call svn_changeset.bat -r 66 > files.lst & popd )
rem 2. rem Read files higher than 66 revision.
rem    pushd "..." && ( call svn_changeset.bat -r 66: > files.lst & popd )
rem 3. rem Read files higher than 66 revision and less or equal to 70 resivion.
rem    pushd "..." && ( call svn_changeset.bat -r 66:70 > files.lst & popd )
rem 4. rem Read none 66 revision files with not empty revision number.
rem    pushd "..." && ( call svn_changeset.bat -r !66 > files.lst & popd )
rem 5. rem Read inversed range where revisions higher than 67 and less or equal to 66 revision.
rem    pushd "..." && ( call svn_changeset.bat -r !66:67 > files.lst & popd )
rem 6. rem Read files without revision number (empty).
rem    pushd "..." && ( call svn_changeset.bat -r - > files.lst & popd )
rem 7. rem Read none 66 revision files including empty revision number.
rem    pushd "..." && ( call svn_changeset.bat -r !66- > files.lst & popd )

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

rem script flags
set ARG_SVN_REVISION_RANGE_IS_SET=0
set "ARG_SVN_REVISION_RANGE="
set ARG_SVN_NODES_TABLE_IS_SET=0
set "ARG_SVN_NODES_TABLE="
set ARG_SVN_WCROOT=0
set "ARG_SVN_WCROOT_PATH="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-r" (
    rem consume next argument into flags
    set ARG_SVN_REVISION_RANGE_IS_SET=1
    set "ARG_SVN_REVISION_RANGE=%~2"
    shift
    shift
  ) else if "%FLAG%" == "-t" (
    rem consume next argument into flags
    set ARG_SVN_NODES_TABLE_IS_SET=1
    set "ARG_SVN_NODES_TABLE=%~2"
    shift
    shift
  ) else if "%FLAG%" == "-wcroot" (
    set ARG_SVN_WCROOT=1
    set "ARG_SVN_WCROOT_PATH=%~2"
    shift
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b 254
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

if %ARG_SVN_REVISION_RANGE_IS_SET% NEQ 0 ^
if "%ARG_SVN_REVISION_RANGE%" == "" (
  echo.%?~nx0%: error: revision range is not set.
  exit /b 253
) >&2

if %ARG_SVN_NODES_TABLE_IS_SET% NEQ 0 ^
if "%ARG_SVN_NODES_TABLE%" == "" (
  echo.%?~nx0%: error: SVN WC database node table name suffix is not set.
  exit /b 252
) >&2

if %ARG_SVN_WCROOT% NEQ 0 ^
if "%ARG_SVN_WCROOT_PATH%" == "" (
  echo.%?~nx0%: error: SVN WC root path should not be empty.
  exit /b 251
) >&2

rem test SVN WC root path
if %ARG_SVN_WCROOT% NEQ 0 (
  call :TEST_WCROOT_PATH || goto :EOF
) else set "SVN_WCROOT_PATH=%CD%"

goto TEST_WCROOT_PATH_END

:TEST_WCROOT_PATH
set "SVN_WCROOT_PATH=%ARG_SVN_WCROOT_PATH:/=\%"

call set "SVN_BRANCH_REL_SUB_PATH=%%CD:%SVN_WCROOT_PATH%=%%"
if not "%SVN_BRANCH_REL_SUB_PATH%" == "" (
  if "%SVN_BRANCH_REL_SUB_PATH:~0,1%" == "\" (
    set "SVN_BRANCH_REL_SUB_PATH=%SVN_BRANCH_REL_SUB_PATH:~1%"
  )
)

if not "%SVN_BRANCH_REL_SUB_PATH%" == "" ^
if /i not "%SVN_WCROOT_PATH%\%SVN_BRANCH_REL_SUB_PATH%" == "%CD%" (
  echo.%?~nx0%: error: SVN WC root path must be absolute and current directory path must be from the SVN WC root path: SVN_WCROOT_PATH="%SVN_WCROOT_PATH%" CD="%CD%".
  exit /b 250
) >&2

if not "%SVN_BRANCH_REL_SUB_PATH%" == "" set "SVN_BRANCH_REL_SUB_PATH=%SVN_BRANCH_REL_SUB_PATH:\=/%"

exit /b 0

:TEST_WCROOT_PATH_END

if not exist "%SVN_WCROOT_PATH%\.svn\wc.db" (
  echo.%?~nx0%: error: SVN WC database file is not found: "%SVN_WCROOT_PATH%\.svn\wc.db"
  exit /b 249
) >&2

if /i not "%SVN_WCROOT_PATH%" == "%CD%" (
  pushd "%SVN_WCROOT_PATH%" && (
    call :IMPL
    popd
  )
) else call :IMPL

exit /b

:IMPL
rem check on supported wc.db user version
call "%%?~dp0%%impl/svn_get_wc_db_user_ver.bat"

if "%WC_DB_USER_VERSION%" == "" (
  echo.%?~nx0%: error: SVN WC database user version is not set or not found: "%CD%\.svn\wc.db"
  exit /b 240
) >&2

if %WC_DB_USER_VERSION% LSS 31 (
  echo.%?~nx0%: warning: SVN WC database user version is not supported: %WC_DB_USER_VERSION%; supported greater or equal to: 31
) >&2

rem parse -r argument value
set "SQLITE_EXP_REVISION_RANGE_SUFFIX="
if %ARG_SVN_REVISION_RANGE_IS_SET% NEQ 0 call "%%?~dp0%%impl/svn_arg_parse-r.bat" "%%ARG_SVN_REVISION_RANGE%%"
if not "%SQLITE_EXP_REVISION_RANGE%" == "" set "SQLITE_EXP_REVISION_RANGE_SUFFIX= and (%SQLITE_EXP_REVISION_RANGE%)"

if "%ARG_SVN_NODES_TABLE%" == "" (
  set "SQLITE_EXP_NODES_TABLE=nodes_base"
) else if not "%ARG_SVN_NODES_TABLE%" == "-" (
  set "SQLITE_EXP_NODES_TABLE=nodes_%ARG_SVN_NODES_TABLE%"
) else (
  set "SQLITE_EXP_NODES_TABLE=nodes"
)

rem filter output only for the current directory path
set "SQLITE_EXP_SELECT_CMD_LINE=* from new_nodes "
if %ARG_SVN_WCROOT% NEQ 0 ^
if not "%SVN_BRANCH_REL_SUB_PATH%" == "" (
  set "SQLITE_EXP_SELECT_CMD_LINE=revision, substr(local_relpath_new, length('%SVN_BRANCH_REL_SUB_PATH%/')+1) as local_relpath_new_suffix from new_nodes where substr(local_relpath_new, 1, length('%SVN_BRANCH_REL_SUB_PATH%/')) == '%SVN_BRANCH_REL_SUB_PATH%/' collate nocase and local_relpath_new_suffix != '' "
)

call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch ".svn/wc.db" ".headers off" ".mode list" ".separator |" ".nullvalue ." "with new_nodes as ( select revision, case when kind != 'dir' then local_relpath else local_relpath || '/' end as local_relpath_new from %%SQLITE_EXP_NODES_TABLE%% where local_relpath != ''%%SQLITE_EXP_REVISION_RANGE_SUFFIX%%) select %%SQLITE_EXP_SELECT_CMD_LINE%%order by local_relpath_new asc"
