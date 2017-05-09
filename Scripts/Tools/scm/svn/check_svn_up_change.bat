@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script generates changesets difference file, prints it and returns
rem   code representing changesets difference state.
rem   Return codes:
rem    -1 - no changes
rem    0  - has changes
rem    127 - difference error

rem Examples:
rem 1. call check_svn_up_change.bat svn_changeset1.lst svn_changeset2.lst
rem    type svn_changesets_diff.lst

setlocal

set "UPSTREAM_SVN_CHANGESET=%~dpf1"
set "DOWNSTREAM_SVN_CHANGESET=%~dpf2"

set "DOWNSTREAM_SVN_CHANGESETS_DIFF_DIR=%~dp2"
set "DOWNSTREAM_SVN_CHANGESETS_DIFF_FILE=svn_changesets_diff.lst"
set "DOWNSTREAM_SVN_CHANGESETS_DIFF=%DOWNSTREAM_SVN_CHANGESETS_DIFF_DIR%%DOWNSTREAM_SVN_CHANGESETS_DIFF_FILE%"

if not exist "%UPSTREAM_SVN_CHANGESET%" (
  echo.%~nx0: error: upstream svn changeset file does not exist: "%UPSTREAM_SVN_CHANGESET%".>&2
  exit /b 1
)

if /i "%UPSTREAM_SVN_CHANGESET%" == "%DOWNSTREAM_SVN_CHANGESET%" (
  echo.%~nx0: error: upstream and downstream svn changeset files must be at least in different directories: "%UPSTREAM_SVN_CHANGESET%".>&2
  exit /b 2
)

if not exist "%DOWNSTREAM_SVN_CHANGESET%" (
  echo.%~nx0: warning: downstream svn changeset file is not found, treat downsteam as required to be built.>&2
  exit /b 0
)

rem Drop last error level
cd .

call "%%~dp0__init__.bat" || goto :EOF

call "%%SVNCMD_TOOLS_ROOT%%/gen_diff_svn_changeset_lst.bat" "%%UPSTREAM_SVN_CHANGESET%%" "%%DOWNSTREAM_SVN_CHANGESET%%" "%%DOWNSTREAM_SVN_CHANGESETS_DIFF%%"
set LASTERROR=%ERRORLEVEL%
if %LASTERROR% LSS 0 (
  echo.%~nx0: info: upstream and downstream svn changesets has changes.
) else if %LASTERROR% GTR 0 (
  echo.%~nx0: warning: build is stopped because of previous errors.>&2
  exit /b 127
) else (
  echo.%~nx0: info: build is not required.
  exit /b -1
)

call "%%SVNCMD_TOOLS_ROOT%%/print_svn_changesets_diff_lst.bat" "%%DOWNSTREAM_SVN_CHANGESETS_DIFF%%"
set LASTERROR=%ERRORLEVEL%
if %LASTERROR% NEQ 0 (
  echo.%~nx0: warning: build is stopped because of previous errors.>&2
  exit /b 127
)

exit /b 0
