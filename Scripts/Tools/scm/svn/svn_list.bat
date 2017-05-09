@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script do SVN list with additional functionality like offline mode.

rem Examples:
rem 1. pushd "..." && ( call svn_list.bat -offline -R branch/current > files.lst & popd )

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~nx0=%~nx0"

rem script flags
set FLAG_SVN_OFFLINE=0
set ARG_SVN_REVISION_RANGE_IS_SET=0
set "ARG_SVN_REVISION_RANGE="
set ARG_SVN_WCROOT=0
set "ARG_SVN_WCROOT_PATH="

rem svn flags
set "SVN_CMD_FLAG_ARGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-offline" (
    set FLAG_SVN_OFFLINE=1
  ) else if "%FLAG%" == "-r" (
    rem consume next argument into flags
    set ARG_SVN_REVISION_RANGE_IS_SET=1
    set "ARG_SVN_REVISION_RANGE=%~2"
    set SVN_CMD_FLAG_ARGS=%SVN_CMD_FLAG_ARGS%%1 %2
    shift
  ) else if "%FLAG%" == "-wcroot" (
    set ARG_SVN_WCROOT=1
    set "ARG_SVN_WCROOT_PATH=%~2"
    shift
  ) else (
    set SVN_CMD_FLAG_ARGS=%SVN_CMD_FLAG_ARGS%%1 
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

if %ARG_SVN_REVISION_RANGE_IS_SET% NEQ 0 ^
if "%ARG_SVN_REVISION_RANGE%" == "" (
  echo.%?~nx0%: error: revision range is not set.
  exit /b 253
) >&2

:ARGSN_LOOP
if not "%~1" == "" (
  set SVN_CMD_FLAG_ARGS=%SVN_CMD_FLAG_ARGS%%1 
  shift
  goto ARGSN_LOOP
)

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
  echo.%?~nx0%: error: SVN WC root path must be absolute and current directory path must be descendant to the SVN WC root path: SVN_WCROOT_PATH="%SVN_WCROOT_PATH%" CD="%CD%".
  exit /b 250
) >&2

if not "%SVN_BRANCH_REL_SUB_PATH%" == "" set "SVN_BRANCH_REL_SUB_PATH=%SVN_BRANCH_REL_SUB_PATH:\=/%"

exit /b 0

:TEST_WCROOT_PATH_END

if %ARG_SVN_WCROOT% NEQ 0 goto CHECK_WCROOT_PATH_DB
if %FLAG_SVN_OFFLINE% NEQ 0 goto CHECK_WCROOT_PATH_DB

goto CHECK_WCROOT_PATH_DB_END

:CHECK_WCROOT_PATH_DB
if not exist "%SVN_WCROOT_PATH%\.svn\wc.db" (
  echo.%?~nx0%: error: SVN WC database file is not found: "%SVN_WCROOT_PATH%\.svn\wc.db"
  exit /b 249
) >&2

:CHECK_WCROOT_PATH_DB_END

if %FLAG_SVN_OFFLINE% NEQ 0 (
  if /i not "%SVN_WCROOT_PATH%" == "%CD%" (
    pushd "%SVN_WCROOT_PATH%" && (
      call :IMPL
      popd
    )
  ) else call :IMPL
) else call :IMPL

exit /b

:IMPL

rem parse -r argument value
set "SQLITE_EXP_REVISION_RANGE_SUFFIX="
if %ARG_SVN_REVISION_RANGE_IS_SET% NEQ 0 call "%%SVNCMD_TOOLS_ROOT%%/impl/svn_arg_parse-r.bat" "%%ARG_SVN_REVISION_RANGE%%"
if not "%SQLITE_EXP_REVISION_RANGE%" == "" set "SQLITE_EXP_REVISION_RANGE_SUFFIX= and (%SQLITE_EXP_REVISION_RANGE%)"

rem filter output only for the current directory path
set "SQLITE_EXP_SELECT_CMD_LINE=* from new_nodes "
if %FLAG_SVN_OFFLINE% NEQ 0 ^
if %ARG_SVN_WCROOT% NEQ 0 (
  if not "%SVN_BRANCH_REL_SUB_PATH%" == "" (
    set "SQLITE_EXP_SELECT_CMD_LINE=substr(local_relpath_new, length('%SVN_BRANCH_REL_SUB_PATH%/')+1) as local_relpath_new_suffix from new_nodes where substr(local_relpath_new, 1, length('%SVN_BRANCH_REL_SUB_PATH%/')) == '%SVN_BRANCH_REL_SUB_PATH%/' collate nocase and local_relpath_new_suffix != '' "
  )
)

if %FLAG_SVN_OFFLINE% NEQ 0 (
  call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch ".svn/wc.db" ".headers off" "with new_nodes as ( select case when kind != 'dir' then local_relpath else local_relpath || '/' end as local_relpath_new from nodes_base where local_relpath != ''%%SQLITE_EXP_REVISION_RANGE_SUFFIX%% and presence != 'not-present') select %%SQLITE_EXP_SELECT_CMD_LINE%%order by local_relpath_new asc"
) else (
  svn ls %SVN_CMD_FLAG_ARGS%
)
