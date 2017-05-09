@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script recursively synchronizes branch information like SVN diff/externals
rem   and restores branch into state which has been when workingset has
rem   generated.

rem   Not recursive externals format:
rem     [-r[ ]<BRANCH_EXTERNAL_URI_REV_OPERATIVE>] <BRANCH_EXTERNAL_URI_PATH>[@<BRANCH_EXTERNAL_URI_REV_PEG>] <BRANCH_EXTERNAL_DIR_PATH>
rem

rem   Recursive externals format:
rem     [<BRANCH_EXTERNAL_DIR_PATH_PREFIX> -] [[-r[ ]<BRANCH_EXTERNAL_URI_REV_OPERATIVE>] <BRANCH_EXTERNAL_URI_PATH>[@<BRANCH_EXTERNAL_URI_REV_PEG>] <BRANCH_EXTERNAL_DIR_PATH>]
rem     , where <BRANCH_EXTERNAL_DIR_PATH_PREFIX> - relative to the current directory
rem 

rem Flags:
rem  -R - update root externals recursively.
rem  -r - checkout/relocate/switch/revert/update all branch directories (recursively or not) w/o flag --ignore-externals.
rem       If set then the script will synchronize a parent branch state with children branches through the svn.exe call only.
rem       If not set, then the script will sychronize parent-children databases itself by the wc.db direct access.
rem  -fresh - remove root branch directory content before checkout it.
rem  -ac - auto cleanup all branches before relocate/switch/revert/update to mainly remove all locks.
rem  -ar - auto revert any branch changes.
rem  -as - auto switch to URL from workingset if previous is different (relative path change).
rem  -fs - force switch from URL w/o common version control ancestry with the requested switch location (see error E195012 and --ignore-ancestry svn.exe flag)
rem  -arloc - auto relocate to URL from workingset if previous is different (repository location change).

rem Examples:
rem 1. call sync_branch_workingset.bat -R branch/current root_info.txt root_diff.patch root_externals.lst workingset.lst workingset
rem    svn info branch/current > root_info_synced.txt
rem    svn diff branch/current > root_diff_synced.patch
rem    svn pget svn:externals branch/current -R > root_externals_synced.lst
rem    dir branch/current /S > dir_branch_synched.txt

rem KNOWN ISSUES:
rem 1. By default, script won't synchronize externals to the workingset and auto cleanup/revert/switch/relocate working copy before synchronization.
rem    You have to explicitly pass -R/-ac/-ar/-as/arloc flags respectively to enable that logic.
rem 2. If the -r flag is not set (--ignore-externals is not used), then the script will leave renamed/removed external directories intact in the working copy,
rem    because script does not implement external directories explicit remove in this case.
rem 3. Versioned directories should not begin by the #-character, because it is used to mark directories as externals, otherwise synchronization may throw errors.
rem    Versioned files should not be the files $info.txt, $changeset.lst, $diff.patch, $diff_copy.lst, $diff_added.lst, $diff_removed.lst, $externals.lst, $files.lst, $status.txt,
rem    because they are used to store svn.exe output information, otherwise the script may throw errors.

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set FLAG_SVN_EXTERNALS_RECURSIVE=0
set "FLAG_SVN_EXTERNALS_PROPGET="
set "FLAG_TEXT_SVN_IGNORE_EXTERNALS=--ignore-externals"
set FLAG_SVN_IGNORE_EXTERNALS=1
set FLAG_SVN_FRESH_CHECKOUT=0
set FLAG_SVN_AUTO_CLEANUP=0
set FLAG_SVN_AUTO_REVERT=0
set FLAG_SVN_AUTO_SWITCH=0
set FLAG_SVN_FORCE_SWITCH=0
set "FLAG_TEXT_SVN_IGNORE_ANCESTRY="
set FLAG_SVN_AUTO_RELOCATE=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-R" (
    set FLAG_SVN_EXTERNALS_RECURSIVE=1
    set "FLAG_SVN_EXTERNALS_PROPGET=-R"
    shift
  ) else if "%FLAG%" == "-r" (
    set FLAG_SVN_IGNORE_EXTERNALS=0
    set "FLAG_TEXT_SVN_IGNORE_EXTERNALS="
    shift
  ) else (
    if "%FLAG%" == "-fresh" (
      set FLAG_SVN_FRESH_CHECKOUT=1
      shift
    ) else (
      if "%FLAG%" == "-ac" (
        set FLAG_SVN_AUTO_CLEANUP=1
        shift
      ) else if "%FLAG%" == "-ar" (
        set FLAG_SVN_AUTO_REVERT=1
        shift
      ) else if "%FLAG%" == "-arloc" (
        set FLAG_SVN_AUTO_RELOCATE=1
        shift
      ) else if "%FLAG%" == "-as" (
        set FLAG_SVN_AUTO_SWITCH=1
        shift
      ) else if "%FLAG%" == "-fs" (
        set FLAG_SVN_FORCE_SWITCH=1
        set "FLAG_TEXT_SVN_IGNORE_ANCESTRY=--ignore-ancestry"
        shift
      ) else (
        echo.%?~nx0%: error: invalid flag: %FLAG%
        exit /b -255
      ) >&2
    )
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "BRANCH_PATH=%~1"

if "%BRANCH_PATH%" == "" (
  echo.%?~nx0%: error: BRANCH_PATH is not set.
  exit /b 1
)

rem Is branch URI in canonical URI form?
if not "%BRANCH_PATH:://=%" == "%BRANCH_PATH%" (
  echo.%?~nx0%: error: BRANCH_PATH should be in local file form ONLY.
  exit /b 2
)

if not exist "%BRANCH_PATH%" (
  echo.%?~nx0%: error: BRANCH_PATH does not exist: "%BRANCH_PATH%"
  exit /b 3
) >&2

rem use canonical file form
set "BRANCH_PATH=%~dpf1"

rem convert all back slashes to slashes
set "BRANCH_PATH=%BRANCH_PATH:\=/%"
if "%BRANCH_PATH:~-1%" == "/" set "BRANCH_PATH=%BRANCH_PATH:~0,-1%"

set "BRANCH_ROOT_INFO_FILE=%~dpf2"
set "BRANCH_ROOT_CHANGESET_FILE=%~dpf3"
set "BRANCH_ROOT_DIFF_FILE=%~dpf4"
set "BRANCH_ROOT_EXTERNALS_FILE=%~dpf5"

set "BRANCH_WORKINGSET_FILE=%~dpf6"
set "BRANCH_WORKINGSET_CATALOG_DIR=%~dpf7"

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "SYNC_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "SYNC_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "SYNC_BRANCH_TEMP_FILE_DIR=%TEMP%\%?~n0%.%SYNC_DATE%.%SYNC_TIME%"
set "BRANCH_INFO_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$info.txt"
set "BRANCH_DIFF_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$diff.patch"
set "BRANCH_FROM_EXTERNALS_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$externals_from.txt"
set "BRANCH_FROM_EXTERNALS_LIST_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$externals_from.lst"
set "BRANCH_EXTERNALS_DIFF_LIST_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$externals_diff.lst"
set "BRANCH_FILES_FILE_TMP=%SYNC_BRANCH_TEMP_FILE_DIR%\$files.lst"

rem create temporary files to store local context output
if exist "%SYNC_BRANCH_TEMP_FILE_DIR%" (
  echo.%?~nx0%: error: temporary generated directory SYNC_BRANCH_TEMP_FILE_DIR already exist: "%SYNC_BRANCH_TEMP_FILE_DIR%"
  exit /b 4
)

mkdir "%SYNC_BRANCH_TEMP_FILE_DIR%"

rem have to set a current directory for shortened path values in output from svn commands
pushd "%BRANCH_PATH%" && (
  call :MAIN
  popd
)
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%SYNC_BRANCH_TEMP_FILE_DIR%"

exit /b %LASTERROR%

:MAIN

if not exist  "%BRANCH_WORKINGSET_FILE%" (
  echo.%?~nx0%: error: BRANCH_WORKINGSET_FILE does not exist: "%BRANCH_WORKINGSET_FILE%".
  exit /b 5
)

if not exist "%BRANCH_WORKINGSET_CATALOG_DIR%\" (
  echo.%?~nx0%: error: BRANCH_WORKINGSET_CATALOG_DIR does not exist: "%BRANCH_WORKINGSET_CATALOG_DIR%"
  exit /b 6
)

