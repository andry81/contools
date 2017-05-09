@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script recursively reads branch information like SVN info/diff/externals/files
rem   and saves it into the workingset file creating catalog directory with
rem   detailed changes associated with the workingset file.

rem   Not recursive externals format:
rem     [-r[ ]<BRANCH_EXTERNAL_URI_REV_OPERATIVE>] <BRANCH_EXTERNAL_URI_PATH>[@<BRANCH_EXTERNAL_URI_REV_PEG>] <BRANCH_EXTERNAL_DIR_PATH>
rem

rem   Recursive externals format:
rem     [<BRANCH_EXTERNAL_DIR_PATH_PREFIX> -] [[-r[ ]<BRANCH_EXTERNAL_URI_REV_OPERATIVE>] <BRANCH_EXTERNAL_URI_PATH>[@<BRANCH_EXTERNAL_URI_REV_PEG>] <BRANCH_EXTERNAL_DIR_PATH>]
rem     , where <BRANCH_EXTERNAL_DIR_PATH_PREFIX> - relative to the current directory
rem 

rem Flags:
rem  -offline - scan Working Copy in offline mode (for example, "svn ls" calls will be replaced by the SVN wc.db direct access).
rem  -relfpaths - truncate any absolute paths in nested info files (the root does not touch) into relative (to avoid comparison issues with different absolute paths).
rem  -R - parse root externals recursively.
rem  -diff_ra - get each branch difference state after Last Changed Rev from server (experimental, slow and can generate wrong difference file in case if commit made w/o update).
rem  -ad - auto detect SVN version control directories recursively.
rem  -ls - save file-directory list of SVN branch into file and hash it.
rem  -stat - save status of SVN branch in a working copy into file.
rem  -stat-exclude-? - exclude status lines for unversionned files (? prefixed) from "svn status" output.

rem Return codes:
rem   >0 - errors
rem    0 - no errors
rem   <0 - warnings

rem Examples:
rem 1. call gen_branch_workingset.bat -R -ls branch/current current_root_info.txt current_root_changeset.lst current_root_diff.patch current_root_externals.lst current_workingset.lst current_workingset current_root_files.lst current_all_files.lst current_all_files_hash.lst current_root_status.txt current_all_status.txt
rem    type current_root_info.txt
rem    type current_root_diff.patch
rem    type current_root_externals.lst
rem    type current_workingset.lst
rem    dir current_workingset /S
rem    type current_root_files.lst
rem    type current_all_files.lst
rem    type current_all_files_hash.lst
rem    type current_root_status.txt
rem    type current_all_status.txt

rem KNOWN ISSUES:
rem 1. By default, script will use the svn command line tools to request Working Copy information. In some cases it will lead to network use even if processed path is a local file path. 
rem    To avoid such condition you have to explicitly set the offline flag to avoid the network interference.
rem 2. By default, script won't request externals from a branch not external subdirectories, won't generate "all files" list and hash these files to
rem    create for a branch files the hash list to give a chance to user to revalidate manually the result of synchronization operation later.
rem    To traverse a branch not external directories recursively and to generate these files you have to explicitly pass -R/-ls/-stat flags to the script respectively.
rem 3. Versioned directories should not begin by the #-character, because it is used to mark directories as externals, otherwise synchronization may throw errors.
rem    Versioned files should not be the files $info.txt, $changeset.lst, $diff.patch, $diff_copy.lst, $diff_added.lst, $diff_removed.lst, $externals.lst, $files.lst, $status.txt,
rem    because they are used to store svn.exe output information, otherwise the script may throw errors.
rem 4. All collisions must be resolved before the script execution, otherwise the result will be inconsistent.

rem Drop last error level
cd .

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem script flags
set FLAG_SVN_OFFLINE=0
set "FLAG_TEXT_SVN_OFFLINE="
set FLAG_SVN_REL_FILE_PATHS_ONLY=0
set FLAG_SVN_EXTERNALS_RECURSIVE=0
set "FLAG_SVN_EXTERNALS_PROPGET="
set FLAG_SVN_DIFF_RA=0
set FLAG_SVN_AUTO_DETECT=0
set FLAG_SVN_LIST_FILES=0
set FLAG_SVN_STATUS_FILES=0
set FLAG_SVN_STATUS_EXCLUDE_?=0
set "FLAG_TEXT_FINDSTR_EXCLUDE_ARGS="
set FLAG_FINDSTR_HAS_EXCLUDES=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
  if "%FLAG%" == "-offline" (
    set FLAG_SVN_OFFLINE=1
    set "FLAG_TEXT_SVN_OFFLINE=-offline"
    shift
  ) else if "%FLAG%" == "-relfpaths" (
    set FLAG_SVN_REL_FILE_PATHS_ONLY=1
    shift
  ) else if "%FLAG%" == "-R" (
    set FLAG_SVN_EXTERNALS_RECURSIVE=1
    set "FLAG_SVN_EXTERNALS_PROPGET=-R"
    shift
  ) else if "%FLAG%" == "-diff_ra" (
    set FLAG_SVN_DIFF_RA=1
    shift
  ) else if "%FLAG%" == "-ad" (
    set FLAG_SVN_AUTO_DETECT=1
    shift
  ) else if "%FLAG%" == "-ls" (
    set FLAG_SVN_LIST_FILES=1
    shift
  ) else if "%FLAG%" == "-stat" (
    set FLAG_SVN_STATUS_FILES=1
    shift
  ) else if "%FLAG%" == "-stat-exclude-?" (
    set FLAG_SVN_STATUS_EXCLUDE_?=1
    set FLAG_TEXT_FINDSTR_EXCLUDE_ARGS=%FLAG_TEXT_FINDSTR_EXCLUDE_ARGS% /C:"^? "
    set FLAG_FINDSTR_HAS_EXCLUDES=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "SVN_BRANCH_URI=%~1"

set "BRANCH_ROOT_INFO_FILE_DIR=%~dp2"
set "BRANCH_ROOT_INFO_FILE_NAME=%~nx2"
set "BRANCH_ROOT_INFO_FILE=%BRANCH_ROOT_INFO_FILE_DIR%%BRANCH_ROOT_INFO_FILE_NAME%"

set "BRANCH_ROOT_CHANGESET_FILE_DIR=%~dp3"
set "BRANCH_ROOT_CHANGESET_FILE_NAME=%~nx3"
set "BRANCH_ROOT_CHANGESET_FILE=%BRANCH_ROOT_CHANGESET_FILE_DIR%%BRANCH_ROOT_CHANGESET_FILE_NAME%"

set "BRANCH_ROOT_DIFF_FILE_DIR=%~dp4"
set "BRANCH_ROOT_DIFF_FILE_NAME=%~nx4"
set "BRANCH_ROOT_DIFF_FILE=%BRANCH_ROOT_DIFF_FILE_DIR%%BRANCH_ROOT_DIFF_FILE_NAME%"

set "BRANCH_ROOT_EXTERNALS_FILE_DIR=%~dp5"
set "BRANCH_ROOT_EXTERNALS_FILE_NAME=%~nx5"
set "BRANCH_ROOT_EXTERNALS_FILE=%BRANCH_ROOT_EXTERNALS_FILE_DIR%%BRANCH_ROOT_EXTERNALS_FILE_NAME%"

set "BRANCH_WORKINGSET_FILE_DIR=%~dp6"
set "BRANCH_WORKINGSET_FILE=%~dpf6"

set "BRANCH_WORKINGSET_CATALOG_DIR=%~dpf7"

set "BRANCH_ROOT_FILES_FILE=%~dpf8"

set "BRANCH_ROOT_ALLFILES_DIR=%~dp9"
set "BRANCH_ROOT_ALLFILES_NAME=%~n9"
set "BRANCH_ROOT_ALLFILES_EXT=%~x9"
set "BRANCH_ROOT_ALLFILES_FILE=%BRANCH_ROOT_ALLFILES_DIR%%BRANCH_ROOT_ALLFILES_NAME%%BRANCH_ROOT_ALLFILES_EXT%"

shift
shift
shift

set "BRANCH_ROOT_ALLFILES_HASH_FILE=%~dpf7"
set "BRANCH_ROOT_STATUS_FILE=%~dpf8"
set "BRANCH_ROOT_ALLSTATUS_FILE=%~dpf9"

if "%SVN_BRANCH_URI%" == "" (
  echo.%?~nx0%: error: SVN_BRANCH_URI is not set.
  exit /b 1
) >&2

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "SYNC_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "SYNC_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "GEN_BRANCH_TEMP_FILE_DIR=%TEMP%\%?~n0%.%SYNC_DATE%.%SYNC_TIME%"
set "BRANCH_ROOT_INFO_FILE_TMP=%GEN_BRANCH_TEMP_FILE_DIR%\$root_info.txt"

rem create temporary files to store local context output
if exist "%GEN_BRANCH_TEMP_FILE_DIR%" (
  echo.%?~nx0%: error: temporary generated directory GEN_BRANCH_TEMP_FILE_DIR is already exist: "%GEN_BRANCH_TEMP_FILE_DIR%"
  exit /b 2
)

mkdir "%GEN_BRANCH_TEMP_FILE_DIR%"

call :MAIN
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%GEN_BRANCH_TEMP_FILE_DIR%"

exit /b %LASTERROR%

:MAIN
rem convert all back slashes to slashes
set "SVN_BRANCH_URI=%SVN_BRANCH_URI:\=/%"
if "%SVN_BRANCH_URI:~-1%" == "/" set "SVN_BRANCH_URI=%SVN_BRANCH_URI:~0,-1%"

rem Is branch URI in canonical URI form?
set SVN_BRANCH_URI_IS_CANONICAL=0
if not "%SVN_BRANCH_URI:://=%" == "%SVN_BRANCH_URI%" set SVN_BRANCH_URI_IS_CANONICAL=1

rem remove URI file prefix
if %SVN_BRANCH_URI_IS_CANONICAL% NEQ 0 (
  set "SVN_BRANCH_PATH=%SVN_BRANCH_URI:file:///=%"
) else (
  set "SVN_BRANCH_PATH=%SVN_BRANCH_URI%"
)

rem Is branch URI in local form?
set SVN_BRANCH_URI_IS_LOCAL=0

rem use absolute file form
set "RETURN_VALUE=%SVN_BRANCH_PATH%"
if %SVN_BRANCH_URI_IS_CANONICAL% EQU 0 (
  set SVN_BRANCH_URI_IS_LOCAL=1
  call :GET_ABSOLUTE_PATH "%%SVN_BRANCH_PATH%%"
) else if not "%SVN_BRANCH_PATH%" == "%SVN_BRANCH_URI%" (
  set SVN_BRANCH_URI_IS_LOCAL=1
  call :GET_ABSOLUTE_PATH "%%SVN_BRANCH_PATH%%"
)
set "SVN_BRANCH_PATH=%RETURN_VALUE:\=/%%"

goto GET_ABSOLUTE_PATH_END

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0

:GET_ABSOLUTE_PATH_END

rem Is branch URI is a WC URL?
set SVN_BRANCH_PATH_IS_WC_URL=0

rem try request as local WC path
if %SVN_BRANCH_URI_IS_LOCAL% NEQ 0 ( svn info "%SVN_BRANCH_PATH%" > "%BRANCH_ROOT_INFO_FILE_TMP%" 2>nul && set "SVN_BRANCH_PATH_IS_WC_URL=1" )

set "SVN_BRANCH_WCROOT_PATH="
if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_ROOT_INFO_FILE_TMP%%" "Working Copy Root Path" || (
    echo.%?~nx0%: error: "Working Copy Root Path" property is not found in info file by SVN branch path: "%SVN_BRANCH_PATH%".
    exit /b 3
  ) >&2
)

