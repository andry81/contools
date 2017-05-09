@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Svn changesets differences file print script.
rem   Print generated differences CSV file between 2 SVN changesets in sorted
rem   mode (first - removed, second - added, third - changed w/ revision
rem   decrease (revert), forth - changed w/ revision increase (update),
rem   last - unchanged).

rem Example of input CSV differences file:
rem *|https://repo1/svn/proj1|111|110
rem +|https://repo2/svn/proj2|222|
rem -|https://repo3/svn/proj3|0|333
rem  |https://repo4/svn/proj4|444|
rem *|https://repo5/svn/proj5|200|300

rem Result print:
rem SVN changesets differences:
rem ---+-------------------------+------+------
rem  S | repository              | rev  | prev
rem ---+-------------------------+------+------
rem  - | https://repo3/svn/proj3 |      | 333
rem  + | https://repo2/svn/proj2 | 222  |
rem !* | https://repo5/svn/proj5 | 200  | 300!
rem  * | https://repo1/svn/proj1 | 111  | 110
rem    | https://repo4/svn/proj4 | 444  |
rem ---+-------------------------+------+------
rem Legend: "*" - revision changed; "+" - added; "-" - removed
rem Status: 4 of 5 changes (2 changed, 1 added, 1 removed, 1 unchanged)
rem ===========================================

rem Examples:
rem 1. call print_svn_changesets_diff_lst.bat svn_changesets_diff.lst

rem Drop last error level
cd .

setlocal

set "SVN_CHANGESETS_DIFF=%~1"

if not exist "%SVN_CHANGESETS_DIFF%" (
  echo.%~nx0: error: svn changeset difference file does not exist: "%SVN_CHANGESETS_DIFF%"
  exit /b -128
) >&2

set "?1=^|"

call "%%~dp0__init__.bat" || goto :EOF

set REPO_MAXLEN=0
call :LOAD_SVN_CHANGESETS_DIFF

rem 80 is max length
if %REPO_MAXLEN% GTR 80 set REPO_MAXLEN=80

rem 10 is min
if %REPO_MAXLEN% LSS 10 set REPO_MAXLEN=10

set "REPO_MAXSPACES=                                                                                "
set "REV_MAXSPACES=       "
set "REPO_HEADER=repository                                                                      "
set "REPEAT_CHAR1=--------------------------------------------------------------------------------"
set "REPEAT_CHAR2================================================================================="

rem update max spaces
call set "REPO_MAXSPACES=%%REPO_MAXSPACES:~0,%REPO_MAXLEN%%%"

set NUM_OVERALL=0
set NUM_CHANGES=0
set NUM_CHANGED=0
set NUM_ADDED=0
set NUM_REMOVED=0
set NUM_UNCHANGED=0

call echo.---+-%%REPEAT_CHAR1:~0,%REPO_MAXLEN%%%-+---------+---------
call echo. S %%?1%% %%REPO_HEADER:~0,%REPO_MAXLEN%%% %%?1%%     rev %%?1%%    prev
call echo.---+-%%REPEAT_CHAR1:~0,%REPO_MAXLEN%%%-+---------+---------

call :PRINT_SVN_CHANGESET -
call :PRINT_SVN_CHANGESET +
call :PRINT_SVN_CHANGESET * 1
call :PRINT_SVN_CHANGESET * 0
call :PRINT_SVN_CHANGESET " "

set /A "NUM_OVERALL=NUM_CHANGES+NUM_UNCHANGED"

if %NUM_OVERALL% EQU 0 echo.     ^*empty^*

call echo.---+-%%REPEAT_CHAR1:~0,%REPO_MAXLEN%%%-+---------+---------
echo.Legend: "*" - revision changed; "+" - added; "-" - removed
echo.Status: %NUM_CHANGES% of %NUM_OVERALL% changes ^(%NUM_CHANGED% changed, %NUM_ADDED% added, %NUM_REMOVED% removed, %NUM_UNCHANGED% unchanged^)
call echo.=====%%REPEAT_CHAR2:~0,%REPO_MAXLEN%%%=====================