rem convert back slashes to forward slashes
set "BRANCH_WORKINGSET_FILE=%BRANCH_WORKINGSET_FILE:\=/%"
set "BRANCH_WORKINGSET_CATALOG_DIR=%BRANCH_WORKINGSET_CATALOG_DIR:\=/%"

set "SYNC_BRANCH_FLAGS="

echo.Synchronizing branch by workingset root...
echo.  Branch  : "%BRANCH_PATH%"
echo.  File    : "%BRANCH_WORKINGSET_FILE%"
echo.  Catalog : "%BRANCH_WORKINGSET_CATALOG_DIR%"
if %FLAG_SVN_EXTERNALS_RECURSIVE% NEQ 0 set set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%Recursively "
if %FLAG_SVN_IGNORE_EXTERNALS% EQU 0 set set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%DoubleRecursively "
if %FLAG_SVN_FRESH_CHECKOUT% NEQ 0 set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%Fresh "
if %FLAG_SVN_AUTO_CLEANUP% NEQ 0 set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%AutoCleanup "
if %FLAG_SVN_AUTO_REVERT% NEQ 0 set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%AutoRevert "
if %FLAG_SVN_AUTO_SWITCH% NEQ 0 set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%AutoSwitch "
if %FLAG_SVN_AUTO_RELOCATE% NEQ 0 set "SYNC_BRANCH_FLAGS=%SYNC_BRANCH_FLAGS%AutoRelocate "
echo.  Flags   : %SYNC_BRANCH_FLAGS%

set SYNC_BRANCH_IS_ROOT=1

set BRANCH_ROOT_INFO_FILE_EXIST=0
if exist "%BRANCH_ROOT_INFO_FILE%" set BRANCH_ROOT_INFO_FILE_EXIST=1

set BRANCH_ROOT_DIFF_FILE_EXIST=0
if exist "%BRANCH_ROOT_DIFF_FILE%" set BRANCH_ROOT_DIFF_FILE_EXIST=1

set /A BRANCH_ROOT_FILES_EXIST_COUNTER=%BRANCH_ROOT_INFO_FILE_EXIST%+%BRANCH_ROOT_DIFF_FILE_EXIST%

if %BRANCH_ROOT_FILES_EXIST_COUNTER% GTR 0 ^
if %BRANCH_ROOT_FILES_EXIST_COUNTER% LSS 2 (
  echo.%?~nx0%: error: BRANCH_ROOT_INFO_FILE and BRANCH_ROOT_DIFF_FILE are not consistent: INFO_FILE="%BRANCH_ROOT_INFO_FILE%" DIFF_FILE="%BRANCH_ROOT_DIFF_FILE%".
  exit /b 7
)

if %BRANCH_ROOT_FILES_EXIST_COUNTER% EQU 0 goto SYNC_WORKINGSET

rem check branch repo relative path on equivalence with workingset branch repo relative path
rem (workingset branch consistency/compatability check, for example, if repository has been moved after workingset creation)
set "BRANCH_INFO_FILE=%BRANCH_ROOT_INFO_FILE%"
set "BRANCH_CHANGESET_FILE=%BRANCH_ROOT_CHANGESET_FILE%"
set "BRANCH_DIFF_FILE=%BRANCH_ROOT_DIFF_FILE%"
set "BRANCH_EXTERNALS_FILE=%BRANCH_ROOT_EXTERNALS_FILE%"

set SYNC_BRANCH_PATH=.

call :SYNC_BRANCH || exit /b

set SYNC_BRANCH_IS_ROOT=0

:SYNC_WORKINGSET
rem Remove --ignore-externals in svn commands to root branch externals if -R was not set.
rem This will leave nested externals in not synchronized state to the workingset but consistent
rem with revisions of root branch externals.
if %FLAG_SVN_EXTERNALS_RECURSIVE% EQU 0 (
  set FLAG_SVN_IGNORE_EXTERNALS=0
  set "FLAG_TEXT_SVN_IGNORE_EXTERNALS="
)

echo.Synchronizing branch by workingset recursively...

rem read and apply workingset file line by line for recursive externals

for /F "usebackq eol=# tokens=4,5,6,7 delims=|" %%i in ("%BRANCH_WORKINGSET_FILE%") do (
  set "SYNC_BRANCH_DECORATED_PATH=%%i"
  set "SYNC_BRANCH_URI=%%j"
  set "SYNC_BRANCH_EXTERNAL_URI_REV_PEG=%%k"
  set "SYNC_BRANCH_EXTERNAL_URI_REV_OPERATIVE=%%l"
  call :SYNC_BRANCH_WORKINGSET_LINE || exit /b
)

exit /b 0

:SYNC_BRANCH_WORKINGSET_LINE
if "%SYNC_BRANCH_DECORATED_PATH%" == "" (
  echo.%?~nx0%: error: found empty branch path in workingset.
  exit /b 10
)

if "%SYNC_BRANCH_URI%" == "" (
  echo.%?~nx0%: error: found empty branch uri in workingset.
  exit /b 11
)

rem ignore not root branch repository paths if -R flag was not set
if %FLAG_SVN_EXTERNALS_RECURSIVE% EQU 0 ^
if not "%SYNC_BRANCH_DECORATED_PATH::=%" == "%SYNC_BRANCH_DECORATED_PATH%" exit /b 0

echo.  %SYNC_BRANCH_DECORATED_PATH%^|%SYNC_BRANCH_URI%

rem translate workingset branch path into workingset catalog unreduced path
set "SYNC_BRANCH_UNREDUCED_PATH=%SYNC_BRANCH_DECORATED_PATH::#=/%"
set "SYNC_BRANCH_UNREDUCED_PATH=%SYNC_BRANCH_UNREDUCED_PATH::=/%"

set "SYNC_BRANCH_REDUCED_PATH=%SYNC_BRANCH_DECORATED_PATH:/=--%"
set "SYNC_BRANCH_REDUCED_PATH=%SYNC_BRANCH_REDUCED_PATH::=/%"

if "%SYNC_BRANCH_UNREDUCED_PATH:~0,1%" == "#" set "SYNC_BRANCH_UNREDUCED_PATH=%SYNC_BRANCH_UNREDUCED_PATH:~1%"

rem have to set a current directory for relative path values
if not exist "%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%" (
  echo.%?~nx0%: error: could not synchronize branch from non existen workingset catalog directory: BRANCH_PATH="%SYNC_BRANCH_UNREDUCED_PATH%" CATALOG_DIR="%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%".
  exit /b 20
)

set "BRANCH_INFO_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%/$info.txt"
if not exist "%BRANCH_INFO_FILE%" (
  echo.%?~nx0%: error: info file required for branch synchronization is not found: BRANCH_PATH="%SYNC_BRANCH_UNREDUCED_PATH%" BRANCH_INFO_FILE="%BRANCH_INFO_FILE%".
  exit /b 21
)

set "BRANCH_EXTERNALS_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%/$externals.lst"
if not exist "%BRANCH_EXTERNALS_FILE%" (
  echo.%?~nx0%: error: externals file required for branch synchronization is not found: BRANCH_PATH="%SYNC_BRANCH_UNREDUCED_PATH%" BRANCH_EXTERNALS_FILE="%BRANCH_EXTERNALS_FILE%".
  exit /b 22
)

set "BRANCH_CHANGESET_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%/$changeset.lst"

set "BRANCH_DIFF_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%/%SYNC_BRANCH_REDUCED_PATH%/$diff.patch"
if not exist "%BRANCH_DIFF_FILE%" (
  echo.%?~nx0%: error: difference file required for branch synchronization is not found: BRANCH_PATH="%SYNC_BRANCH_UNREDUCED_PATH%" BRANCH_DIFF_FILE="%BRANCH_DIFF_FILE%".
  exit /b 23
)

echo.Synchronizing branch: "%SYNC_BRANCH_REDUCED_PATH%"...

set "SYNC_BRANCH_PATH=%SYNC_BRANCH_UNREDUCED_PATH%"

call :SYNC_BRANCH
exit /b

:SYNC_BRANCH
setlocal