rem SVN_BRANCH_WCROOT_PATH must be base for the SVN_BRANCH_PATH, will be tested inside svn_changeset.bat/svn_list.bat scripts
if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 set "SVN_BRANCH_WCROOT_PATH=%RETURN_VALUE%"
if not "%SVN_BRANCH_WCROOT_PATH%" == "" set "SVN_BRANCH_WCROOT_PATH=%SVN_BRANCH_WCROOT_PATH:\=/%"

rem Is branch URI is a local repo URL?
set SVN_BRANCH_PATH_IS_LOCAL_REPO_URL=0

rem if not SVN WC path but a local path, then try to request file:/// prefixed path to detect local repo URL presence
if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 if %SVN_BRANCH_URI_IS_LOCAL% NEQ 0 ( svn info "file:///%SVN_BRANCH_PATH%" >nul 2>nul && set "SVN_BRANCH_PATH_IS_LOCAL_REPO_URL=1" )

if %SVN_BRANCH_URI_IS_LOCAL% NEQ 0 (
  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    set "SVN_BRANCH_CANONICAL_PATH=%SVN_BRANCH_PATH%"
  ) else if %SVN_BRANCH_PATH_IS_LOCAL_REPO_URL% NEQ 0 (
    set "SVN_BRANCH_CANONICAL_PATH=file:///%SVN_BRANCH_PATH%"
  ) else (
    set "SVN_BRANCH_CANONICAL_PATH=%SVN_BRANCH_PATH%"
  )
) else (
  set "SVN_BRANCH_CANONICAL_PATH=%SVN_BRANCH_URI%"
)

if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 ^
if %FLAG_SVN_REL_FILE_PATHS_ONLY% NEQ 0 (
  rem ignore special case with autodetect, where branch directory is not SVN WC directory, but under autodetect and won't be processed for paths truncation anyway
  if %FLAG_SVN_AUTO_DETECT% EQU 0 (
    echo.%?~nx0%: error: branch path is not a WC file path and can't be processed for absolute file paths truncation (flag -relfpaths^): "%SVN_BRANCH_CANONICAL_PATH%".
    exit /b 4
  ) >&2
)

set "BRANCH_ROOT_PATH=%SVN_BRANCH_PATH%"

set "BRANCH_EXTERNALS_INFO_FILE_TMP=%GEN_BRANCH_TEMP_FILE_DIR%\$info.txt"
set "BRANCH_EXTERNALS_LIST_FILE_TMP=%GEN_BRANCH_TEMP_FILE_DIR%\$externals.lst"
set "BRANCH_ROOT_ALL_FILES_LIST_FILE_TMP=%GEN_BRANCH_TEMP_FILE_DIR%\root_all_files.lst"

set "BRANCH_WORKINGSET_CATALOG_BINARY_DIFF_DIR=%BRANCH_WORKINGSET_CATALOG_DIR%"

if not exist "%BRANCH_WORKINGSET_FILE_DIR%" (
  echo.%?~nx0%: error: SVN branch workingset file directory does not exist: "%BRANCH_WORKINGSET_FILE_DIR%".
  exit /b 10
) >&2

if "%BRANCH_WORKINGSET_FILE%" == "" (
  echo.%?~nx0%: error: SVN branch workingset file is not set.
  exit /b 11
) >&2

if %FLAG_SVN_STATUS_FILES% NEQ 0 ^
if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 (
  rem ignore special case with autodetect, where branch directory is not SVN WC directory, but under autodetect and won't be processed for paths truncation anyway
  if %FLAG_SVN_AUTO_DETECT% EQU 0 (
    echo.%?~nx0%: error: SVN status must be requested from working copy directories only: SVN_BRANCH_CANONICAL_PATH="%SVN_BRANCH_CANONICAL_PATH%".
    exit /b 12
  ) >&2

  if "%BRANCH_ROOT_ALLSTATUS_FILE%" == "" if "%BRANCH_ROOT_STATUS_FILE%" == "" (
    echo.%?~nx0%: error: at least one file path must be defined to generate SVN status information.
    exit /b 13
  ) >&2
)