exit /b 0

:PRINT_SVN_CHANGESET
set "STATUS=%~1"
set "REV_DEC=%~2"

set FOR_INDEX=1
:PRINT_SVN_CHANGESET_FOR_LOOP
call :PRINT_LINE_SVN_CHANGESET || goto :EOF
set /A FOR_INDEX+=1
if %FOR_INDEX% GTR %SVN_CHANGESETS_DIFF_NUM_LINES% exit /b 0
goto PRINT_SVN_CHANGESET_FOR_LOOP

:PRINT_LINE_SVN_CHANGESET
call set "SVN_CHANGESETS_DIFF_LINE=%%SVN_CHANGESETS_DIFF_LINE_%FOR_INDEX%%%"
for /F "eol=# delims=| tokens=1,2,3,4" %%i in ("%SVN_CHANGESETS_DIFF_LINE%") do (
  set "S=%%i"
  set "REPO=%%j"
  set "REV=%%k"
  set "PREV=%%l"
)

rem remove all spaces
set "REV=%REV: =%"
set "PREV=%PREV: =%"

if not "%S%" == "%STATUS%" exit /b 0

if "%STATUS%" == "*" (
  if %REV_DEC%0 EQU 0 (
    if %PREV%0 GTR %REV%0 exit /b 0
  ) else (
    if %REV%0 GTR %PREV%0 exit /b 0
  )
)

if not "%STATUS%" == " " set /A NUM_CHANGES+=1
if "%STATUS%" == "*" set /A NUM_CHANGED+=1
if "%STATUS%" == "+" set /A NUM_ADDED+=1
if "%STATUS%" == "-" set /A NUM_REMOVED+=1
if "%STATUS%" == " " set /A NUM_UNCHANGED+=1

call "%%CONTOOLS_ROOT%%/strlen.bat" "" "%%REPO%%"
set REPO_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/strlen.bat" "" "%%REV%%"
set REV_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/strlen.bat" "" "%%PREV%%"
set PREV_LEN=%ERRORLEVEL%

call set "REPO_SPACES=%%REPO_MAXSPACES:~%REPO_LEN%%%"
call set "REV_SPACES=%%REV_MAXSPACES:~%REV_LEN%%%"
call set "PREV_SPACES=%%REV_MAXSPACES:~%PREV_LEN%%%"

if %REV_DEC%0 EQU 0 (
  echo. ^%S% ^| %REPO%%REPO_SPACES% ^| %REV_SPACES%%REV% ^| %PREV_SPACES%%PREV%
) else (
  echo.!^%S% ^| %REPO%%REPO_SPACES% ^| %REV_SPACES%%REV% ^| %PREV_SPACES%%PREV%^!
)

exit /b 0

:LOAD_SVN_CHANGESETS_DIFF
set SVN_CHANGESET_DIFF_INDEX=0
for /F "eol=# delims=| tokens=1,2,3,4" %%i in (%SVN_CHANGESETS_DIFF%) do ( call :LOAD_LINE_SVN_CHANGESETS_DIFF "%%i" "%%j" "%%k" "%%l" || goto :EOF )
set "SVN_CHANGESETS_DIFF_NUM_LINES=%SVN_CHANGESET_DIFF_INDEX%"
exit /b 0

:LOAD_LINE_SVN_CHANGESETS_DIFF
set "S=%~1"
set "REPO=%~2"
set "REV=%~3"
set "PREV=%~4"

call "%%CONTOOLS_ROOT%%/strlen.bat" "" "%%REPO%%"
set REPO_LEN=%ERRORLEVEL%
if %REPO_LEN% GTR %REPO_MAXLEN% set REPO_MAXLEN=%REPO_LEN%

set /A SVN_CHANGESET_DIFF_INDEX+=1

set "SVN_CHANGESETS_DIFF_LINE_%SVN_CHANGESET_DIFF_INDEX%=%~1|%~2|%~3|%~4"

exit /b 0
