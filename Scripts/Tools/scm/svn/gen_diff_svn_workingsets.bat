@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Svn changeset generation script from 2 workingsets (external+revision list).
rem   Generate CSV file with not sorted differences between 2 SVN workingset
rem   lists and returns:
rem     > 0 if changeset has errors.
rem     = 0 if changeset has differences.
rem     < 0 if changeset has no differences.

rem   Changeset file per line format:
rem   <S>|<repo>|<rev>|<prev>
rem   , where:
rem     <S> - status of repository revision:
rem       " " - no changes;
rem       "*" - revision changed;
rem       "+" - repository added;
rem       "-" - repository removed.
rem     <repo> - repository path
rem     <rev> - repository new or current (depends on status) revision
rem     <prev> - repository previous or last (depends on status) revision

rem Examples:
rem 1. call gen_diff_svn_workingsets.bat svn_workingset1.lst svn_workingset2.lst svn_changeset.lst
rem    type svn_changeset.lst

rem Drop last error level
cd .

rem enable delayed expansion to speed overall code iterations
setlocal ENABLEDELAYEDEXPANSION

set "SVN_WORKINGSET_NEXT=%~1"
set "SVN_WORKINGSET_PREV=%~2"
set "SVN_WORKINGSET_DIFF=%~3"

if not exist "!SVN_WORKINGSET_NEXT!" (
  echo.%~nx0: error: svn next workingset file does not exist: "!SVN_WORKINGSET_NEXT!"
  exit /b 1
) >&2

if not exist "!SVN_WORKINGSET_PREV!" (
  echo.%~nx0: error: svn prev workingset file does not exist: "!SVN_WORKINGSET_PREV!"
  exit /b 2
) >&2

rem drop output difference file
del /F /Q /A:-D "!SVN_WORKINGSET_DIFF!" 2>nul
if exist "!SVN_WORKINGSET_DIFF!" (
  echo.%~nx0: error: svn workingsets differences file could not be recreated: "!SVN_WORKINGSET_DIFF!"
  exit /b 3
) >&2

rem load workingset lines into variables to speed up overall code interations
set "LOAD_SVN_WORKINGSET=!SVN_WORKINGSET_NEXT!"
set "SVN_WORKINGSET_LINE_VAR_PREFIX=SVN_WORKINGSET_NEXT_LINE_"
set "SVN_WORKINGSET_NUM_LINES_VAR=SVN_WORKINGSET_NEXT_LINES"
set LASTERROR=0
call :LOAD_SVN_WORKINGSET

if !LASTERROR! NEQ 0 (
  echo.%~nx0: error: svn next workingset file is broken: "!SVN_WORKINGSET_NEXT!"
  exit /b !LASTERROR!
) >&2

set "LOAD_SVN_WORKINGSET=!SVN_WORKINGSET_PREV!"
set "SVN_WORKINGSET_LINE_VAR_PREFIX=SVN_WORKINGSET_PREV_LINE_"
set "SVN_WORKINGSET_NUM_LINES_VAR=SVN_WORKINGSET_PREV_LINES"
set LASTERROR=0
call :LOAD_SVN_WORKINGSET

if !LASTERROR! NEQ 0 (
  echo.%~nx0: error: svn previous workingset file is broken: "!SVN_WORKINGSET_PREV!"
  exit /b !LASTERROR!
) >&2

set WORKINGSETS_HAS_CHANGES=0

rem make next one workingset a left one, search for changed and added
set SVN_WORKINGSET_SEARCH_T=0
set SVN_WORKINGSET_L_LINE_VAR=SVN_WORKINGSET_NEXT_LINE_
set SVN_WORKINGSET_R_LINE_VAR=SVN_WORKINGSET_PREV_LINE_
set SVN_WORKINGSET_L_LINES_VAR=SVN_WORKINGSET_NEXT_LINES
set SVN_WORKINGSET_R_LINES_VAR=SVN_WORKINGSET_PREV_LINES

call :PROCESS_WORKINGSET_L

rem make previous one workingset a left one, search for removed only
set SVN_WORKINGSET_SEARCH_T=1
set SVN_WORKINGSET_L_LINE_VAR=SVN_WORKINGSET_PREV_LINE_
set SVN_WORKINGSET_R_LINE_VAR=SVN_WORKINGSET_NEXT_LINE_
set SVN_WORKINGSET_L_LINES_VAR=SVN_WORKINGSET_PREV_LINES
set SVN_WORKINGSET_R_LINES_VAR=SVN_WORKINGSET_NEXT_LINES