if %FLAG_SVN_OFFLINE% NEQ 0 ^
if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 (
  rem ignore special case with autodetect, where branch directory is not SVN WC directory, but under autodetect and won't be processed for paths truncation anyway
  if %FLAG_SVN_AUTO_DETECT% EQU 0 (
    echo.%?~nx0%: error: SVN offline mode must be requested from working copy directories only: SVN_BRANCH_CANONICAL_PATH="%SVN_BRANCH_CANONICAL_PATH%".
    exit /b 14
  ) >&2
)

rem always create an empty file
type nul > "%BRANCH_WORKINGSET_FILE%"

rem set a current directory for shortened path values in output from svn commands (for example: svn info)
if %SVN_BRANCH_PATH_IS_WC_URL%%FLAG_SVN_AUTO_DETECT% GTR 0 (
  pushd "%SVN_BRANCH_PATH%" && (
    call :MAIN_IMPL
    popd
  )
) else call :MAIN_IMPL

goto :EOF

:MAIN_IMPL
rem if auto discovery is enabled then do list directories under SVN version control recursively, otherwise use a requested directory directly
set "BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH="
set "BRANCH_EXTERNAL_BASE_PATH="
set "SVN_BRANCH_REL_SUB_PATH=."
set BRANCH_AUTO_DETECT=0

rem requested directory already under SVN version control, query directory directly
if %SVN_BRANCH_URI_IS_LOCAL% EQU 0 goto IMPL
if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 goto IMPL
if %SVN_BRANCH_PATH_IS_LOCAL_REPO_URL% NEQ 0 goto IMPL

if %FLAG_SVN_AUTO_DETECT% EQU 0 (
  echo.%?~nx0%: error: SVN_BRANCH_CANONICAL_PATH is not under SVN version control: "%SVN_BRANCH_CANONICAL_PATH%".
  exit /b 15
) >&2

set BRANCH_AUTO_DETECT=1

rem always create an empty file
type nul > "%BRANCH_ROOT_ALLFILES_FILE%"
type nul > "%BRANCH_ROOT_ALLFILES_HASH_FILE%"

set "SVN_BRANCH_SUB_PATH_LAST="
for /F "usebackq eol= tokens=* delims=" %%i in (`dir /S /B /A:D "*.svn" 2^>nul`) do (
  set "SVN_BRANCH_SUB_PATH=%%i"
  call :BRANCH_SUB_PATH "%%SVN_BRANCH_SUB_PATH%%\.." || goto :EOF
)

if "%SVN_BRANCH_SUB_PATH_LAST%" == "" (
  echo.%?~nx0%: warning: SVN version control directories is not found: "%SVN_BRANCH_CANONICAL_PATH%".
  exit /b -1
) >&2

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  if %FLAG_SVN_LIST_FILES% NEQ 0 ( call :GEN_BRANCH_ALL_FILES_HASH_LIST || goto :EOF )
)

exit /b 0

:BRANCH_SUB_PATH
set "SVN_BRANCH_SUB_PATH=%~dpf1"

if "%SVN_BRANCH_SUB_PATH_LAST%" == "" goto BRANCH_SUB_PATH_VALID

call set "SVN_BRANCH_SUB_PATH_LAST_SUFFIX=%%SVN_BRANCH_SUB_PATH:%SVN_BRANCH_SUB_PATH_LAST%=%%"
rem ignore duplication and recursion
if "%SVN_BRANCH_SUB_PATH_LAST_SUFFIX%" == "" exit /b 0
if "%SVN_BRANCH_SUB_PATH_LAST_SUFFIX:~0,1%" == "\" exit /b 0

:BRANCH_SUB_PATH_VALID
set "SVN_BRANCH_SUB_PATH_LAST=%SVN_BRANCH_SUB_PATH%"

setlocal

rem treat autodetected path as SVN WC root path
set SVN_BRANCH_PATH_IS_WC_URL=1

rem SVN WC root path should not be empty
set "SVN_BRANCH_WCROOT_PATH=%SVN_BRANCH_SUB_PATH%"

rem test path on consistency
call set "SVN_BRANCH_REL_SUB_PATH=%%SVN_BRANCH_SUB_PATH:%CD%=%%"
if not "%SVN_BRANCH_REL_SUB_PATH%" == "" (
  if "%SVN_BRANCH_REL_SUB_PATH:~0,1%" == "\" set "SVN_BRANCH_REL_SUB_PATH=%SVN_BRANCH_REL_SUB_PATH:~1%"
) else (
  echo.%?~nx0%: error: SVN branch path should not be a current directory here: SVN_BRANCH_SUB_PATH="%SVN_BRANCH_SUB_PATH%" CD="%CD%".
  exit /b 16
) >&2

rem test if SVN_BRANCH_SUB_PATH inside current directory path
if /i not "%CD%\%SVN_BRANCH_REL_SUB_PATH%" == "%SVN_BRANCH_SUB_PATH%" (
  echo.%?~nx0%: error: current directory path is not base path for SVN branch path: SVN_BRANCH_SUB_PATH="%SVN_BRANCH_SUB_PATH%" CD="%CD%".
  exit /b 17
) >&2

if not "%SVN_BRANCH_REL_SUB_PATH%" == "" set "SVN_BRANCH_REL_SUB_PATH=%SVN_BRANCH_REL_SUB_PATH:\=/%"

set "BRANCH_WORKINGSET_CATALOG_DIR=%BRANCH_WORKINGSET_CATALOG_DIR%\%SVN_BRANCH_REL_SUB_PATH:/=--%"
set "BRANCH_ROOT_INFO_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$info.txt"
set "BRANCH_ROOT_CHANGESET_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$changeset.lst"
set "BRANCH_ROOT_DIFF_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$diff.patch"
set "BRANCH_ROOT_EXTERNALS_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$externals.lst"
set "BRANCH_ROOT_FILES_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$files.lst"
set "BRANCH_ROOT_STATUS_FILE=%BRANCH_WORKINGSET_CATALOG_DIR%\$status.txt"

set "BRANCH_WORKINGSET_CATALOG_BINARY_DIFF_DIR=%BRANCH_WORKINGSET_CATALOG_DIR%"

set "SVN_BRANCH_PATH=%SVN_BRANCH_REL_SUB_PATH%"
set "BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH=%SVN_BRANCH_REL_SUB_PATH%"
set "BRANCH_EXTERNAL_BASE_PATH=%SVN_BRANCH_REL_SUB_PATH%"

:IMPL
rmdir /S /Q "%BRANCH_WORKINGSET_CATALOG_DIR%" 2> nul
mkdir "%BRANCH_WORKINGSET_CATALOG_DIR%"

rem SVN info

if exist "%BRANCH_ROOT_INFO_FILE_DIR%" (
  echo.Generating SVN branch root info and version into file...
  echo.  "%BRANCH_ROOT_INFO_FILE%"

  rem always create an empty file
  type nul > "%BRANCH_ROOT_INFO_FILE%"

  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    svn info "%SVN_BRANCH_REL_SUB_PATH%" --non-interactive > "%BRANCH_ROOT_INFO_FILE%" || exit /b 20
  ) else (
    svn info "%SVN_BRANCH_CANONICAL_PATH%" --non-interactive > "%BRANCH_ROOT_INFO_FILE%" || exit /b 20
  )

  set "BRANCH_VERID="
  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    rem save svnversion output in case commit w/o update been made
    for /F "usebackq eol= tokens=* delims=" %%i in (`svnversion "%SVN_BRANCH_CANONICAL_PATH%"`) do set "BRANCH_VERID=%%i"

    (call echo.VerID: %%BRANCH_VERID%%)>> "%BRANCH_ROOT_INFO_FILE%"
  )
)

if not exist "%BRANCH_ROOT_INFO_FILE%" (
  echo.%?~nx0%: error: BRANCH_ROOT_INFO_FILE does not exist: "%BRANCH_ROOT_INFO_FILE%".
  exit /b 21
) >&2