rem retrieve workingset URL and Repository Root properties
call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "URL"
set "BRANCH_WORKINGSET_DIR_URL=%RETURN_VALUE%"
if "%BRANCH_WORKINGSET_DIR_URL%" == "" (
  echo.%?~nx0%: error: `URL` property is not found in SVN info file: BRANCH_PATH="%BRANCH_PATH%" BRANCH_INFO_FILE="%BRANCH_INFO_FILE%".
  exit /b 30
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "Repository Root"
set "BRANCH_WORKINGSET_REPO_ROOT=%RETURN_VALUE%"
if "%BRANCH_WORKINGSET_REPO_ROOT%" == "" (
  echo.%?~nx0%: error: `Repository Root` property is not found in SVN workingset info file: BRANCH_PATH="%BRANCH_PATH%" BRANCH_INFO_FILE="%BRANCH_INFO_FILE%".
  exit /b 31
) >&2

rem retrieve workingset revisions and VerID properties
call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "Revision"
set "BRANCH_WORKINGSET_INFO_CURRENT_REV=%RETURN_VALUE%"
if "%BRANCH_WORKINGSET_INFO_CURRENT_REV%" == "" (
  echo.%?~nx0%: error: `Revision` property is not found in SVN workingset info file: BRANCH_PATH="%BRANCH_PATH%" BRANCH_INFO_FILE="%BRANCH_INFO_FILE%".
  exit /b 32
) >&2

rem call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "VerID"
rem set "BRANCH_WORKINGSET_SVNVERSION_VALUE=%RETURN_VALUE%"
rem if "%BRANCH_WORKINGSET_SVNVERSION_VALUE%" == "" set BRANCH_WORKINGSET_SVNVERSION_VALUE=0

call set "BRANCH_WORKINGSET_REPO_REL_PATH=%%BRANCH_WORKINGSET_DIR_URL:*%BRANCH_WORKINGSET_REPO_ROOT%=%%"

rem WORKAROUND: 
rem   Fix for "invalid command" output.
if "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "" set BRANCH_WORKINGSET_REPO_REL_PATH=/

rem echo "BRANCH_WORKINGSET_REPO_REL_PATH=%BRANCH_WORKINGSET_REPO_REL_PATH%"
rem echo "BRANCH_WORKINGSET_DIR_URL=%BRANCH_WORKINGSET_DIR_URL%"
rem echo "BRANCH_WORKINGSET_REPO_ROOT=%BRANCH_WORKINGSET_REPO_ROOT%"

if "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "/" goto BRANCH_WORKINGSET_ROOT_DIR_URL_VALID

if not "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "%BRANCH_WORKINGSET_DIR_URL%" ^
if "%BRANCH_WORKINGSET_REPO_ROOT%%BRANCH_WORKINGSET_REPO_REL_PATH%" == "%BRANCH_WORKINGSET_DIR_URL%" (
  if "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "" goto BRANCH_WORKINGSET_ROOT_DIR_URL_VALID
  if "%BRANCH_WORKINGSET_REPO_REL_PATH:~0,1%" == "/" goto BRANCH_WORKINGSET_ROOT_DIR_URL_VALID
)

(
  echo.%?~nx0%: error: Workingset Repository Root is not a prefix to the workingset branch URL: BRANCH_PATH="%BRANCH_PATH%" REPO_ROOT="%BRANCH_WORKINGSET_REPO_ROOT%" BRANCH_URL="%BRANCH_WORKINGSET_DIR_URL%".
  exit /b 40
) >&2

:BRANCH_WORKINGSET_ROOT_DIR_URL_VALID

if not "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "" ^
if "%BRANCH_WORKINGSET_REPO_REL_PATH:~0,1%" == "/" set "BRANCH_WORKINGSET_REPO_REL_PATH=%BRANCH_WORKINGSET_REPO_REL_PATH:~1%"
if "%BRANCH_WORKINGSET_REPO_REL_PATH%" == "" set BRANCH_WORKINGSET_REPO_REL_PATH=.

rem fresh checkout
if %FLAG_SVN_FRESH_CHECKOUT% NEQ 0 ^
if %SYNC_BRANCH_IS_ROOT% NEQ 0 (
  echo.Removing "%BRANCH_PATH%"...
  rem DO NOT remove branch root directory, instead cleanup it's content!
  pushd "%SYNC_BRANCH_PATH%"
  rmdir /S /Q . 2>nul
  popd
)

if not exist "%SYNC_BRANCH_PATH%" mkdir "%SYNC_BRANCH_PATH%"

rem CAUTION: For some reason svn sometimes returns E160013 error: "/svn/XXX/!svn/rvr/NNNN/<path>" path not found
rem SOLUTION: Use "URL@<revision>" addition to the `-r "<revision>"' argument.

rem make checkout/update if directory was not yet checkout or was checkouted/updated excluding externals
set SVN_DIR_CHECKOUTED=0
if not exist "%SYNC_BRANCH_PATH%\.svn\" (
  set SVN_DIR_CHECKOUTED=1
  call :CMD svn co "%%BRANCH_WORKINGSET_DIR_URL%%@%%BRANCH_WORKINGSET_INFO_CURRENT_REV%%" -r "%%BRANCH_WORKINGSET_INFO_CURRENT_REV%%" "%%SYNC_BRANCH_PATH%%" --depth infinity %%FLAG_TEXT_SVN_IGNORE_EXTERNALS%% --non-interactive || exit /b 41
  echo.
)

rem create temporary branch info file to compare with relative URL from workingset info file
pushd "%SYNC_BRANCH_PATH%" && (
  svn info . --non-interactive > "%BRANCH_INFO_FILE_TMP%" || ( popd & exit /b 42 )
  popd
)

rem read branch info file
call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE_TMP%%" "URL"
set "BRANCH_DIR_URL=%RETURN_VALUE%"
if "%BRANCH_DIR_URL%" == "" (
  echo.%?~nx0%: error: `URL` property is not found in temporary SVN info file requested from the branch: BRANCH_PATH="%BRANCH_PATH%".
  exit /b 43
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE_TMP%%" "Repository Root"
set "BRANCH_REPO_ROOT=%RETURN_VALUE%"
if "%BRANCH_REPO_ROOT%" == "" (
  echo.%?~nx0%: error: `Repository Root` property is not found in temporary SVN info file requested from the branch: BRANCH_PATH="%BRANCH_PATH%".
  exit /b 44
) >&2

call set "BRANCH_REPO_REL_PATH=%%BRANCH_DIR_URL:*%BRANCH_REPO_ROOT%=%%"

rem WORKAROUND:
rem   Fix for "invalid command" output.
if "%BRANCH_REPO_REL_PATH%" == "" set BRANCH_REPO_REL_PATH=/

rem echo "BRANCH_REPO_REL_PATH=%BRANCH_REPO_REL_PATH%"
rem echo "BRANCH_DIR_URL=%BRANCH_DIR_URL%"
rem echo "BRANCH_REPO_ROOT=%BRANCH_REPO_ROOT%"

if "%BRANCH_REPO_REL_PATH%" == "/" goto BRANCH_ROOT_DIR_URL_VALID

if not "%BRANCH_REPO_REL_PATH%" == "%BRANCH_DIR_URL%" ^
if "%BRANCH_REPO_ROOT%%BRANCH_REPO_REL_PATH%" == "%BRANCH_DIR_URL%" (
  if "%BRANCH_REPO_REL_PATH%" == "" goto BRANCH_ROOT_DIR_URL_VALID
  if "%BRANCH_REPO_REL_PATH:~0,1%" == "/" goto BRANCH_ROOT_DIR_URL_VALID
)

(
  echo.%?~nx0%: error: `Repository Root` is not a prefix to the branch `URL`: BRANCH_PATH="%BRANCH_PATH%" REPO_ROOT="%BRANCH_REPO_ROOT%" BRANCH_URL="%BRANCH_DIR_URL%".
  exit /b 50
) >&2

:BRANCH_ROOT_DIR_URL_VALID

if not "%BRANCH_REPO_REL_PATH%" == "" ^
if "%BRANCH_REPO_REL_PATH:~0,1%" == "/" set "BRANCH_REPO_REL_PATH=%BRANCH_REPO_REL_PATH:~1%"
if "%BRANCH_REPO_REL_PATH%" == "" set BRANCH_REPO_REL_PATH=.

rem if auto switch/relocate to workingset repository
if %FLAG_SVN_AUTO_RELOCATE% NEQ 0 goto IGNORE_BRANCH_REPO_REL_PATH_COMPARE
if %FLAG_SVN_AUTO_SWITCH% NEQ 0 goto IGNORE_BRANCH_REPO_REL_PATH_COMPARE

rem compare workingset branch repo relative path with branch repo relative path
if not "%BRANCH_REPO_REL_PATH%" == "%BRANCH_WORKINGSET_REPO_REL_PATH%" (
  echo.%?~nx0%: error: Branch URL relative path is not equal to the workingset branch URL relative path: BRANCH_PATH="%BRANCH_PATH%" BRANCH_REL_PATH="%BRANCH_REPO_REL_PATH%" BRANCH_WORKINGSET_REL_PATH="%BRANCH_WORKINGSET_REPO_REL_PATH%"
  exit /b 51
) >&2

:IGNORE_BRANCH_REPO_REL_PATH_COMPARE

set SVN_DIR_SWITCHED=0
set SVN_DIR_RELOCATE=0

if %SVN_DIR_CHECKOUTED% NEQ 0 goto IGNORE_UPDATE

rem autocleanup all branches
if %FLAG_SVN_AUTO_CLEANUP% NEQ 0 (
  pushd "%SYNC_BRANCH_PATH%" && (
    call :CMD svn cleanup . || ( popd & exit /b 52 )
    popd
  )
)

if %FLAG_SVN_AUTO_RELOCATE% NEQ 0 goto IGNORE_BRANCH_REPO_PATH_COMPARE

rem compare workingset branch repo path with branch repo path
if not "%BRANCH_REPO_ROOT%" == "%BRANCH_WORKINGSET_REPO_ROOT%" (
  echo.%?~nx0%: error: Branch repository URL path is not equal to the workingset branch repository URL path: BRANCH_PATH="%BRANCH_PATH%" REPO_PATH="%BRANCH_REPO_ROOT%" REPO_WORKINGSET_PATH="%BRANCH_WORKINGSET_REPO_ROOT%"
  exit /b 53
) >&2

:IGNORE_BRANCH_REPO_PATH_COMPARE

if %FLAG_SVN_IGNORE_EXTERNALS% NEQ 0 (
  rem Add externals remove step, because:
  rem   1. Update or switch w/ --ignore-externals flag won't remove externals what should be removed
  rem      (externals what should be added will be added automatically in next turn by it's explicit processing).
  rem   2. We must remove an external directory before the switch/update below because a switch/update can update the tree structure where the external subdirectory may
  rem      become a part of the repository and so raise the "obstructing working copy" issue.
  rem Algorithm:
  rem   1. Request externals list for a particular revision from being updated directory and current externals list. Then
  rem      compare them and find removed externals and physically remove them.
  rem   2. Additionally remove parent directories (in reverse order from child to parent) if they were a part of an external path and there is no
  rem      any files or directories in it.
  rem   3. Stop with an error if being removed external contains changes but the auto revert option is not set.

  rem from externals
  pushd "%SYNC_BRANCH_PATH%" && (
    svn pget svn:externals . -R --non-interactive > "%BRANCH_FROM_EXTERNALS_FILE_TMP%" || ( popd & exit /b 54 )
    popd
  )

  rem convert externals into CSV list
  call "%%SVNCMD_TOOLS_ROOT%%/gen_externals_list.bat" "%%BRANCH_FROM_EXTERNALS_FILE_TMP%%" "%%BRANCH_REPO_ROOT%%" "%%BRANCH_DIR_URL%%" > "%BRANCH_FROM_EXTERNALS_LIST_FILE_TMP%"
  if %ERRORLEVEL% NEQ 0 (
    echo.%?~nx0%: error: invalid svn:externals path transformation: EXTERNAL_FILE="%BRANCH_FROM_EXTERNALS_FILE_TMP%" REPO_ROOT="%BRANCH_REPO_ROOT%" ^
DIR_URL="%BRANCH_DIR_URL%".
    exit /b 55
  ) >&2

  rem generate externals difference file
  call "%%SVNCMD_TOOLS_ROOT%%/gen_diff_svn_externals.bat" "%%BRANCH_EXTERNALS_FILE%%" "%%BRANCH_FROM_EXTERNALS_LIST_FILE_TMP%%" "%%BRANCH_EXTERNALS_DIFF_LIST_FILE_TMP%%"
  if %ERRORLEVEL% GTR 0 (
    echo.%?~nx0%: error: invalid svn:externals file lists: ERROR="%ERRORLEVEL%" PREV_EXTERNALS="%BRANCH_FROM_EXTERNALS_LIST_FILE_TMP%" NEXT_EXTERNALS="%BRANCH_EXTERNALS_FILE%".
    exit /b 56
  ) >&2

  if %ERRORLEVEL% EQU 0 (
    rem externals has differences, search for removed externals
    for /F "usebackq eol=# tokens=1,2,3 delims=|" %%i in ("%BRANCH_EXTERNALS_DIFF_LIST_FILE_TMP%") do (
      if "%%i" == "-" (
        set "BRANCH_EXTERNAL_DIR_PATH_PREFIX_TO_REMOVE=%%j"
        set "BRANCH_EXTERNAL_DIR_PATH_TO_REMOVE=%%k"
        call :REMOVE_BRANCH_EXTERNAL_DIR_PATH || goto :EOF
      )
    )
  )
)

goto REMOVE_BRANCH_EXTERNAL_DIR_PATH_END

:REMOVE_BRANCH_EXTERNAL_DIR_PATH
set "DIR_PATH=%BRANCH_EXTERNAL_DIR_PATH_PREFIX_TO_REMOVE%/%BRANCH_EXTERNAL_DIR_PATH_TO_REMOVE%"
set "SYNC_BRANCH_PATH_TO_REMOVE=%SYNC_BRANCH_PATH%/%DIR_PATH%"

rem create temporary branch difference file to compare with
pushd "%SYNC_BRANCH_PATH_TO_REMOVE%" && (
  svn diff . --non-interactive > "%BRANCH_DIFF_FILE_TMP%" || ( popd & exit /b 57 )
  popd
)

rem get branch difference file size before update
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%BRANCH_DIFF_FILE_TMP%%"

if %ERRORLEVEL% NEQ 0 ^
if %FLAG_SVN_AUTO_REVERT% EQU 0 (
  rem being removed external directory has differences but the auto revert flag is not set
  echo.%?~nx0%: error: Branch has differences, manual branch revert is required: BRANCH_PATH="%SYNC_BRANCH_PATH_TO_REMOVE%".
  exit /b 58
) >&2

pushd "%SYNC_BRANCH_PATH%" && (
  rem remove recursively all versioned files and directories in the external directory
  call :SVN_REMOVE_DIR_BY_LIST || ( popd & goto :EOF )
  rem remove parent path to the external directory
  call :REMOVE_EMPTY_DIR_PATH || ( popd & goto :EOF )
  popd
)

exit /b 0

:REMOVE_BRANCH_EXTERNAL_DIR_PATH_END

if %FLAG_SVN_AUTO_RELOCATE% NEQ 0 (
  if not "%BRANCH_REPO_ROOT%" == "%BRANCH_WORKINGSET_REPO_ROOT%" (
    rem auto relocate to workingset URL 
    set SVN_DIR_RELOCATED=1
    pushd "%SYNC_BRANCH_PATH%" && (
      call :CMD svn relocate "%%BRANCH_DIR_URL%%" "%%BRANCH_WORKINGSET_DIR_URL%%" . %%FLAG_TEXT_SVN_IGNORE_EXTERNALS%% --non-interactive || ( popd & exit /b 59 )
      popd
    )
    echo.
  )
)

if %FLAG_SVN_AUTO_SWITCH% NEQ 0 (
  if not "%BRANCH_DIR_URL%" == "%BRANCH_WORKINGSET_DIR_URL%" (
    rem auto switch to workingset URL w/o branch switch (in-tree relocation)
    set SVN_DIR_SWITCHED=1
    pushd "%SYNC_BRANCH_PATH%" && (
      call :CMD svn switch "%%BRANCH_WORKINGSET_DIR_URL%%@%%BRANCH_WORKINGSET_INFO_CURRENT_REV%%" -r "%%BRANCH_WORKINGSET_INFO_CURRENT_REV%%" . --set-depth infinity %%FLAG_TEXT_SVN_IGNORE_EXTERNALS%% %%FLAG_TEXT_SVN_IGNORE_ANCESTRY%% --non-interactive || ( popd & exit /b 60 )
      popd
    )
    echo.
  )
)

if %FLAG_SVN_AUTO_REVERT% EQU 0 (
  rem create temporary branch difference file to compare with
  pushd "%SYNC_BRANCH_PATH%" && (
    svn diff . --non-interactive > "%BRANCH_DIFF_FILE_TMP%" || ( popd & exit /b 61 )
    popd
  )

  rem get branch difference file size before update
  call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%BRANCH_DIFF_FILE_TMP%%"
)

if %FLAG_SVN_AUTO_REVERT% EQU 0 (
  set BRANCH_DIFF_FILESIZE=%ERRORLEVEL%
) else (
  rem must be not empty before usage in if expression
  set BRANCH_DIFF_FILESIZE=0
)

rem autorevert branch changes if not fresh checkout
if %FLAG_SVN_FRESH_CHECKOUT% EQU 0 (
  if %FLAG_SVN_AUTO_REVERT% NEQ 0 (
    rem if %BRANCH_DIFF_FILESIZE% NEQ 0 (
      pushd "%SYNC_BRANCH_PATH%" && (
        call :CMD svn revert . %%FLAG_SVN_EXTERNALS_PROPGET%% --depth infinity --non-interactive || ( popd & exit /b 62 )
        popd
      )
      echo.
    rem )
  ) else if %BRANCH_DIFF_FILESIZE% NEQ 0 (
    echo.%?~nx0%: error: Branch has differences, manual branch revert is required: BRANCH_PATH="%BRANCH_PATH%".
    exit /b 63
  )
)

rem INFO:
rem   Update changes with --set-depth infinity in case if previous checkout/update has been done w/o infinity depth.
rem   If update is recursive (-R) then ignore externals update because they will be updated exclusively.
if %SVN_DIR_SWITCHED% EQU 0 (
  pushd "%SYNC_BRANCH_PATH%" && (
    call :CMD svn up . -r "%%BRANCH_WORKINGSET_INFO_CURRENT_REV%%" --set-depth infinity %%FLAG_TEXT_SVN_IGNORE_EXTERNALS%% --non-interactive || ( popd & exit /b 64 )
    echo.
    rem rem revert immediately to resolve potential tree conflicts
    rem call :CMD svn revert . %%FLAG_SVN_EXTERNALS_PROPGET%% --depth infinity --non-interactive || ( popd & exit /b 65 )
    popd
  )
  echo.
)

:IGNORE_UPDATE

rem make update by changeset
if exist "%BRANCH_CHANGESET_FILE%" call :UPDATE_BY_CHANGESET
goto UPDATE_BY_CHANGESET_END

:UPDATE_BY_CHANGESET
for /F "usebackq eol= tokens=1,* delims=|" %%i in ("%BRANCH_CHANGESET_FILE%") do (
  set CHANGESET_REVISION=%%i
  set "CHANGESET_PATH=%%j"
  pushd "%SYNC_BRANCH_PATH%" && (
    call :CMD svn up "%%CHANGESET_PATH%%@%%CHANGESET_REVISION%%" -r "%%CHANGESET_REVISION%%" --depth infinity %%FLAG_TEXT_SVN_IGNORE_EXTERNALS%% --non-interactive || ( popd & exit /b 66 )
    rem rem revert immediately to resolve potential tree conflicts
    rem call :CMD svn revert "%%CHANGESET_PATH" %%FLAG_SVN_EXTERNALS_PROPGET%% --depth infinity --non-interactive || ( popd & exit /b 67 )
    popd
  )
  echo.
)

exit /b 0
:UPDATE_BY_CHANGESET_END

rem get branch difference file size after update
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%BRANCH_DIFF_FILE%%"
set BRANCH_DIFF_FILESIZE=%ERRORLEVEL%

if %BRANCH_DIFF_FILESIZE% NEQ 0 pushd "%SYNC_BRANCH_PATH%" && (
  rem PREPROCESS_EXTERNAL_REMOVE step, because:
  rem   1. We must postprocess all removed external items after the patch below because a patch can update a directory externals property list but does not
  rem      physically remove directories associated with removed external items.
  rem Algorithm:
  rem   1. Request current externals list from being updated directory and compare it with externals list about to be apply. Then
  rem      find removed externals and physically remove them.
  rem   2. Additionally remove parent directories (in reverse order from child to parent) if they were a part of an external path and there is no
  rem      any files or directories in it.
  rem   3. Stop with an error if being removed external contains changes but the auto revert option is not set.

  rem CAUTION: Patch svn added files workaround:
  rem   SVN revert can leave files in working copy if they were added before into version control
  rem   (Undo Add command usually does leave files in working copy). So the next patch command
  rem   may fail with messages "Skipped missing target: '...'" if such files has already been in the
  rem   working copy being patched.
  rem   To avoid such circumstance we must remove these files before a patch apply or just after revert them.
  call :RESOLVE_PATCH_AMBIGUITY PREPROCESS_SVN_ADD_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF )

  rem CAUTION: Patch binary files workaround:
  rem   Preprocess branch binary differences by creating empty binary files gonna be patched,
  rem   otherwise "svn patch" will fail with: "E720003: Can't open file '...': ...".
  rem   If empty binary file does exist before the "svn patch", then it will just warn: "Skipped missing target: '...'".
  call :RESOLVE_PATCH_AMBIGUITY PREPROCESS_COPY_BINARY_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF )
  
  rem CAUTION:
  rem   "svn patch" may fail to add files into directory which is not under version control, because previous
  rem   stage could add unversionned directories for empty files to workaround another problem in "svn patch" (see above).
  rem   So to workaround this problem we must add under version control all newly created directories which files gonna
  rem   be added to the version control through a patch below.
  call :RESOLVE_PATCH_AMBIGUITY PREPROCESS_COPY_ADD_BINARY_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF)

  call :CMD svn patch "%%BRANCH_DIFF_FILE%%" . || ( popd & exit /b 70 )
  echo.

  rem copy branch binary differences
  call :RESOLVE_PATCH_AMBIGUITY COPY_BINARY_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF )

  rem "svn add" branch differences
  call :RESOLVE_PATCH_AMBIGUITY SVN_ADD_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF )

  rem "svn remove" branch differences
  call :RESOLVE_PATCH_AMBIGUITY SVN_REMOVE_FILE "%%BRANCH_DIFF_FILE%%" || ( popd & goto :EOF )

  popd
)

rem end of branch root processing
if %SYNC_BRANCH_IS_ROOT% NEQ 0 exit /b 0

rem CAUTION:
rem   1. Because patch could change anything including svn properties like svn:externals, so we must update those changes exclusively avoiding
rem      redundant processing by the call like "svn up" here. Native svn update will update repository which already updated before the patch and may rollback
rem      patched items, for example, by update to the head (the changeset exists to update items to a particular revision).
rem   2. Exclusive externals update will leave those externals unsynchronized with parent repositories in the local WC database. So we must synchronize
rem      those repositories by direct write into wc.db database into EXTERNALS table.

rem Extract branch parent path, branch local path and branch external path.
call :EXTRACT_BRANCH_PATHS
goto EXTRACT_BRANCH_PATHS_END

:EXTRACT_BRANCH_PATHS
set "SYNC_BRANCH_DECORATED_PARENT_PATH="
set "SYNC_BRANCH_DECORATED_PREV_REL_PATH="
set "SYNC_BRANCH_DECORATED_NEXT_REL_PATH=%SYNC_BRANCH_DECORATED_PATH%"
:EXTRACT_BRANCH_PATHS_LOOP
for /F "eol= tokens=1,* delims=:" %%i in ("%SYNC_BRANCH_DECORATED_NEXT_REL_PATH%") do (
  if not "%%j" == "" (
    if not "%SYNC_BRANCH_DECORATED_PREV_REL_PATH%" == "" (
      if not "%SYNC_BRANCH_DECORATED_PARENT_PATH%" == "" (
        set "SYNC_BRANCH_DECORATED_PARENT_PATH=%SYNC_BRANCH_DECORATED_PARENT_PATH%:%SYNC_BRANCH_DECORATED_PREV_REL_PATH%"
      ) else (
        set "SYNC_BRANCH_DECORATED_PARENT_PATH=%SYNC_BRANCH_DECORATED_PREV_REL_PATH%"
      )
    )
    set "SYNC_BRANCH_DECORATED_PREV_REL_PATH=%%i"
    set "SYNC_BRANCH_DECORATED_NEXT_REL_PATH=%%j"
    goto EXTRACT_BRANCH_PATHS_LOOP
  )
  goto EXTRACT_BRANCH_PATHS_LOOP_END
)

:EXTRACT_BRANCH_PATHS_LOOP_END
set "SYNC_BRANCH_LOCAL_DEF_PATH="
if not "%SYNC_BRANCH_DECORATED_PREV_REL_PATH%" == "" (
  if "%SYNC_BRANCH_DECORATED_PREV_REL_PATH:~0,1%" == "#" (
    if not "%SYNC_BRANCH_DECORATED_PARENT_PATH%" == "" (
      set "SYNC_BRANCH_DECORATED_PARENT_PATH=%SYNC_BRANCH_DECORATED_PARENT_PATH%:%SYNC_BRANCH_DECORATED_PREV_REL_PATH%"
    ) else (
      set "SYNC_BRANCH_DECORATED_PARENT_PATH=%SYNC_BRANCH_DECORATED_PREV_REL_PATH%"
    )
  ) else (
    set "SYNC_BRANCH_LOCAL_DEF_PATH=%SYNC_BRANCH_DECORATED_PREV_REL_PATH%"
  )
)

set "SYNC_BRANCH_PARENT_PATH=%SYNC_BRANCH_DECORATED_PARENT_PATH%"
set "SYNC_BRANCH_EXT_PATH=%SYNC_BRANCH_DECORATED_NEXT_REL_PATH%"

goto :EOF

:EXTRACT_BRANCH_PATHS_END

if not "%SYNC_BRANCH_PARENT_PATH%" == "" set "SYNC_BRANCH_PARENT_PATH=%SYNC_BRANCH_PARENT_PATH::#=/%"
if not "%SYNC_BRANCH_PARENT_PATH%" == "" set "SYNC_BRANCH_PARENT_PATH=%SYNC_BRANCH_PARENT_PATH::=/%"
if "%SYNC_BRANCH_PARENT_PATH%" == "" goto SYNC_BRANCH_PARENT_PATH_EMPTY
if "%SYNC_BRANCH_PARENT_PATH:~0,1%" == "#" set "SYNC_BRANCH_PARENT_PATH=%SYNC_BRANCH_PARENT_PATH:~1%"
:SYNC_BRANCH_PARENT_PATH_EMPTY

if "%SYNC_BRANCH_PARENT_PATH%" == "" set SYNC_BRANCH_PARENT_PATH=.

if not "%SYNC_BRANCH_EXT_PATH%" == "" set "SYNC_BRANCH_EXT_PATH=%SYNC_BRANCH_EXT_PATH::#=/%"
if not "%SYNC_BRANCH_EXT_PATH%" == "" set "SYNC_BRANCH_EXT_PATH=%SYNC_BRANCH_EXT_PATH::=/%"
if "%SYNC_BRANCH_EXT_PATH%" == "" goto SYNC_BRANCH_EXT_PATH_EMPTY
if "%SYNC_BRANCH_EXT_PATH:~0,1%" == "#" set "SYNC_BRANCH_EXT_PATH=%SYNC_BRANCH_EXT_PATH:~1%"
:SYNC_BRANCH_EXT_PATH_EMPTY

rem Extract branch local/parent relative paths.
call :EXTRACT_BRANCH_PARENT_REL_PATH
goto EXTRACT_BRANCH_PARENT_REL_PATH_END

:EXTRACT_BRANCH_PARENT_REL_PATH
set "SYNC_BRANCH_LOCAL_REL_PATH="
if not "%SYNC_BRANCH_LOCAL_DEF_PATH%" == "" (
  set "SYNC_BRANCH_LOCAL_REL_PATH=%SYNC_BRANCH_LOCAL_DEF_PATH%/%SYNC_BRANCH_EXT_PATH%"
) else (
  set "SYNC_BRANCH_LOCAL_REL_PATH=%SYNC_BRANCH_EXT_PATH%"
)
set "SYNC_BRANCH_PARENT_REL_PATH="
set "SYNC_BRANCH_PARENT_REL_NEXT_PATH=%SYNC_BRANCH_LOCAL_REL_PATH%"
:EXTRACT_BRANCH_PARENT_REL_PATH_LOOP
for /F "eol= tokens=1,* delims=/" %%i in ("%SYNC_BRANCH_PARENT_REL_NEXT_PATH%") do (
  if not "%%j" == "" (
    if not "%SYNC_BRANCH_PARENT_REL_PATH%" == "" (
      set "SYNC_BRANCH_PARENT_REL_PATH=%SYNC_BRANCH_PARENT_REL_PATH%/%%i"
    ) else (
      set "SYNC_BRANCH_PARENT_REL_PATH=%%i"
    )
    set "SYNC_BRANCH_PARENT_REL_NEXT_PATH=%%j"
    goto EXTRACT_BRANCH_PARENT_REL_PATH_LOOP
  )
  goto :EOF
)

goto :EOF

:EXTRACT_BRANCH_PARENT_REL_PATH_END

if not exist "%SYNC_BRANCH_PARENT_PATH%/.svn/wc.db" (
  echo.%?~nx0%: error: SVN database is not found: "%BRANCH_PATH:\=/%/%SYNC_BRANCH_PARENT_PATH%/.svn/wc.db".
  exit /b 80
)

rem get parent branch info file to request repository UUID
pushd "%SYNC_BRANCH_PARENT_PATH%" && (
  svn info . --non-interactive > "%BRANCH_INFO_FILE_TMP%" || ( popd & exit /b 81 )
  popd
)

rem read parent branch info file
call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE_TMP%%" "Repository UUID"
set "PARENT_BRANCH_REPOSITORY_UUID=%RETURN_VALUE%"
if "%PARENT_BRANCH_REPOSITORY_UUID%" == "" (
  echo.%?~nx0%: error: `Repository UUID` property is not found in temporary SVN info file requested from the branch: BRANCH_PATH="%BRANCH_PATH:\=/%/%SYNC_BRANCH_PARENT_PATH%".
  exit /b 84
) >&2

if "%BRANCH_REPO_REL_PATH%" == "." set "BRANCH_REPO_REL_PATH="

set "REPOS_ID="
for /F "usebackq eol= tokens=* delims=" %%i in (`call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch "%%SYNC_BRANCH_PARENT_PATH%%/.svn/wc.db" ".headers off" "select id from "REPOSITORY" where uuid='%%PARENT_BRANCH_REPOSITORY_UUID%%'"`) do set "REPOS_ID=%%i"
if "%REPOS_ID%" == "" (
  echo.%?~nx0%: error: SVN database `REPOSITORY id` request has failed: "%BRANCH_PATH:\=/%/%SYNC_BRANCH_PARENT_PATH%/.svn/wc.db".
  exit /b 90
)

set "WC_ID="
for /F "usebackq eol= tokens=* delims=" %%i in (`call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch "%%SYNC_BRANCH_PARENT_PATH%%/.svn/wc.db" ".headers off" "select id from "WCROOT" where local_abspath is null or local_abspath = ''"`) do set "WC_ID=%%i"
if "%WC_ID%" == "" (
  echo.%?~nx0%: error: SVN database `WCROOT id` request has failed: "%BRANCH_PATH:\=/%/%SYNC_BRANCH_PARENT_PATH%/.svn/wc.db".
  exit /b 91
)

if "%SYNC_BRANCH_EXTERNAL_URI_REV_PEG%" == "0" set "SYNC_BRANCH_EXTERNAL_URI_REV_PEG="
if "%SYNC_BRANCH_EXTERNAL_URI_REV_OPERATIVE%" == "0" set "SYNC_BRANCH_EXTERNAL_URI_REV_OPERATIVE=%SYNC_BRANCH_EXTERNAL_URI_REV_PEG%"

set "PREV_WC_ID="
for /F "usebackq eol= tokens=* delims=" %%i in (`call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch "%%SYNC_BRANCH_PARENT_PATH%%/.svn/wc.db" ".headers off" "select wc_id from "EXTERNALS" where wc_id = '%%WC_ID%%' and local_relpath = '%%SYNC_BRANCH_LOCAL_REL_PATH%%' and def_local_relpath = '%SYNC_BRANCH_LOCAL_DEF_PATH%' "`) do set "PREV_WC_ID=%%i"

rem Update/Insert records into WC EXTERNALS table to link external directory from the parent.
if not "%PREV_WC_ID%" == "" (
  call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch "%%SYNC_BRANCH_PARENT_PATH%%/.svn/wc.db" ".headers off" ^
    "update EXTERNALS set parent_relpath = '%%SYNC_BRANCH_PARENT_REL_PATH%%',repos_id = '%%REPOS_ID%%',presence = 'normal',kind = 'dir',def_repos_relpath = '%%BRANCH_REPO_REL_PATH%%',def_operational_revision = '%%SYNC_BRANCH_EXTERNAL_URI_REV_PEG%%',def_revision = '%%SYNC_BRANCH_EXTERNAL_URI_REV_OPERATIVE%%' where wc_id = '%%WC_ID%%' and local_relpath = '%%SYNC_BRANCH_LOCAL_REL_PATH%%' and def_local_relpath = '%%SYNC_BRANCH_LOCAL_DEF_PATH%%'" >nul
) else (
  call "%%SQLITE_TOOLS_ROOT%%/sqlite.bat" -batch "%%SYNC_BRANCH_PARENT_PATH%%/.svn/wc.db" ".headers off" ^
    "insert into EXTERNALS (wc_id,local_relpath,parent_relpath,repos_id,presence,kind,def_local_relpath,def_repos_relpath,def_operational_revision,def_revision) values (%%WC_ID%%,'%%SYNC_BRANCH_LOCAL_REL_PATH%%','%%SYNC_BRANCH_PARENT_REL_PATH%%','%%REPOS_ID%%','normal','dir','%%SYNC_BRANCH_LOCAL_DEF_PATH%%','%%BRANCH_REPO_REL_PATH%%','%%SYNC_BRANCH_EXTERNAL_URI_REV_PEG%%','%%SYNC_BRANCH_EXTERNAL_URI_REV_OPERATIVE%%')"
)

:SYNC_BRANCH_END
exit /b 0

:RESOLVE_PATCH_AMBIGUITY
setlocal
set "BINARY_FILE_ACTION=%~1"
set "BRANCH_DIFF_FILE_DIR=%~dp2"

if "%BINARY_FILE_ACTION%" == "PREPROCESS_SVN_ADD_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_added.lst"
if "%BINARY_FILE_ACTION%" == "PREPROCESS_COPY_BINARY_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_copy.lst"
if "%BINARY_FILE_ACTION%" == "PREPROCESS_COPY_ADD_BINARY_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_copy.lst"
if "%BINARY_FILE_ACTION%" == "COPY_BINARY_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_copy.lst"
if "%BINARY_FILE_ACTION%" == "SVN_ADD_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_added.lst"
if "%BINARY_FILE_ACTION%" == "SVN_REMOVE_FILE" set "BRANCH_DIFF_FROM_FILE_NAME=%~n2_removed.lst"

if not exist "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FROM_FILE_NAME%" exit /b 0

if "%BINARY_FILE_ACTION%" == "PREPROCESS_SVN_ADD_FILE" goto RESOLVE_PREPROCESS_SVN_ADD
if "%BINARY_FILE_ACTION%" == "PREPROCESS_COPY_ADD_BINARY_FILE" goto RESOLVE_PREPROCESS_COPY_ADD_BINARY_FILE
if "%BINARY_FILE_ACTION%" == "SVN_REMOVE_FILE" goto RESOLVE_SVN_REMOVE

for /F "usebackq eol=# tokens=* delims=" %%i in ("%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FROM_FILE_NAME%") do (
  set "BRANCH_FILE_PATH=%%i"
  call :%%BINARY_FILE_ACTION%% "%%BRANCH_DIFF_FILE_DIR%%%%BRANCH_FILE_PATH%%" "%%BRANCH_FILE_PATH%%" || goto :EOF
)

echo.

exit /b 0

:RESOLVE_PREPROCESS_SVN_ADD
:RESOLVE_SVN_REMOVE
rem add directories from the copy.lst to the version control which files has located in the added.lst (would be added by a patch).
for /F "usebackq eol=# tokens=* delims=" %%i in (`sort /R "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FROM_FILE_NAME%"`) do (
  set "BRANCH_FILE_PATH=%%i"
  call :%%BINARY_FILE_ACTION%% "%%BRANCH_DIFF_FILE_DIR%%%%BRANCH_FILE_PATH%%" "%%BRANCH_FILE_PATH%%" || goto :EOF
)

echo.

exit /b 0

:RESOLVE_PREPROCESS_COPY_ADD_BINARY_FILE
set "BRANCH_TO_ADD_FILE_NAME=%~n2_added.lst"

rem add directories from the copy.lst to the version control which files has located in the added.lst (would be added by a patch).
for /F "usebackq eol=# tokens=* delims=" %%i in ("%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FROM_FILE_NAME%") do (
  set "BRANCH_FILE_PATH=%%i"
  call :%%BINARY_FILE_ACTION%% "%%BRANCH_DIFF_FILE_DIR%%%%BRANCH_FILE_PATH%%" "%%BRANCH_FILE_PATH%%" || goto :EOF
)

echo.

exit /b 0

:PREPROCESS_COPY_BINARY_FILE
set "BRANCH_BINARY_FILE_DIR=%~dp2"

if not exist "%BRANCH_BINARY_FILE_DIR%" mkdir "%BRANCH_BINARY_FILE_DIR%"
rem echo.^>empty "%BRANCH_FILE_PATH%"
echo.> "%BRANCH_FILE_PATH%"

exit /b 0

:PREPROCESS_COPY_ADD_BINARY_FILE
set "BRANCH_BINARY_FILE_DIR=%~dp2"
set "BRANCH_BINARY_FILE_DIR=%BRANCH_BINARY_FILE_DIR:~0,-1%"

rem check is directory already added to the version control
svn info "%BRANCH_BINARY_FILE_DIR%" >nul 2>nul && exit /b 0

rem echo BRANCH_FILE_PATH=%BRANCH_FILE_PATH%
call "%%CONTOOLS_ROOT%%/index_pathstr.bat" BRANCH_BINARY_FILE_SUBDIR_ /\ "%%BRANCH_FILE_PATH%%"
set BRANCH_BINARY_FILE_INDEX_SIZE=%RETURN_VALUE%
if %BRANCH_BINARY_FILE_INDEX_SIZE% LSS 2 exit /b 0

call :PREPROCESS_COPY_ADD_BINARY_FILE_IMPL
rem exit with positive exit code
if %ERRORLEVEL% GTR 0 exit /b
exit /b 0

:PREPROCESS_COPY_ADD_BINARY_FILE_IMPL
for /F "usebackq eol=# tokens=* delims=" %%i in ("%BRANCH_DIFF_FILE_DIR%%BRANCH_TO_ADD_FILE_NAME%") do (
  set "BRANCH_FILE_PATH_TO_ADD=%%i"
  call :PREPROCESS_COPY_ADD_BINARY_FILE_LINE || goto :EOF
)
exit /b 0

:PREPROCESS_COPY_ADD_BINARY_FILE_LINE
rem echo BRANCH_FILE_PATH_TO_ADD=%BRANCH_FILE_PATH_TO_ADD%
call "%%CONTOOLS_ROOT%%/index_pathstr.bat" BRANCH_BINARY_FILE_TO_ADD_SUBDIR_ /\ "%%BRANCH_FILE_PATH_TO_ADD%%"
set BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE=%RETURN_VALUE%
if %BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE% LSS 2 exit /b 0

set BRANCH_BINARY_FILE_MIN_INDEX_SIZE=%BRANCH_BINARY_FILE_INDEX_SIZE%
if %BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE% LSS %BRANCH_BINARY_FILE_MIN_INDEX_SIZE% set BRANCH_BINARY_FILE_MIN_INDEX_SIZE=%BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE%

set BRANCH_BINARY_FILE_MAX_INDEX_SIZE=%BRANCH_BINARY_FILE_INDEX_SIZE%
if %BRANCH_BINARY_FILE_MAX_INDEX_SIZE% LSS %BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE% set BRANCH_BINARY_FILE_MAX_INDEX_SIZE=%BRANCH_BINARY_FILE_TO_ADD_INDEX_SIZE%

call :SVN_COPY_ADD_BINARY_FILE_DIR
rem exit with positive or special negative exit code
if %ERRORLEVEL% GTR 0 exit /b
if %ERRORLEVEL% LSS -1 exit /b
exit /b 0

:SVN_COPY_ADD_BINARY_FILE_DIR
set /A BRANCH_BINARY_FILE_MIN_INDEX_SIZE-=1
set /A BRANCH_BINARY_FILE_MAX_INDEX_SIZE-=1
for /L %%i in (1,1,%BRANCH_BINARY_FILE_MIN_INDEX_SIZE%) do (
  set DIR_INDEX=%%i
  call :SVN_COPY_ADD_BINARY_FILE_DIR_IMPL || goto :EOF
)
exit /b 0

:SVN_COPY_ADD_BINARY_FILE_DIR_IMPL
call set "DIR_PATH=%%BRANCH_BINARY_FILE_SUBDIR_%DIR_INDEX%:/=\%%"
call set "DIR_TO_ADD_PATH=%%BRANCH_BINARY_FILE_TO_ADD_SUBDIR_%DIR_INDEX%:/=\%%"
if not "%DIR_PATH%" == "%DIR_TO_ADD_PATH%" exit /b -1

call :SVN_ADD_FILE_DIR || goto :EOF

rem stop search second list because all path is added to the version control
if %DIR_INDEX% EQU %BRANCH_BINARY_FILE_MAX_INDEX_SIZE% exit /b -2

exit /b 0

:PREPROCESS_SVN_ADD_FILE
if exist "%BRANCH_FILE_PATH%" ( call :REMOVE_UNVERSIONNED || goto :EOF )
exit /b 0

:COPY_BINARY_FILE
set "BRANCH_BINARY_FILE_DIR=%~dp1"
set "BRANCH_BINARY_FILE_NAME=%~nx1"

set "BRANCH_BINARY_FILE_DIR_COPY_TO=%~dp2"
set "BRANCH_FILE_PATH_COPY_TO=%~dpnx2"

call "%%CONTOOLS_ROOT%%/xcopy_file.bat" "%%BRANCH_BINARY_FILE_DIR%%" "%%BRANCH_BINARY_FILE_NAME%%" "%%BRANCH_BINARY_FILE_DIR_COPY_TO%%" /NJS || exit /b 110
exit /b 0

:SVN_ADD_FILE
rem safe checks
if "%BRANCH_FILE_PATH%" == "" exit /b 0
if "%BRANCH_FILE_PATH%" == "." exit /b 0
rem add only unversionned files
svn info "%BRANCH_FILE_PATH%" >nul 2>nul && exit /b 0
call :CMD svn add "%%BRANCH_FILE_PATH%%" --depth empty --non-interactive || exit /b 111
exit /b 0

:SVN_ADD_FILE_DIR
rem safe checks
if "%DIR_PATH%" == "" exit /b 0
if "%DIR_PATH%" == "." exit /b 0
if not exist "%DIR_PATH%\" mkdir "%DIR_PATH%"
rem add only unversionned directories
svn info "%DIR_PATH%" >nul 2>nul && exit /b 0
call :CMD svn add "%%DIR_PATH%%" --depth empty --non-interactive || exit /b 112
exit /b 0

:SVN_REMOVE_FILE
rem safe checks
if "%BRANCH_FILE_PATH%" == "" exit /b 0
if "%BRANCH_FILE_PATH%" == "." exit /b 0
if exist "%BRANCH_FILE_PATH%" ( call :REMOVE_VERSIONNED || goto :EOF )
exit /b 0

:SVN_REMOVE_DIR_BY_LIST
rem set a current directory for "svn ls" command to reduce path lengths in output and from there the ".svn" directory search up to the root
pushd "%DIR_PATH%" && (
  call "%%SVNCMD_TOOLS_ROOT%%/svn_list.bat" -offline . --depth infinity --non-interactive > "%BRANCH_FILES_FILE_TMP%" 2>nul || ( popd & goto :EOF )

  echo.Removing external directory: "%DIR_PATH%"...
  for /F "usebackq eol=	 tokens=* delims=" %%i in (`sort /R "%BRANCH_FILES_FILE_TMP%"`) do (
    echo.%%i
    set "SVN_FILE_PATH=%%i"
    call :REMOVE_SVN_FILE_PATH || ( popd & goto :EOF )
  )
  popd
)
exit /b 0

:REMOVE_SVN_FILE_PATH
rem safe checks
if "%SVN_FILE_PATH%" == "" exit /b 0
if "%SVN_FILE_PATH%" == "." exit /b 0
if "%SVN_FILE_PATH:~-1%" == "/" (
  rmdir /Q "%SVN_FILE_PATH:/=\%" 2>nul && echo."%SVN_FILE_PATH%"
) else (
  del /F /Q /A:-D "%SVN_FILE_PATH:/=\%" 2>nul && echo."%SVN_FILE_PATH%"
)
exit /b 0

:REMOVE_VERSIONNED
rem safe checks
if "%BRANCH_FILE_PATH%" == "" exit /b 0
if "%BRANCH_FILE_PATH%" == "." exit /b 0
rem remove only versionned files
svn info "%BRANCH_FILE_PATH%" >nul 2>nul || exit /b 0
call :CMD svn remove "%%BRANCH_FILE_PATH%%" --force --non-interactive || exit /b 113
exit /b 0

:REMOVE_UNVERSIONNED
rem safe checks
if "%BRANCH_FILE_PATH%" == "" exit /b 0
if "%BRANCH_FILE_PATH%" == "." exit /b 0
rem remove only unversionned files
svn info "%BRANCH_FILE_PATH%" >nul 2>nul && exit /b 0
if exist "%BRANCH_FILE_PATH%\" (
  call :CMD rmdir /Q "%%BRANCH_FILE_PATH:/=\%%" || exit /b 114
  exit /b 0
)
call :CMD del /F /Q /A:-D "%%BRANCH_FILE_PATH:/=\%%" || exit /b 115
exit /b 0

:REMOVE_EMPTY_DIR_PATH
rem safe checks
if "%DIR_PATH%" == "" exit /b 0
if "%DIR_PATH%" == "." exit /b 0
if "%DIR_PATH:~1,1%" == ":" exit /b 0
rem test whole path on empty directory
rem set "DIR_PATH=%DIR_PATH:/=\%"
if exist "%DIR_PATH%\" (
  dir /B "%DIR_PATH%\" >nul 2>nul && exit /b 0
  call :REMOVE_EMPTY_DIR_PATH_IMPL || goto :EOF
)
exit /b 0

:REMOVE_EMPTY_DIR_PATH_IMPL
set "DIR_PATH_PREFIX="
set DIR_PATH_OFFSET=1

:REMOVE_EMPTY_DIR_PATH_IMPL_COMPONENT_LOOP
set "DIR_PATH_COMPONENT="
for /F "eol=	 tokens=%DIR_PATH_OFFSET% delims=/" %%i in ("%DIR_PATH%") do set "DIR_PATH_COMPONENT=%%i"
if not "%DIR_PATH_COMPONENT%" == "" (
  set "DIR_PATH_ARR[%DIR_PATH_OFFSET%]=%DIR_PATH_PREFIX%%DIR_PATH_COMPONENT%"
  set "DIR_PATH_PREFIX=%DIR_PATH_PREFIX%%DIR_PATH_COMPONENT%/"
  set /A DIR_PATH_OFFSET+=1
  goto REMOVE_EMPTY_DIR_PATH_IMPL_COMPONENT_LOOP
)

set /A DIR_PATH_OFFSET-=1

:REMOVE_EMPTY_DIR_PATH_IMPL_REMOVE_LOOP
if %DIR_PATH_OFFSET% LEQ 0 exit /b 0
call set "DIR_PATH_PREFIX=%%DIR_PATH_ARR[%DIR_PATH_OFFSET%]%%"
rem test path component on empty directory
if not "%DIR_PATH_PREFIX%" == "." ^
if exist "%DIR_PATH_PREFIX:/=\%\" (
  dir /B "%DIR_PATH_PREFIX:/=\%\" >nul 2>nul && exit /b 0
  call :CMD rmdir /Q "%%DIR_PATH_PREFIX:/=\%%" || exit /b 116
)

set /A DIR_PATH_OFFSET-=1

goto REMOVE_EMPTY_DIR_PATH_IMPL_REMOVE_LOOP

:CMD
echo.^>%*
rem Drop last error code
cd .
(%*)
exit /b