call :PROCESS_WORKINGSET_L

if !WORKINGSETS_HAS_CHANGES! EQU 0 exit /b -1

exit /b 0

:PROCESS_WORKINGSET_L
set FOR_L_INDEX=1
:PROCESS_WORKINGSET_L_FOR_LOOP
call :PROCESS_LINE_WORKINGSET_L || goto :EOF
set /A FOR_L_INDEX+=1
if !FOR_L_INDEX! GTR !%SVN_WORKINGSET_L_LINES_VAR%! exit /b 0
goto PROCESS_WORKINGSET_L_FOR_LOOP

:PROCESS_LINE_WORKINGSET_L
set "L_REPO="
set "L_REV="
set "SVN_WORKINGSET_L_LINE=!%SVN_WORKINGSET_L_LINE_VAR%%FOR_L_INDEX%!"
for /F "eol=# tokens=1,2 delims=|" %%i in ("!SVN_WORKINGSET_L_LINE!") do (
  set "L_REPO=%%i"
  set "L_REV=%%j"
)

set WORKINGSET_REPO_FOUND=0
set WORKINGSET_REV_CHANGED=0

rem echo.!L_REPO!^|!L_REV!

call :PROCESS_WORKINGSET_R

if !SVN_WORKINGSET_SEARCH_T! EQU 0 (
  if !WORKINGSET_REPO_FOUND! NEQ 0 (
    if !WORKINGSET_REV_CHANGED! EQU 0 (
      (echo. ^|!L_REPO!^|!L_REV!^|0)>>"!SVN_WORKINGSET_DIFF!"
    ) else (
      set WORKINGSETS_HAS_CHANGES=1
      (echo.^*^|!L_REPO!^|!L_REV!^|!R_REV!)>>"!SVN_WORKINGSET_DIFF!"
    )
  ) else if not "!L_REPO!" == "" (
    set WORKINGSETS_HAS_CHANGES=1
    (echo.+^|!L_REPO!^|!L_REV!^|0)>>"!SVN_WORKINGSET_DIFF!"
  )
) else if not "!R_REPO!" == "" (
  if !WORKINGSET_REPO_FOUND! EQU 0 (
    set WORKINGSETS_HAS_CHANGES=1
    (echo.-^|!L_REPO!^|0^|!L_REV!)>>"!SVN_WORKINGSET_DIFF!"
  )
)

exit /b 0

:PROCESS_WORKINGSET_R
set FOR_R_INDEX=1
:PROCESS_WORKINGSET_R_FOR_LOOP
call :PROCESS_LINE_WORKINGSET_R || goto :EOF
set /A FOR_R_INDEX+=1
if !FOR_R_INDEX! GTR !%SVN_WORKINGSET_R_LINES_VAR%! exit /b 0
goto PROCESS_WORKINGSET_R_FOR_LOOP

:PROCESS_LINE_WORKINGSET_R
set "R_REPO="
set "R_REV="
set "SVN_WORKINGSET_R_LINE=!%SVN_WORKINGSET_R_LINE_VAR%%FOR_R_INDEX%!"
for /F "eol=# tokens=1,2 delims=|" %%i in ("!SVN_WORKINGSET_R_LINE!") do (
  set "R_REPO=%%i"
  set "R_REV=%%j"
)

rem case sensitive compare!
if "!L_REPO!" == "!R_REPO!" (
  set WORKINGSET_REPO_FOUND=1
  if !L_REV! NEQ !R_REV! set WORKINGSET_REV_CHANGED=1
  exit /b -1
)

exit /b 0

:LOAD_SVN_WORKINGSET
set SVN_WORKINGSET_INDEX=0
for /F "eol=# tokens=1,2 delims=|" %%i in (!LOAD_SVN_WORKINGSET!) do (
  set "REPO=%%i"
  set "REV=%%j"
  call :LOAD_LINE_SVN_WORKINGSET || goto :EOF
)
set "!SVN_WORKINGSET_NUM_LINES_VAR!=!SVN_WORKINGSET_INDEX!"
exit /b 0

:LOAD_LINE_SVN_WORKINGSET
if "!REPO!" == "" ( set "LASTERROR=1" && exit /b 1 )
if "!REV!" == "" ( set "LASTERROR=2" && exit /b 1 )
if !REV! LSS 0 ( set "LASTERROR=3" && exit /b 1 )

set /A SVN_WORKINGSET_INDEX+=1

set "%SVN_WORKINGSET_LINE_VAR_PREFIX%!SVN_WORKINGSET_INDEX!=!REPO!|!REV!"

exit /b 0