if %FLAG_SVN_DIFF_RA% NEQ 0 (
  call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_ROOT_INFO_FILE%%" "Last Changed Rev" || (
    echo.%?~nx0%: error: "Last Changed Rev" property is not found in SVN info file: "%BRANCH_ROOT_INFO_FILE%".
    exit /b 22
  ) >&2
)
if %FLAG_SVN_DIFF_RA% NEQ 0 set "BRANCH_ROOT_LAST_REV=%RETURN_VALUE%"

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_ROOT_INFO_FILE%%" "Revision"
set "BRANCH_ROOT_CURRENT_REV=%RETURN_VALUE%"
if "%BRANCH_ROOT_CURRENT_REV%" == "" (
  echo.%?~nx0%: error: `Revision` property is not found in SVN info file: "%BRANCH_ROOT_INFO_FILE%".
  exit /b 23
) >&2

rem SVN changeset (wc.db direct request)

if exist "%BRANCH_ROOT_CHANGESET_FILE_DIR%" (
  echo.Generating SVN branch root changeset into file...
  echo.  "%BRANCH_ROOT_CHANGESET_FILE%"

  rem always create an empty file
  type nul > "%BRANCH_ROOT_CHANGESET_FILE%"

  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    rem set a current directory for the svn_changeset.bat script
    pushd "%SVN_BRANCH_PATH%" && (
      call "%%SVNCMD_TOOLS_ROOT%%/svn_changeset.bat" -r "!%%BRANCH_ROOT_CURRENT_REV%%" -wcroot "%%SVN_BRANCH_WCROOT_PATH%%" > "%BRANCH_ROOT_CHANGESET_FILE%" || ( popd & exit /b 24 )
      popd
    )
  )
)

if not exist "%BRANCH_ROOT_CHANGESET_FILE%" (
  echo.%?~nx0%: error: BRANCH_ROOT_CHANGESET_FILE does not exist: "%BRANCH_ROOT_CHANGESET_FILE%".
  exit /b 25
) >&2

rem SVN diff

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  if exist "%BRANCH_ROOT_DIFF_FILE_DIR%" (
    echo.Generating SVN branch root diff into file...
    echo.  "%BRANCH_ROOT_DIFF_FILE%"

    rem always create an empty file
    type nul > "%BRANCH_ROOT_DIFF_FILE%"

    rem set a current directory for relative paths in a diff file
    pushd "%SVN_BRANCH_PATH%" && (
      rem WARNING: "-r <Last Changed Rev>" will request a file from the SVN server!
      if %FLAG_SVN_DIFF_RA% EQU 0 (
        svn diff . --non-interactive > "%BRANCH_ROOT_DIFF_FILE%" || ( popd & exit /b 26 )
      ) else (
        svn diff -r "%BRANCH_ROOT_LAST_REV%" . --non-interactive > "%BRANCH_ROOT_DIFF_FILE%" || ( popd & exit /b 26 )
      )

      rem Resolve binary differences which could not been displayed in the difference file and index add/remove
      call :RESOLVE_BINARY_DIFFERENCES "%%BRANCH_ROOT_DIFF_FILE%%" "%%BRANCH_WORKINGSET_CATALOG_BINARY_DIFF_DIR%%" || ( popd & exit /b 27 )

      popd
    )
  )
) else if exist "%BRANCH_ROOT_DIFF_FILE_DIR%" (
  rem root diff file must exist even if empty
  type nul > "%BRANCH_ROOT_DIFF_FILE%"
  rem del /F /Q /A:-D "%BRANCH_ROOT_DIFF_FILE:/=\%" 2> nul
)
  
if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 ^
if not exist "%BRANCH_ROOT_DIFF_FILE%" (
  echo.%?~nx0%: error: BRANCH_ROOT_DIFF_FILE does not exist: "%BRANCH_ROOT_DIFF_FILE%".
  exit /b 28
) >&2

rem SVN externals

if exist "%BRANCH_ROOT_EXTERNALS_FILE_DIR%" (
  echo.Generating SVN branch root externals list into file...
  echo.  "%BRANCH_ROOT_EXTERNALS_FILE%"

  rem always create an empty file
  type nul > "%BRANCH_ROOT_EXTERNALS_FILE%"

  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    rem set a current directory for "svn pget" command to reduce path lengths in output
    pushd "%SVN_BRANCH_PATH%" && (
      svn pget svn:externals . %FLAG_SVN_EXTERNALS_PROPGET% --non-interactive > "%BRANCH_ROOT_EXTERNALS_FILE%" 2>nul
      popd
    )
  ) else (
    svn pget svn:externals "%SVN_BRANCH_CANONICAL_PATH%" %FLAG_SVN_EXTERNALS_PROPGET% --non-interactive > "%BRANCH_ROOT_EXTERNALS_FILE%" 2>nul
  )
)

if not exist "%BRANCH_ROOT_EXTERNALS_FILE%" (
  echo.%?~nx0%: error: BRANCH_ROOT_EXTERNALS_FILE does not exist: "%BRANCH_ROOT_EXTERNALS_FILE%".
  exit /b 29
) >&2

if "%BRANCH_WORKINGSET_CATALOG_DIR%" == "" (
  echo.%?~nx0%: error: BRANCH_WORKINGSET_CATALOG_DIR is not set, workingset won't be generated.
  exit /b 30
) >&2

if %FLAG_SVN_LIST_FILES% NEQ 0 (
  echo.Generating SVN branch root files list into files...
  echo.  "%BRANCH_ROOT_FILES_FILE%"
  echo.  "%BRANCH_ROOT_ALLFILES_FILE%"

  if %BRANCH_AUTO_DETECT% EQU 0 (
    rem always create an empty file
    type nul > "%BRANCH_ROOT_ALLFILES_FILE%"
    type nul > "%BRANCH_ROOT_ALLFILES_HASH_FILE%"
  )

  rem always create an empty file
  type nul > "%BRANCH_ROOT_FILES_FILE%"

  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    rem set a current directory for "svn ls" command to reduce path lengths in output and from there the ".svn" directory search up to the root
    pushd "%SVN_BRANCH_PATH%" && (
      call "%%SVNCMD_TOOLS_ROOT%%/svn_list.bat" %%FLAG_TEXT_SVN_OFFLINE%% -wcroot "%%SVN_BRANCH_WCROOT_PATH%%" . --depth infinity --non-interactive > "%BRANCH_ROOT_FILES_FILE%" 2>nul
      popd
    )
  ) else (
    svn ls "%SVN_BRANCH_CANONICAL_PATH%" --depth infinity --non-interactive > "%BRANCH_ROOT_FILES_FILE%" 2>nul
  )

  if not "%BRANCH_EXTERNAL_BASE_PATH%" == "" (
    type "%BRANCH_ROOT_FILES_FILE%" | "%GNUWIN32_ROOT%/bin/sed.exe" -e "s|^|%BRANCH_EXTERNAL_BASE_PATH%/|" >> "%BRANCH_ROOT_ALLFILES_FILE%"
  ) else (
    type "%BRANCH_ROOT_FILES_FILE%" >> "%BRANCH_ROOT_ALLFILES_FILE%"
  )
)

if %FLAG_SVN_LIST_FILES% NEQ 0 (
  if not exist "%BRANCH_ROOT_ALLFILES_FILE%" (
    echo.%?~nx0%: error: BRANCH_ROOT_ALLFILES_FILE does not exist: "%BRANCH_ROOT_ALLFILES_FILE%".
    exit /b 31
  ) >&2

  if not exist "%BRANCH_ROOT_FILES_FILE%" (
    echo.%?~nx0%: error: BRANCH_ROOT_FILES_FILE does not exist: "%BRANCH_ROOT_FILES_FILE%".
    exit /b 32
  ) >&2
)

if %FLAG_SVN_STATUS_FILES% NEQ 0 ^
if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 (
  echo.Generating SVN branch root status into files...
  echo.  "%BRANCH_ROOT_STATUS_FILE%"
  echo.  "%BRANCH_ROOT_ALLSTATUS_FILE%"

  rem always create an empty file
  type nul > "%BRANCH_ROOT_ALLSTATUS_FILE%"

  if not "%BRANCH_ROOT_ALLSTATUS_FILE%" == "" (
    rem set a current directory for "svn status" command to reduce path lengths in output
    pushd "%SVN_BRANCH_PATH%" && (
      if %FLAG_FINDSTR_HAS_EXCLUDES% EQU 0 (
        svn status . --depth infinity --non-interactive 2>nul > "%BRANCH_ROOT_ALLSTATUS_FILE%"
      ) else (
        svn status . --depth infinity --non-interactive 2>nul | findstr.exe /R /V %FLAG_TEXT_FINDSTR_EXCLUDE_ARGS% > "%BRANCH_ROOT_ALLSTATUS_FILE%"
      )
      popd
    )
  )

  rem always create an empty file
  type nul > "%BRANCH_ROOT_STATUS_FILE%"

  if not "%BRANCH_ROOT_STATUS_FILE%" == "" (
    rem set a current directory for "svn status" command to reduce path lengths in output
    pushd "%SVN_BRANCH_PATH%" && (
      if %FLAG_FINDSTR_HAS_EXCLUDES% EQU 0 (
        svn status . --depth infinity --ignore-externals --non-interactive 2>nul > "%BRANCH_ROOT_STATUS_FILE%"
      ) else (
        svn status . --depth infinity --ignore-externals --non-interactive 2>nul | findstr.exe /R /V %FLAG_TEXT_FINDSTR_EXCLUDE_ARGS% > "%BRANCH_ROOT_STATUS_FILE%"
      )
      popd
    )
  )
)

echo.Generating SVN branch workingset file and catalog...
echo.  "%BRANCH_WORKINGSET_FILE%"
echo.  "%BRANCH_WORKINGSET_CATALOG_DIR%"

rem parse externals from the root recursively
call :EXTRACT_ROOT_EXTERNALS || goto :EOF

echo.

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  if %BRANCH_AUTO_DETECT% EQU 0 (
    if %FLAG_SVN_LIST_FILES% NEQ 0 ( call :GEN_BRANCH_ALL_FILES_HASH_LIST || goto :EOF )
  )
)

exit /b 0

:GEN_BRANCH_ALL_FILES_HASH_LIST
echo.Generating SVN branch(es) all files hash list...
echo.  "%BRANCH_ROOT_ALLFILES_HASH_FILE%"

rem always create an empty file
type nul > "%BRANCH_ROOT_ALLFILES_HASH_FILE%"

rem for "svn ls" we must convert from ANSI to UTF-8 explicitly (hashdeep.exe requirement)
if %FLAG_SVN_OFFLINE% EQU 0 call :CONVERT_ROOT_ALLFILES_FILE
goto CONVERT_ROOT_ALLFILES_FILE_END

:CONVERT_ROOT_ALLFILES_FILE
rem read defaul ansi iconv locale name
set /P ICONV_DEFAULT_ANSI_LOCALE=< "%VARS_ROOT%/vars/iconv.default_ansi_locale.var"

call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "%%ICONV_DEFAULT_ANSI_LOCALE%%" UTF-8 "%%BRANCH_ROOT_ALLFILES_FILE%%" > "%BRANCH_ROOT_ALL_FILES_LIST_FILE_TMP%"

copy /Y /B "%BRANCH_ROOT_ALL_FILES_LIST_FILE_TMP%" "%BRANCH_ROOT_ALLFILES_NAME%%BRANCH_ROOT_ALLFILES_EXT%" >nul
del /F /Q /A:-D "%BRANCH_ROOT_ALL_FILES_LIST_FILE_TMP%"

goto :EOF

:CONVERT_ROOT_ALLFILES_FILE_END

rem HashDeep KNOWN ISSUES:
rem 1. Currently suppress errors generated by directories in list because HashDeep incorrectly handles directories in the list:
rem    https://github.com/jessek/hashdeep/issues/351
rem 2. Use single thread execution because overwise output file will be too randomly sorted:
rem    https://github.com/jessek/hashdeep/issues/353
call "%%CONTOOLS_ROOT%%/gen_dir_hash_lst.bat" -j 0 -c "md5,sha256" -l -f "%%BRANCH_ROOT_ALLFILES_FILE%%" 2>nul > "%BRANCH_ROOT_ALLFILES_DIR%%BRANCH_ROOT_ALLFILES_NAME%_hash.lst"
echo.

exit /b 0

:EXTRACT_ROOT_EXTERNALS
setlocal

set BRANCH_NEST_INDEX=1

set "BRANCH_INFO_FILE=%BRANCH_ROOT_INFO_FILE%"
set "BRANCH_EXTERNALS_FILE=%BRANCH_ROOT_EXTERNALS_FILE%"
set "BRANCH_WORKINGSET_CATALOG_DIR_NEXT=%BRANCH_WORKINGSET_CATALOG_DIR%"
set "BRANCH_EXTERNAL_DIR_PATH_PREFIX="

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "URL"
set "BRANCH_DIR_URL=%RETURN_VALUE%"
if "%BRANCH_DIR_URL%" == "" (
  echo.%?~nx0%: error: `URL` property is not found in SVN info file: "%BRANCH_INFO_FILE%".
  exit /b 40
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "Repository Root"
set "BRANCH_REPO_ROOT=%RETURN_VALUE%"
if "%BRANCH_REPO_ROOT%" == "" (
  echo.%?~nx0%: error: `Repository Root` property is not found in SVN info file: "%BRANCH_INFO_FILE%".
  exit /b 41
) >&2

rem postprocess externals list
call :POST_PROCESS_EXTERNALS_FILE || goto :EOF

if %BRANCH_AUTO_DETECT% NEQ 0 ( call :PROCESS_ROOT_BRANCH_PATH || goto :EOF )

goto EXTRACT_ROOT_EXTERNALS_IMPL

:PROCESS_ROOT_BRANCH_PATH
call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_ROOT_INFO_FILE%%" "Revision"
set "BRANCH_EXTERNAL_CURRENT_REV=%RETURN_VALUE%"
if "%BRANCH_EXTERNAL_CURRENT_REV%" == "" (
  echo.%?~nx0%: error: `Revision` property is not found in SVN info file: "%BRANCH_ROOT_INFO_FILE%".
  exit /b 42
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_ROOT_INFO_FILE%%" "Last Changed Rev"
set "BRANCH_EXTERNAL_LAST_REV=%RETURN_VALUE%"
if "%BRANCH_EXTERNAL_LAST_REV%" == "" (
  echo.%?~nx0%: error: `Last Changed Rev` property is not found in SVN info file: "%BRANCH_ROOT_INFO_FILE%".
  exit /b 43
) >&2

rem use svnversion utility output instead of current revision if have any, because more informative
set "BRANCH_EXTERNAL_CURRENT_REV_VERID_STR=%BRANCH_EXTERNAL_CURRENT_REV%"
if not "%BRANCH_VERID%" == "" set "BRANCH_EXTERNAL_CURRENT_REV_VERID_STR=%BRANCH_VERID%"

(echo.%BRANCH_EXTERNAL_CURRENT_REV%^|%BRANCH_EXTERNAL_LAST_REV%^|%BRANCH_EXTERNAL_CURRENT_REV_VERID_STR%^|%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%^|%BRANCH_DIR_URL%^|0^|0)>> "%BRANCH_WORKINGSET_FILE%"
echo.%BRANCH_EXTERNAL_CURRENT_REV%^|%BRANCH_EXTERNAL_LAST_REV%^|%BRANCH_EXTERNAL_CURRENT_REV_VERID_STR%^|%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%^|%BRANCH_DIR_URL%^|0^|0

exit /b 0

:EXTRACT_EXTERNALS
setlocal

set /A BRANCH_NEST_INDEX+=1

if not "%BRANCH_EXTERNAL_BASE_PATH%" == "" (
  set "BRANCH_EXTERNAL_BASE_PATH=%BRANCH_EXTERNAL_BASE_PATH%/%BRANCH_EXTERNAL_DIR_PATH%"
) else (
  set "BRANCH_EXTERNAL_BASE_PATH=%BRANCH_EXTERNAL_DIR_PATH%"
)
if not "%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%" == "" (
  set "BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH=%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%:%BRANCH_WORKINGSET_CATALOG_DIR_PATH%"
) else (
  set "BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH=%BRANCH_WORKINGSET_CATALOG_DIR_PATH%"
)
set "BRANCH_INFO_FILE=%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt"
set "BRANCH_EXTERNALS_FILE=%BRANCH_WORKINGSET_CATALOG_PATH%/$externals.lst"
set "BRANCH_WORKINGSET_CATALOG_DIR_NEXT=%BRANCH_WORKINGSET_CATALOG_PATH%"

rem echo BRANCH_INFO_FILE=%BRANCH_INFO_FILE%

rem postprocess externals list
call :POST_PROCESS_EXTERNALS_FILE || goto :EOF

:EXTRACT_ROOT_EXTERNALS_IMPL
for /F "usebackq eol= tokens=1,2,3,4,* delims=|" %%i in ("%BRANCH_EXTERNALS_FILE%") do (
  set "BRANCH_EXTERNAL_DIR_PATH_PREFIX=%%i"
  set "BRANCH_EXTERNAL_DIR_PATH=%%j"
  set "BRANCH_EXTERNAL_URI_REV_OPERATIVE=%%k"
  set "BRANCH_EXTERNAL_URI_REV_PEG=%%l"
  set "BRANCH_EXTERNAL_URI=%%m"
  call :PROCESS_EXTERNAL
)
goto :EOF

:PROCESS_EXTERNAL
if "%BRANCH_EXTERNAL_URI_REV_OPERATIVE%" == "0" set "BRANCH_EXTERNAL_URI_REV_OPERATIVE="
if "%BRANCH_EXTERNAL_URI_REV_PEG%" == "0" set "BRANCH_EXTERNAL_URI_REV_PEG="

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "Path"
set "BRANCH_WORKING_PATH=%RETURN_VALUE%"
if "%BRANCH_WORKING_PATH%" == "" (
  echo.%?~nx0%: error: `Path` property is not found in SVN info file: "%BRANCH_INFO_FILE%".
  exit /b 44
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "URL"
set "BRANCH_DIR_URL=%RETURN_VALUE%"
if "%BRANCH_DIR_URL%" == "" (
  echo.%?~nx0%: error: `URL` property is not found in SVN info file: "%BRANCH_INFO_FILE%".
  exit /b 45
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_INFO_FILE%%" "Repository Root"
set "BRANCH_REPO_ROOT=%RETURN_VALUE%"
if "%BRANCH_REPO_ROOT%" == "" (
  echo.%?~nx0%: error: `Repository Root` property is not found in SVN info file: "%BRANCH_INFO_FILE%".
  exit /b 46
) >&2

if "%BRANCH_EXTERNAL_DIR_PATH_PREFIX%" == "" goto BRANCH_EXTERNAL_DIR_PATH_PREFIX_EMPTY

rem remove root URL from BRANCH_EXTERNAL_DIR_PATH_PREFIX if SVN_BRANCH_URI is canonical

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 goto BRANCH_EXTERNAL_DIR_PATH_PREFIX_IS_WC_URL_END

call set "BRANCH_EXTERNAL_DIR_PATH_PREFIX_SUFFIX=%%BRANCH_EXTERNAL_DIR_PATH_PREFIX:*%BRANCH_DIR_URL%=%%"

if not "%BRANCH_EXTERNAL_DIR_PATH_PREFIX_SUFFIX%" == "%BRANCH_EXTERNAL_DIR_PATH_PREFIX%" ^
if "%BRANCH_DIR_URL%%BRANCH_EXTERNAL_DIR_PATH_PREFIX_SUFFIX%" == "%BRANCH_EXTERNAL_DIR_PATH_PREFIX%" (
  set "BRANCH_EXTERNAL_DIR_PATH_PREFIX=%BRANCH_EXTERNAL_DIR_PATH_PREFIX_SUFFIX%"
)

if "%BRANCH_EXTERNAL_DIR_PATH_PREFIX%" == "" set BRANCH_EXTERNAL_DIR_PATH_PREFIX=.
if "%BRANCH_EXTERNAL_DIR_PATH_PREFIX:~0,1%" == "/" set "BRANCH_EXTERNAL_DIR_PATH_PREFIX=%BRANCH_EXTERNAL_DIR_PATH_PREFIX:~1%"

:BRANCH_EXTERNAL_DIR_PATH_PREFIX_IS_WC_URL_END

if "%BRANCH_EXTERNAL_DIR_PATH_PREFIX:~-1%" == "/" set "BRANCH_EXTERNAL_DIR_PATH_PREFIX=%BRANCH_EXTERNAL_DIR_PATH_PREFIX:~0,-1%"

if "%BRANCH_EXTERNAL_DIR_PATH_PREFIX%" == "." goto BRANCH_EXTERNAL_DIR_PATH_PREFIX_EMPTY

rem subfolder (not root) external
set "BRANCH_WORKINGSET_CATALOG_DIR_PATH=%BRANCH_EXTERNAL_DIR_PATH_PREFIX%:#%BRANCH_EXTERNAL_DIR_PATH%"
set "BRANCH_WORKINGSET_CATALOG_DIR_NAME=%BRANCH_EXTERNAL_DIR_PATH_PREFIX:/=--%/#%BRANCH_EXTERNAL_DIR_PATH:/=--%"
set "BRANCH_EXTERNAL_DIR_PATH=%BRANCH_EXTERNAL_DIR_PATH_PREFIX%/%BRANCH_EXTERNAL_DIR_PATH%"

goto BRANCH_EXTERNAL_DIR_PATH_PREFIX_EMPTY_END

:BRANCH_EXTERNAL_DIR_PATH_PREFIX_EMPTY
set "BRANCH_WORKINGSET_CATALOG_DIR_PATH=#%BRANCH_EXTERNAL_DIR_PATH%"
set "BRANCH_WORKINGSET_CATALOG_DIR_NAME=#%BRANCH_EXTERNAL_DIR_PATH:/=--%"
:BRANCH_EXTERNAL_DIR_PATH_PREFIX_EMPTY_END

set "BRANCH_WORKINGSET_CATALOG_PATH=%BRANCH_WORKINGSET_CATALOG_DIR_NEXT%/%BRANCH_WORKINGSET_CATALOG_DIR_NAME%"
if not exist "%BRANCH_WORKINGSET_CATALOG_PATH%" mkdir "%BRANCH_WORKINGSET_CATALOG_PATH%"

set "BRANCH_WORKINGSET_CATALOG_BINARY_DIFF_DIR=%BRANCH_WORKINGSET_CATALOG_PATH%"

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  set "BRANCH_EXTERNAL_WORKING_PATH=%BRANCH_WORKING_PATH%\%BRANCH_EXTERNAL_DIR_PATH:/=\%"
) else (
  set "BRANCH_EXTERNAL_WORKING_PATH=%BRANCH_EXTERNAL_URI:\=/%"
)

rem SVN info

rem always create an empty file
type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt"

svn info "%BRANCH_EXTERNAL_WORKING_PATH%" --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt" || exit /b 47

if %FLAG_SVN_REL_FILE_PATHS_ONLY% NEQ 0 call :FILTER_NESTED_INFO_FILE "%%BRANCH_WORKINGSET_CATALOG_PATH%%/$info.txt"
goto FILTER_NESTED_INFO_FILE_END

:FILTER_NESTED_INFO_FILE
setlocal

set "SED_BRANCH_ROOT_PATH=%BRANCH_ROOT_PATH:/=\%"
set "SED_BRANCH_ROOT_PATH=%SED_BRANCH_ROOT_PATH:\=\\%"
set "SED_SEARCH_STR=^Working Copy Root Path: %SED_BRANCH_ROOT_PATH%"
set "SED_REPLACE_STR=Working Copy Root Path: ."

type "%~dpf1" | "%GNUWIN32_ROOT%/bin/sed.exe" -b -e "s|%SED_SEARCH_STR%|%SED_REPLACE_STR%|img" > "%BRANCH_EXTERNALS_INFO_FILE_TMP%"

copy /Y /B "%BRANCH_EXTERNALS_INFO_FILE_TMP%" "%~dpf1" >nul
del /F /Q /A:-D "%BRANCH_EXTERNALS_INFO_FILE_TMP%"

goto :EOF

:FILTER_NESTED_INFO_FILE_END

set "BRANCH_VERID="
if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  rem save svnversion output in case commit w/o update been made
  for /F "usebackq eol= tokens=* delims=" %%i in (`svnversion "%BRANCH_EXTERNAL_WORKING_PATH%"`) do set "BRANCH_VERID=%%i"

  (call echo.VerID: %%BRANCH_VERID%%)>> "%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt"
)

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_WORKINGSET_CATALOG_PATH%%/$info.txt" "Revision"
set "BRANCH_EXTERNAL_CURRENT_REV=%RETURN_VALUE%"
if "%BRANCH_EXTERNAL_CURRENT_REV%" == "" (
  echo.%?~nx0%: error: `Revision` property is not found in SVN info file: "%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt".
  exit /b 48
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%BRANCH_WORKINGSET_CATALOG_PATH%%/$info.txt" "Last Changed Rev"
set "BRANCH_EXTERNAL_LAST_REV=%RETURN_VALUE%"
if "%BRANCH_EXTERNAL_LAST_REV%" == "" (
  echo.%?~nx0%: error: `Last Changed Rev` property is not found in SVN info file: "%BRANCH_WORKINGSET_CATALOG_PATH%/$info.txt".
  exit /b 49
) >&2

rem SVN changeset (wc.db direct request)

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  rem always create an empty file
  type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$changeset.lst"

  rem set a current directory for the svn_changeset.bat script
  pushd "%BRANCH_EXTERNAL_WORKING_PATH%" && (
    call "%%SVNCMD_TOOLS_ROOT%%/svn_changeset.bat" -r "!%%BRANCH_EXTERNAL_CURRENT_REV%%" > "%BRANCH_WORKINGSET_CATALOG_PATH%/$changeset.lst" || ( popd & exit /b 50 )
    popd
  )
)

rem SVN diff

rem always create an empty file
type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$diff.patch"

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  rem set a current directory for relative paths in a patch file
  pushd "%BRANCH_EXTERNAL_WORKING_PATH%" && (
    rem WARNING: "-r <Last Changed Rev>" will request a file from the SVN server!
    if %FLAG_SVN_DIFF_RA% EQU 0 (
      svn diff . --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$diff.patch" || ( popd & exit /b 51 )
    ) else (
      svn diff -r "%BRANCH_EXTERNAL_LAST_REV%" . --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$diff.patch" || ( popd & exit /b 51 )
    )

    rem Resolve binary differences which could not been displayed in the difference file and index add/remove
    call :RESOLVE_BINARY_DIFFERENCES "%%BRANCH_WORKINGSET_CATALOG_PATH%%/$diff.patch" "%%BRANCH_WORKINGSET_CATALOG_BINARY_DIFF_DIR%%" || ( popd & exit /b 52 )

    popd
  )
)
rem else (
rem   rem always remove diff text file
rem   del /F /Q /A:-D "%BRANCH_WORKINGSET_CATALOG_PATH:/=\%\$diff.patch" 2> nul
rem )

rem always create an empty file
type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$externals.lst"

if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
  rem set a current directory for "svn pget" command to reduce path lengths in output
  pushd "%BRANCH_EXTERNAL_WORKING_PATH%" && (
    svn pget svn:externals . %FLAG_SVN_EXTERNALS_PROPGET% --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$externals.lst" 2>nul
    popd
  )
) else (
  svn pget svn:externals "%BRANCH_EXTERNAL_WORKING_PATH%" %FLAG_SVN_EXTERNALS_PROPGET% --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$externals.lst" 2>nul
)

if %FLAG_SVN_LIST_FILES% NEQ 0 (
  rem always create an empty file
  type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$files.lst"

  if %SVN_BRANCH_PATH_IS_WC_URL% NEQ 0 (
    rem set a current directory for "svn ls" command to reduce path lengths in output
    pushd "%BRANCH_EXTERNAL_WORKING_PATH%" && (
      call "%%SVNCMD_TOOLS_ROOT%%/svn_list.bat" %%FLAG_TEXT_SVN_OFFLINE%% . --depth infinity --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$files.lst" 2>nul
      popd
    )
  ) else (
    svn ls "%BRANCH_EXTERNAL_WORKING_PATH%" --depth infinity --non-interactive > "%BRANCH_WORKINGSET_CATALOG_PATH%/$files.lst" 2>nul
  )

  set "BRANCH_EXTERNAL_DIR_PATH_PREFIX2="
  if not "%BRANCH_EXTERNAL_BASE_PATH%" == "" set "BRANCH_EXTERNAL_DIR_PATH_PREFIX2=%BRANCH_EXTERNAL_BASE_PATH%/"
)

if %FLAG_SVN_LIST_FILES% NEQ 0 (
  type "%BRANCH_WORKINGSET_CATALOG_PATH:/=\%\$files.lst" | "%GNUWIN32_ROOT%/bin/sed.exe" -e "s|^|%BRANCH_EXTERNAL_DIR_PATH_PREFIX2%%BRANCH_EXTERNAL_DIR_PATH%/|" >> "%BRANCH_ROOT_ALLFILES_FILE%"
)

if %FLAG_SVN_STATUS_FILES% NEQ 0 ^
if %SVN_BRANCH_PATH_IS_WC_URL% EQU 0 (
  rem always create an empty file
  type nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$status.txt"

  rem set a current directory for "svn status" command to reduce path lengths in output
  pushd "%BRANCH_EXTERNAL_WORKING_PATH%" && (
    if %FLAG_FINDSTR_HAS_EXCLUDES% EQU 0 (
      svn status . --depth infinity --ignore-externals --non-interactive 2>nul > "%BRANCH_WORKINGSET_CATALOG_PATH%/$status.txt"
    ) else (
      svn status . --depth infinity --ignore-externals --non-interactive 2>nul | findstr.exe /R /V %FLAG_TEXT_FINDSTR_EXCLUDE_ARGS% > "%BRANCH_WORKINGSET_CATALOG_PATH%/$status.txt"
    )
    popd
  )
)

set "BRANCH_WORKINGSET_CATALOG_DIR_PATH_PREFIX="
if not "%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%" == "" set "BRANCH_WORKINGSET_CATALOG_DIR_PATH_PREFIX=%BRANCH_EXTERNAL_WORKINGSET_CATALOG_BASE_PATH%:"

rem use svnversion utility output instead of current revision if have any, because more informative
set "BRANCH_EXTERNAL_CURRENT_REV_VERID_STR=%BRANCH_EXTERNAL_CURRENT_REV%"
if not "%BRANCH_VERID%" == "" set "BRANCH_EXTERNAL_CURRENT_REV_VERID_STR=%BRANCH_VERID%"

if "%BRANCH_EXTERNAL_URI_REV_PEG%" == "" set BRANCH_EXTERNAL_URI_REV_PEG=0
if "%BRANCH_EXTERNAL_URI_REV_OPERATIVE%" == "" set BRANCH_EXTERNAL_URI_REV_OPERATIVE=0

(echo.%BRANCH_EXTERNAL_CURRENT_REV%^|%BRANCH_EXTERNAL_LAST_REV%^|%BRANCH_EXTERNAL_CURRENT_REV_VERID_STR%^|%BRANCH_WORKINGSET_CATALOG_DIR_PATH_PREFIX%%BRANCH_WORKINGSET_CATALOG_DIR_PATH%^|%BRANCH_EXTERNAL_URI%^|%BRANCH_EXTERNAL_URI_REV_PEG%^|%BRANCH_EXTERNAL_URI_REV_OPERATIVE%)>> "%BRANCH_WORKINGSET_FILE%"
echo.%BRANCH_EXTERNAL_CURRENT_REV%^|%BRANCH_EXTERNAL_LAST_REV%^|%BRANCH_EXTERNAL_CURRENT_REV_VERID_STR%^|%BRANCH_WORKINGSET_CATALOG_DIR_PATH_PREFIX%%BRANCH_WORKINGSET_CATALOG_DIR_PATH%^|%BRANCH_EXTERNAL_URI%^|%BRANCH_EXTERNAL_URI_REV_PEG%^|%BRANCH_EXTERNAL_URI_REV_OPERATIVE%

rem get branch info recursively from here

call :EXTRACT_EXTERNALS
goto :EOF

:POST_PROCESS_EXTERNALS_FILE
call "%%SVNCMD_TOOLS_ROOT%%/gen_externals_list.bat" "%%BRANCH_EXTERNALS_FILE%%" "%%BRANCH_REPO_ROOT%%" "%%BRANCH_DIR_URL%%" > "%BRANCH_EXTERNALS_LIST_FILE_TMP%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~nx0%: error: invalid svn:externals path transformation: EXTERNAL_FILE="%BRANCH_EXTERNALS_FILE%" REPO_ROOT="%BRANCH_REPO_ROOT%" ^
DIR_URL="%BRANCH_DIR_URL%".
  exit /b 53
) >&2

copy /Y /B "%BRANCH_EXTERNALS_LIST_FILE_TMP%" "%BRANCH_EXTERNALS_FILE%" >nul
del /F /Q /A:-D "%BRANCH_EXTERNALS_LIST_FILE_TMP%"

goto :EOF

:RESOLVE_BINARY_DIFFERENCES
setlocal

set "BRANCH_DIFF_FILE=%~1"
set "BRANCH_DIFF_FILE_DIR=%~dp1"
set "BRANCH_DIFF_FILE_NAME=%~n1"
set "BRANCH_BINARY_DIFF_DIR=%~2"

set HAS_TO_RESOLVE_COPY_FIRST_FILE=1
set HAS_TO_RESOLVE_ADD_FIRST_FILE=1
set HAS_TO_RESOLVE_REMOVE_FIRST_FILE=1

rem resolve binary differences by indexing difference file on unresolved state values
call "%%CONTOOLS_ROOT%%/index_patch_file.bat" BRANCH_DIFF_FILE_INDEX "%%BRANCH_DIFF_FILE%%"

if %RETURN_VALUE% LSS 1 exit /b 0
for /L %%i in (1,1,%RETURN_VALUE%) do (
  set BRANCH_DIFF_FILE_INDEX=%%i
  call :PROCESS_BINARY_DIFF_FILE_INDEX || goto :EOF
)

rem resolve add/remove files/directories by adding them to the special lists
for /F "usebackq eol= tokens=* delims=" %%i in (`svn status . --depth infinity --ignore-externals --non-interactive 2^>nul ^| findstr.exe /R /C:"^A "`) do (
  set "BRANCH_FILE_PATH=%%i"
  call :ADD_SVN_FILE || goto :EOF
)

for /F "usebackq eol= tokens=* delims=" %%i in (`svn status . --depth infinity --ignore-externals --non-interactive 2^>nul ^| findstr.exe /R /C:"^D "`) do (
  set "BRANCH_FILE_PATH=%%i"
  call :REMOVE_SVN_FILE || goto :EOF
)

exit /b 0

:PROCESS_BINARY_DIFF_FILE_INDEX
set BRANCH_DIFF_FILE_INDEX_VAR=BRANCH_DIFF_FILE_INDEX.%BRANCH_DIFF_FILE_INDEX%
call set "BRANCH_DIFF_FILE_INDEX_FILE=%%%BRANCH_DIFF_FILE_INDEX_VAR%.FILE%%"
call set "BRANCH_DIFF_FILE_INDEX_NODIFF=%%%BRANCH_DIFF_FILE_INDEX_VAR%.NODIFF%%"
call set "BRANCH_DIFF_FILE_INDEX_NONEXISTENT_BEFORE=%%%BRANCH_DIFF_FILE_INDEX_VAR%.NONEXISTENT_BEFORE%%"
call set "BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER=%%%BRANCH_DIFF_FILE_INDEX_VAR%.NONEXISTENT_AFTER%%"

if "%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_BEFORE%" == "" set BRANCH_DIFF_FILE_INDEX_NONEXISTENT_BEFORE=0
if "%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER%" == "" set BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER=0

if %BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER% EQU 0 (
  if not exist "%BRANCH_DIFF_FILE_INDEX_FILE%" (
    echo.%?~nx0%: error: Could not resolve binary file existence in difference file: BINARY_FILE="%BRANCH_DIFF_FILE_INDEX_FILE%" DIFF_FILE="%BRANCH_DIFF_FILE%" NONEXISTENT_BEFORE=%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_BEFORE% NONEXISTENT_AFTER=%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER%.
    exit /b 64
  ) >&2
) else if exist "%BRANCH_DIFF_FILE_INDEX_FILE%" (
  echo.%?~nx0%: error: Could not resolve binary file non existence in difference file: BINARY_FILE="%BRANCH_DIFF_FILE_INDEX_FILE%" DIFF_FILE="%BRANCH_DIFF_FILE%" NONEXISTENT_BEFORE=%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_BEFORE% NONEXISTENT_AFTER=%BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER%.
  exit /b 65
) >&2
rem copy file into workingset catalog if exists after patch but could not be displayed by a difference file
if %BRANCH_DIFF_FILE_INDEX_NONEXISTENT_AFTER% EQU 0 ^
if %BRANCH_DIFF_FILE_INDEX_NODIFF%0 NEQ 0 (
  call :COPY_BINARY_DIFF_FILE "%%BRANCH_DIFF_FILE_INDEX_FILE%%" "%%BRANCH_BINARY_DIFF_DIR%%/%%BRANCH_DIFF_FILE_INDEX_FILE%%" || exit /b 66
)

exit /b 0

:COPY_BINARY_DIFF_FILE
set "BRANCH_BINARY_FILE_DIR=%~dp1"
set "BRANCH_BINARY_FILE_NAME=%~nx1"

set "BRANCH_BINARY_DIFF_DIR_PATH=%~dp2"

if not exist "%BRANCH_BINARY_DIFF_DIR_PATH%" mkdir "%BRANCH_BINARY_DIFF_DIR_PATH%"

if %HAS_TO_RESOLVE_COPY_FIRST_FILE% NEQ 0 (
  set HAS_TO_RESOLVE_COPY_FIRST_FILE=0
  rem always create an empty file
  type nul > "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_copy.lst" || goto :EOF
)

call "%%CONTOOLS_ROOT%%/xcopy_file.bat" "%%BRANCH_BINARY_FILE_DIR%%" "%%BRANCH_BINARY_FILE_NAME%%" "%%BRANCH_BINARY_DIFF_DIR_PATH%%" /NJS || goto :EOF

rem register binary copy in the list
(echo.%BRANCH_DIFF_FILE_INDEX_FILE%)>> "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_copy.lst"

exit /b 0

:ADD_SVN_FILE
if %HAS_TO_RESOLVE_ADD_FIRST_FILE% NEQ 0 (
  set HAS_TO_RESOLVE_ADD_FIRST_FILE=0
  rem always create an empty file
  type nul > "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_added.lst" || goto :EOF
)

rem register "svn add" in the list
(echo.%BRANCH_FILE_PATH:~8%)>> "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_added.lst"

exit /b 0

:REMOVE_SVN_FILE
if %HAS_TO_RESOLVE_REMOVE_FIRST_FILE% NEQ 0 (
  set HAS_TO_RESOLVE_REMOVE_FIRST_FILE=0
  rem always create an empty file
  type nul > "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_removed.lst" || goto :EOF
)

rem register "svn remove" in the list
(echo.%BRANCH_FILE_PATH:~8%)>> "%BRANCH_DIFF_FILE_DIR%%BRANCH_DIFF_FILE_NAME%_removed.lst"

exit /b 0
