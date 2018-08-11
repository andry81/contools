@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Script to recursively find the SVN WC root directories from a set of local
rem directories and call
rem `tortoiseproc.exe /command:repostatus /pathfile:"<path-to-file-with-list-of-items-to-lookup-from>"`
rem or
rem `tortoiseproc.exe /command:commit /pathfile:"<path-to-file-with-list-of-items-to-lookup-from>"`
rem on them.

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

rem builtin defaults
if not defined TORTOISEPROC_MAX_CALLS set TORTOISEPROC_MAX_CALLS=10
if not defined TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS set TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS=20
set "TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP=pathfile-ansi-crlf.lst"
set "TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP=pathfile-ansi-crlf-filtered.lst"
set "TORTOISEPROC_PATHFILE_FILTER_NAME_ANSI_CRLF_TMP=pathfile-ansi-crlf-filter.lst"
set "TORTOISEPROC_PATHFILE_NOT_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP=pathfile-ansi-crlf-not-orphan-externals.lst"
set "TORTOISEPROC_PATHFILE_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP=pathfile-ansi-crlf-orphan-externals.lst"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem ==================== all-in-one process ====================

if %FLAG_ALL_IN_ONE% EQU 0 goto IGNORE_OUTTER_ALL_IN_ONE_PROCESS

if %FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS% EQU 0 ( call :FILTER_PATHFILE_BY_NOT_ORPHAN_EXTERNALS || goto EXIT_MAIN )
if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% NEQ 0 ( call :FILTER_PATHFILE_BY_VERSIONED_CHANGES || goto EXIT_MAIN )

rem convert dos line returns to unix
call "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%" > "%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%" || goto EXIT_MAIN
rem convert to UCS-16BE w/o bom
call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2LE "%%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%" || goto EXIT_MAIN
rem execute path file
if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%" /deletepathfile
)
set LASTERROR=%ERRORLEVEL%

goto EXIT_MAIN

:IGNORE_OUTTER_ALL_IN_ONE_PROCESS

rem ==================== window-per-reporoot process ====================

if %FLAG_WINDOW_PER_REPOROOT% EQU 0 goto IGNORE_OUTTER_WINDOW_PER_REPOROOT_PROCESS

rem to preserve the order through the dir command call
set REPOROOT_NEXT_INDEX=0

rem to prefix task index by number with zeros to correct order in case of single dir command
set REPOROOT_LAST_INDEX=%REPOROOT_INDEX%
call "%%CONTOOLS_ROOT%%/strlen.bat" /v REPOROOT_LAST_INDEX
set REPOROOT_LAST_INDEX_STR_LEN=%ERRORLEVEL%
set /A REPOROOT_LAST_INDEX_STR_LEN_INDEX=REPOROOT_LAST_INDEX_STR_LEN-1

for /F "usebackq eol=	 tokens=1,2 delims=|" %%i in ("%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%") do (
  set WCDIR_PATH=%%i
  set REPOROOT=%%j
  call :PREPROCESS_OUTTER_WINDOW_PER_REPOROOT
)
goto OUTTER_WINDOW_PER_REPOROOT_PREPROCESS_END

:PREPROCESS_OUTTER_WINDOW_PER_REPOROOT
if "%WCDIR_PATH:~-1%" == "\" set "WCDIR_PATH=%WCDIR_PATH:~0,-1%"

rem make hash from a path
if not exist "%SCRIPT_TEMP_CURRENT_DIR%\tmp\" mkdir "%SCRIPT_TEMP_CURRENT_DIR%\tmp"

rem copy path to a file
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%REPOROOT%") do (echo.%%i) > "%SCRIPT_TEMP_CURRENT_DIR%\tmp\reporoot_path.var"

rem generate md5 hash from a file content
call "%%CONTOOLS_ROOT%%/hash/gen_file_hash_cvs.bat" -c md5 -b -s "%%SCRIPT_TEMP_CURRENT_DIR%%\tmp\reporoot_path.var"

set "REPOROOT_DECORATED="
for /F "eol=	 tokens=2 delims=," %%i in ("%RETURN_VALUE%") do set "REPOROOT_DECORATED=%%i"

set "REPOROOT_TASK_INDEX_DIR=%SCRIPT_TEMP_CURRENT_DIR%\reporoots_index\%REPOROOT_DECORATED%"
set "REPOROOT_TASK_INDEX_FILE=%REPOROOT_TASK_INDEX_DIR%\index.var"
if not exist "%REPOROOT_TASK_INDEX_DIR%\" (
  mkdir "%REPOROOT_TASK_INDEX_DIR%"
  rem create index file
  set REPOROOT_INDEX=%REPOROOT_NEXT_INDEX%
  set /A REPOROOT_NEXT_INDEX+=1
  (call echo.%%REPOROOT_INDEX%%) > "%REPOROOT_TASK_INDEX_FILE%"
) else set /P REPOROOT_INDEX=< "%REPOROOT_TASK_INDEX_FILE%"

set REPOROOT_INDEX_DECORATED=%REPOROOT_INDEX%
for /L %%i in (1,1,%REPOROOT_LAST_INDEX_STR_LEN%) do (
  call "%%CONTOOLS_ROOT%%/std/if_.bat" "%%REPOROOT_INDEX_DECORATED:~%REPOROOT_LAST_INDEX_STR_LEN_INDEX%,1%%" == "" && call set "REPOROOT_INDEX_DECORATED=0%%REPOROOT_INDEX_DECORATED%%"
)

set "REPOROOT_TASK_DIR_DECORATED=%REPOROOT_INDEX_DECORATED%=%REPOROOT_DECORATED%"
set "REPOROOT_TASK_DIR=%SCRIPT_TEMP_CURRENT_DIR%\reporoots\%REPOROOT_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTER_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTER_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_NOT_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "WORKINGSET_PATH_INFO_TEXT_TMP=%REPOROOT_TASK_DIR%\$info.txt"
set "WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP=%REPOROOT_TASK_DIR%\externals_db"
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP=%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\{{REF}}.lst"
set "WORKINGSET_PATH_EXTERNALS_PATHS_TMP=%REPOROOT_TASK_DIR%\external_paths.lst"

if not exist "%REPOROOT_TASK_DIR%\" (
  mkdir "%REPOROOT_TASK_DIR%"
  rem create empty files
  type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"
)

rem Save to pathfile associated with repository root
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%\") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

if %FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS% NEQ 0 goto IGNORE_OUTTER_SUPPRESS_DUPLICATE_CHANGE

rem extract the directory WC root through the info file if WCDIR_PATH is not WC root
set "WCROOT_PATH=%WCDIR_PATH%"
if exist "%WCDIR_PATH%\.svn\" goto IGNORE_OUTTER_WCROOT_FROM_WCDIR

svn info "%WCDIR_PATH%" --non-interactive > "%WORKINGSET_PATH_INFO_TEXT_TMP%" || (
  echo.%?~nx0%: error: not versioned directory: "%WCDIR_PATH%".
  exit /b 255
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%WORKINGSET_PATH_INFO_TEXT_TMP%%" "Working Copy Root Path" || (
  echo.%?~nx0%: error: "Working Copy Root Path" property is not found in info file from WC directory: "%WCDIR_PATH%".
  exit /b 254
) >&2

set "WCROOT_PATH=%RETURN_VALUE%"

:IGNORE_OUTTER_WCROOT_FROM_WCDIR

rem append to the workingset externals from the WC root database ONLY
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP=%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP%"

rem make hash from a path
if not exist "%SCRIPT_TEMP_CURRENT_DIR%\tmp\" mkdir "%SCRIPT_TEMP_CURRENT_DIR%\tmp"

rem copy path to a file
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) > "%SCRIPT_TEMP_CURRENT_DIR%\tmp\wcdir_path.var"

rem generate md5 hash from a file content
call "%%CONTOOLS_ROOT%%/hash/gen_file_hash_cvs.bat" -c md5 -b -s "%%SCRIPT_TEMP_CURRENT_DIR%%\tmp\wcdir_path.var"

set "WCDIR_PATH_DECORATED="
for /F "eol=	 tokens=2 delims=," %%i in ("%RETURN_VALUE%") do set "WCDIR_PATH_DECORATED=%%i"

call set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP=%%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP:{{REF}}=%WCDIR_PATH_DECORATED%%%"

if not exist "%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\" mkdir "%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%"
call "%%SVNCMD_TOOLS_ROOT%%/svn_externals_list.bat" -R -l -offline -wcroot "%%WCROOT_PATH%%" "%%WCDIR_PATH%%" > "%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP%"

for /F "usebackq eol=	 tokens=* delims=" %%i in ("%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP%") do (
  set "WORKINGSET_EXTERNAL_PATH=%%i"
  call :PROCESS_OUTTER_WORKINGSET_PATH_EXTERNALS_LIST
)

goto IGNORE_OUTTER_SUPPRESS_DUPLICATE_CHANGE

:PROCESS_OUTTER_WORKINGSET_PATH_EXTERNALS_LIST
rem 1. Make URL absolute
rem 2. Convert forward/backward slashes (special form of the echo command to ignore special characters in the echo value).
set "WORKINGSET_EXTERNAL_PATH=%WCDIR_PATH:\=/%/%WORKINGSET_EXTERNAL_PATH%"
for /F "eol=	 tokens=* delims=" %%i in ("%WORKINGSET_EXTERNAL_PATH:/=\\%") do (
  (echo.%%i) >> "%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%"
)

exit /b 0

:IGNORE_OUTTER_SUPPRESS_DUPLICATE_CHANGE

exit /b

:OUTTER_WINDOW_PER_REPOROOT_PREPROCESS_END
if not exist "%SCRIPT_TEMP_CURRENT_DIR%\reporoots" goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_END

rem count only success calls
set CALL_INDEX=0

for /F "usebackq eol=	 tokens=1,2 delims==" %%i in (`@pushd "%SCRIPT_TEMP_CURRENT_DIR%\reporoots" ^&^& ^( dir /B /A:D "*=*" 2^>nul ^& popd ^)`) do (
  set REPOROOT_INDEX_DECORATED=%%i
  set REPOROOT_DIR_DECORATED=%%j
  call :PROCESS_OUTTER_WINDOW_PER_REPOROOT || goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_END
)
goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_END

:PROCESS_OUTTER_WINDOW_PER_REPOROOT
rem run only first TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS
if %CALL_INDEX% GEQ %TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS% exit /b 1

set REPOROOT_INDEX_DECORATED_DECORATED=0%REPOROOT_INDEX_DECORATED%
set REPOROOT_INDEX=%REPOROOT_INDEX_DECORATED_DECORATED:*0=%
set "REPOROOT_TASK_DIR_DECORATED=%REPOROOT_INDEX_DECORATED%=%REPOROOT_DIR_DECORATED%"
set "REPOROOT_TASK_DIR=%SCRIPT_TEMP_CURRENT_DIR%\reporoots\%REPOROOT_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTER_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTER_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_NOT_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\%TORTOISEPROC_PATHFILE_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "WORKINGSET_PATH_INFO_TEXT_TMP=%REPOROOT_TASK_DIR%\$info.txt"
set "WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP=%REPOROOT_TASK_DIR%\externals_db"
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP=%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\{{REF}}.lst"
set "WORKINGSET_PATH_EXTERNALS_PATHS_TMP=%REPOROOT_TASK_DIR%\external_paths.lst"

set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%REPOROOT_TASK_DIR%\pathfile-ansi-cr.lst"

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%REPOROOT_TASK_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%.%REPOROOT_TASK_DIR_DECORATED%.lst"
)

if %FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS% EQU 0 ( call :FILTER_PATHFILE_BY_NOT_ORPHAN_EXTERNALS || goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_EXIT )
if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% NEQ 0 ( call :FILTER_PATHFILE_BY_VERSIONED_CHANGES || goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_EXIT )

rem convert dos line returns to unix
call "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%" > "%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%" || goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_EXIT
rem convert to UCS-16BE w/o bom
call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2LE "%%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%" || goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_EXIT
rem execute path file
if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%" /deletepathfile
)

:OUTTER_WINDOW_PER_REPOROOT_PROCESS_EXIT
set /A CALL_INDEX+=1

exit /b 0

:OUTTER_WINDOW_PER_REPOROOT_PROCESS_END
:IGNORE_OUTTER_WINDOW_PER_REPOROOT_PROCESS
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

rem if %FLAG_WAIT_EXIT% EQU 0 (
rem   rem delete the external file in case if left behind
rem   del /F /Q /A:-D "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%"
rem )

exit /b %LASTERROR%

:MAIN
rem wait TrotoiseProc.exe to exit
set FLAG_WAIT_EXIT=0
rem single window for all changes
set FLAG_ALL_IN_ONE=0
rem window per WC directory (directory in the command line argument)
set FLAG_WINDOW_PER_WCDIR=0
rem window per WC root (WC root directories found by searching from directories in the command line arguments,
rem including directories from command line arguments which might be not WC root directories)
set FLAG_WINDOW_PER_WCROOT=0
rem window per repository root (WC root directories found by searching from directories in the command line
rem arguments and groupped by unique repository roots). Won't include unversioned WC directories from the command line
rem in the search logic, because unversioned directories does not have repository root (currently in the TODO list).
set FLAG_WINDOW_PER_REPOROOT=0
rem Force use workingset paths with out versioned changes.
rem Has meaning only for /command:commit and if -all-in-one flag is not set.
rem Has additional meaning when WC directories might contain unversioned items to show them in changesets along with items to be committed
rem (useful if you may miss to add something to commit).
set FLAG_FORCE_USE_WORKINGSET_PATHS_WITHOUT_VERSIONED_CHANGES=0
rem Force use not orphan external paths.
rem Has meaning only for all-in-one/window-per-wcdir/window-per-reporoot only modes.
rem By default externals registered in the wc.db EXTERNALS table will be removed from the pathsfile.
rem The wc.db EXTERNALS table used as workaround for the `svn status` bug: https://svn.haxx.se/users/archive-2017-06/0057.shtml ("svn status merges intersected external records into single row")
set FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS=0

rem internal flags
set FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES=0
rem will be used only when the FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES is not set!
set FLAG_INTERNAL_USE_UNVERSIONED_WORKINGSET_PATHS=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
    shift
  ) else if "%FLAG%" == "-all-in-one" (
    set FLAG_ALL_IN_ONE=1
    set FLAG_WINDOW_PER_WCDIR=0
    set FLAG_WINDOW_PER_WCROOT=0
    set FLAG_WINDOW_PER_REPOROOT=0
    shift
  ) else if "%FLAG%" == "-window-per-wcdir" (
    set FLAG_ALL_IN_ONE=0
    set FLAG_WINDOW_PER_WCDIR=1
    set FLAG_WINDOW_PER_WCROOT=0
    set FLAG_WINDOW_PER_REPOROOT=0
    shift
  ) else if "%FLAG%" == "-window-per-wcroot" (
    set FLAG_ALL_IN_ONE=0
    set FLAG_WINDOW_PER_WCDIR=0
    set FLAG_WINDOW_PER_WCROOT=1
    set FLAG_WINDOW_PER_REPOROOT=0
    shift
  ) else if "%FLAG%" == "-window-per-reporoot" (
    set FLAG_ALL_IN_ONE=0
    set FLAG_WINDOW_PER_WCDIR=0
    set FLAG_WINDOW_PER_WCROOT=0
    set FLAG_WINDOW_PER_REPOROOT=1
    shift
  ) else if "%FLAG%" == "-force-use-workingset-paths-wo-versioned-changes" (
    set FLAG_FORCE_USE_WORKINGSET_PATHS_WITHOUT_VERSIONED_CHANGES=1
    shift
  ) else if "%FLAG%" == "-force-use-not-orphan-external-paths" (
    set FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  )

  rem read until no flags
  goto FLAGS_LOOP
)

set "COMMAND=%~1"
set "PWD=%~2"
shift
shift

set COMMAND_REPOSTATUS=0
set COMMAND_COMMIT=0
if "%COMMAND%" == "/command:repostatus" set COMMAND_REPOSTATUS=1
if "%COMMAND%" == "/command:commit" set COMMAND_COMMIT=1

if %FLAG_ALL_IN_ONE%%FLAG_WINDOW_PER_WCDIR%%FLAG_WINDOW_PER_WCROOT%%FLAG_WINDOW_PER_REPOROOT% EQU 0 (
  if %COMMAND_REPOSTATUS% NEQ 0 (
    rem all-in-one by default in case of repostatus command
    set FLAG_ALL_IN_ONE=1
  ) else if %COMMAND_COMMIT% NEQ 0 (
    rem window-per-reporoot by default in case of commit command
    set FLAG_WINDOW_PER_REPOROOT=1
  ) else (
    rem window-per-wcdir by default in case of other commands
    set FLAG_WINDOW_PER_WCDIR=1
  )
)

rem exception cases
if %COMMAND_COMMIT% NEQ 0 (
  if %FLAG_ALL_IN_ONE% EQU 0 (
    if %FLAG_FORCE_USE_WORKINGSET_PATHS_WITHOUT_VERSIONED_CHANGES% EQU 0 (
      set FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES=1
    )
  )
)

if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% EQU 0 ^
if %FLAG_WINDOW_PER_REPOROOT% EQU 0 (
  set FLAG_INTERNAL_USE_UNVERSIONED_WORKINGSET_PATHS=1
)

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

rem special initialized
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTER_ANSI_CRLF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%TORTOISEPROC_PATHFILE_FILTER_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%TORTOISEPROC_PATHFILE_NOT_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\%TORTOISEPROC_PATHFILE_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "WORKINGSET_PATH_INFO_TEXT_TMP=%SCRIPT_TEMP_CURRENT_DIR%\$info.txt"
set "WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP=%SCRIPT_TEMP_CURRENT_DIR%\externals_db"
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP=%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\{{REF}}.lst"
set "WORKINGSET_PATH_EXTERNALS_PATHS_TMP=%SCRIPT_TEMP_CURRENT_DIR%\external_paths.lst"

rem create empty files
if %FLAG_WINDOW_PER_WCDIR% EQU 0 type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

if %FLAG_ALL_IN_ONE% EQU 0 ^
if %FLAG_WINDOW_PER_REPOROOT% EQU 0 goto IGNORE_OUTTER_INIT

set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%SCRIPT_TEMP_CURRENT_DIR%\pathfile-ansi-cr.lst"
set "TORTOISEPROC_PATHFILE_WORKINGSET_TMP=%SCRIPT_TEMP_CURRENT_DIR%\pathfile-workingset.lst"
set "TASKS_NUM_VARFILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\num_tasks.var"

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%.lst"
)

rem create empty files
if %FLAG_WINDOW_PER_REPOROOT% NEQ 0 ( type nul > "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%" )

:IGNORE_OUTTER_INIT

if not defined PWD goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD
rem count only success calls
set CALL_INDEX=0
rem count unique repository roots
set REPOROOT_INDEX=-1
rem task per subdir
set OUTTER_TASK_INDEX=0

rem run COMMAND over selected files/directories in the PWD directory
:LOOKUP_DIR_LOOP
rem run only first TORTOISEPROC_MAX_CALLS
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 0

set "FILEPATH=%~1"
if not defined FILEPATH exit /b 0

rem ignore files selection
if not exist "%FILEPATH%\" goto NEXT_LOOKUP_DIR

rem reduce relative path to avoid . and .. characters
call "%%CONTOOLS_ROOT%%/reduce_relative_path.bat" "%%FILEPATH%%"
set "FILEPATH=%RETURN_VALUE%"

rem should not be empty
if not defined FILEPATH set FILEPATH=.
set "FILEPATH=%FILEPATH:/=\%"

set "FILEPATH_DECORATED=\%FILEPATH%\"

rem cut off suffix with .svn subdirectory
if "%FILEPATH_DECORATED:\.svn\=%" == "%FILEPATH_DECORATED%" goto IGNORE_FILEPATH_WCROOT_PATH_CUTOFF

set "FILEPATH_WCROOT_SUFFIX=%FILEPATH_DECORATED:*.svn\=%"

set "FILEPATH_WCROOT_PREFIX=%FILEPATH_DECORATED%"
if not defined FILEPATH_WCROOT_SUFFIX goto CUTOFF_WCROOT_PREFIX

call set "FILEPATH_WCROOT_PREFIX=%%FILEPATH_DECORATED:\%FILEPATH_WCROOT_SUFFIX%=%%"

:CUTOFF_WCROOT_PREFIX
rem remove bounds character and extract diretory path
if "%FILEPATH_DECORATED:~-1%" == "\" set "FILEPATH_DECORATED=%FILEPATH_DECORATED:~0,-1%"
call "%%CONTOOLS_ROOT%%/split_pathstr.bat" "%%FILEPATH_DECORATED:~1%%" \ "" FILEPATH

rem should not be empty
if not defined FILEPATH set FILEPATH=.

:IGNORE_FILEPATH_WCROOT_PATH_CUTOFF

rem filename must be always absolute
call :ABS_FILEPATH "%%FILEPATH%%"
goto ABS_FILEPATH_END

:ABS_FILEPATH
set "FILEPATH=%~dpf1"
exit /b
:ABS_FILEPATH_END

rem ==================== window-per-wcdir init ====================

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCDIR_INIT

set INNER_TASK_INDEX=%OUTTER_TASK_INDEX%

rem make hash from a path
if not exist "%SCRIPT_TEMP_CURRENT_DIR%\tmp\" mkdir "%SCRIPT_TEMP_CURRENT_DIR%\tmp"

rem copy path to a file
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%FILEPATH%") do (echo.%%i) > "%SCRIPT_TEMP_CURRENT_DIR%\tmp\wcdir_path.var"

rem generate md5 hash from a file content
call "%%CONTOOLS_ROOT%%/hash/gen_file_hash_cvs.bat" -c md5 -b -s "%%SCRIPT_TEMP_CURRENT_DIR%%\tmp\wcdir_path.var"

set "FILEPATH_DECORATED="
for /F "eol=	 tokens=2 delims=," %%i in ("%RETURN_VALUE%") do set "FILEPATH_DECORATED=%%i"

if "%INNER_TASK_INDEX:~1,1%" == "" set INNER_TASK_INDEX=0%INNER_TASK_INDEX%

set "FILEPATH_TASK_DIR_DECORATED=%INNER_TASK_INDEX%=%FILEPATH_DECORATED%"
set "FILEPATH_TASK_DIR=%SCRIPT_TEMP_CURRENT_DIR%\wcdirs\%FILEPATH_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\%TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_FILTER_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\%TORTOISEPROC_PATHFILE_FILTER_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\%TORTOISEPROC_PATHFILE_NOT_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\%TORTOISEPROC_PATHFILE_ORPHAN_EXTERNALS_NAME_ANSI_CRLF_TMP%"
set "WORKINGSET_PATH_INFO_TEXT_TMP=%FILEPATH_TASK_DIR%\$info.txt"
set "WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP=%FILEPATH_TASK_DIR%\externals_db"
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP=%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\{{REF}}.lst"
set "WORKINGSET_PATH_EXTERNALS_PATHS_TMP=%FILEPATH_TASK_DIR%\external_paths.lst"

set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%FILEPATH_TASK_DIR%\pathfile-ansi-cr.lst"

rem create temporary files to store local context output
if exist "%FILEPATH_TASK_DIR%\" (
  echo.%?~nx0%: error: temporary generated directory FILEPATH_TASK_DIR is already exist: "%FILEPATH_TASK_DIR%"
  exit /b 2
) >&2

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%FILEPATH_TASK_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%.lst"
)

mkdir "%FILEPATH_TASK_DIR%"

rem recreate empty files
type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

:IGNORE_INNER_WINDOW_PER_WCDIR_INIT

rem add directory as a fake WC root path if it is not a WC root path to process
rem it's content in case if real WC root directory is above of the directory in the directories tree.
if not exist "%FILEPATH%\.svn\" (
  set "WCDIR_PATH=%FILEPATH%\.svn"
  call :PROCESS_WCDIR_PATH || exit /b 0
)

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /S /B /A:D "%FILEPATH%\*.svn" 2^>nul`) do (
  set WCDIR_PATH=%%i
  call :PROCESS_WCDIR_PATH || exit /b 0
)

if %FLAG_WINDOW_PER_WCROOT% EQU 0 set /A CALL_INDEX+=1

rem ==================== window-per-wcdir process ====================

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCDIR_PROCESS

if %FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS% EQU 0 ( call :FILTER_PATHFILE_BY_NOT_ORPHAN_EXTERNALS || goto NEXT_LOOKUP_DIR )
if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% NEQ 0 ( call :FILTER_PATHFILE_BY_VERSIONED_CHANGES || goto NEXT_LOOKUP_DIR )

rem convert dos line returns to unix
call "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%" > "%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%" || goto NEXT_LOOKUP_DIR
rem convert to UCS-16BE w/o bom
call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2LE "%%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%" || goto NEXT_LOOKUP_DIR
rem execute path file
if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%" /deletepathfile
)

:IGNORE_INNER_WINDOW_PER_WCDIR_PROCESS

:NEXT_LOOKUP_DIR
set /A OUTTER_TASK_INDEX+=1

shift

goto LOOKUP_DIR_LOOP

:CMD
echo.^>%*
(%*)
exit /b

rem ==================== process for all ====================

rem can process versioned and unversioned directories together
:PROCESS_WCDIR_PATH
rem run only first TORTOISEPROC_MAX_CALLS
if %FLAG_WINDOW_PER_WCROOT% NEQ 0 ^
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 1

call :GET_WCDIR_PARENT "%%WCDIR_PATH%%"
set "WCDIR_PATH=%WCDIR_PARENT_PATH%"

rem ignore check in case of unversioned paths
if %FLAG_INTERNAL_USE_UNVERSIONED_WORKINGSET_PATHS% NEQ 0 goto IGNORE_CHANGES_CHECK

rem test path on version control presence and get file path svn info
svn info "%WCDIR_PATH%" > "%WORKINGSET_PATH_INFO_TEXT_TMP%" 2>nul
rem ignore on error
if %ERRORLEVEL% NEQ 0 exit /b 0

rem filter WC directory by changes existance just before call to TortoiseProc.exe and after orphan externals filter!
if %FLAG_WINDOW_PER_WCROOT% EQU 0 goto IGNORE_CHANGES_CHECK

if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% EQU 0 goto IGNORE_CHANGES_CHECK

call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -stat-exclude-? "%%WCDIR_PATH%%" >nul 2>nul
rem call anyway if error happened
if %ERRORLEVEL% EQU 0 ^
if %RETURN_VALUE% EQU 0 exit /b 0

:IGNORE_CHANGES_CHECK

rem Write to path file even if file is not required (for debugging purposes).
rem set "WCDIR_PATH=%WCDIR_PATH:\=/%"
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%\") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

rem ==================== window-per-wcroot process ====================

if %FLAG_WINDOW_PER_WCROOT% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCROOT_PROCESS

rem execute path file
if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /path:"%%WCDIR_PATH%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /path:"%%WCDIR_PATH%%"
)

set /A CALL_INDEX+=1

exit /b 0

:IGNORE_INNER_WINDOW_PER_WCROOT_PROCESS

if %FLAG_WINDOW_PER_REPOROOT% NEQ 0 goto IGNORE_INNER_SUPPRESS_DUPLICATE_CHANGE
if %FLAG_FORCE_USE_NOT_ORPHAN_EXTERNAL_PATHS% NEQ 0 goto IGNORE_INNER_SUPPRESS_DUPLICATE_CHANGE

rem extract the directory WC root through the info file if WCDIR_PATH is not WC root
set "WCROOT_PATH=%WCDIR_PATH%"
if exist "%WCDIR_PATH%\.svn\" goto IGNORE_INNER_WCROOT_FROM_WCDIR

svn info "%WCDIR_PATH%" --non-interactive > "%WORKINGSET_PATH_INFO_TEXT_TMP%"

if %ERRORLEVEL% NEQ 0 (
  rem leave unversioned paths as is
  if %FLAG_INTERNAL_USE_UNVERSIONED_WORKINGSET_PATHS% NEQ 0 exit /b 0
  echo.%?~nx0%: error: not versioned directory: "%WCDIR_PATH%".
  exit /b 245
) >&2

call "%%SVNCMD_TOOLS_ROOT%%/extract_info_param.bat" "%%WORKINGSET_PATH_INFO_TEXT_TMP%%" "Working Copy Root Path" || (
  echo.%?~nx0%: error: "Working Copy Root Path" property is not found in info file from WC directory: "%WCDIR_PATH%".
  exit /b 244
) >&2

set "WCROOT_PATH=%RETURN_VALUE%"

:IGNORE_INNER_WCROOT_FROM_WCDIR

rem append to the workingset externals from the WC root database ONLY
set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP=%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMPL_TMP%"

rem make hash from a path
if not exist "%SCRIPT_TEMP_CURRENT_DIR%\tmp\" mkdir "%SCRIPT_TEMP_CURRENT_DIR%\tmp"

rem copy path to a file
rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) > "%SCRIPT_TEMP_CURRENT_DIR%\tmp\wcdir_path.var"

rem generate md5 hash from a file content
call "%%CONTOOLS_ROOT%%/hash/gen_file_hash_cvs.bat" -c md5 -b -s "%%SCRIPT_TEMP_CURRENT_DIR%%\tmp\wcdir_path.var"

set "WCDIR_PATH_DECORATED="
for /F "eol=	 tokens=2 delims=," %%i in ("%RETURN_VALUE%") do set "WCDIR_PATH_DECORATED=%%i"

call set "WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP=%%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP:{{REF}}=%WCDIR_PATH_DECORATED%%%"

if not exist "%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%\" mkdir "%WORKINGSET_PATH_DB_EXTERNALS_DIR_TMP%"
call "%%SVNCMD_TOOLS_ROOT%%/svn_externals_list.bat" -R -l -offline -wcroot "%%WCROOT_PATH%%" "%%WCDIR_PATH%%" > "%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP%"

for /F "usebackq eol=	 tokens=* delims=" %%i in ("%WORKINGSET_PATH_DB_EXTERNALS_LIST_TMP%") do (
  set "WORKINGSET_EXTERNAL_PATH=%%i"
  call :PROCESS_INNER_WORKINGSET_PATH_EXTERNALS_LIST
)

goto IGNORE_INNER_SUPPRESS_DUPLICATE_CHANGE

:PROCESS_INNER_WORKINGSET_PATH_EXTERNALS_LIST
rem 1. Make URL absolute
rem 2. Convert forward/backward slashes (special form of the echo command to ignore special characters in the echo value).
set "WORKINGSET_EXTERNAL_PATH=%WCDIR_PATH:\=/%/%WORKINGSET_EXTERNAL_PATH%"
for /F "eol=	 tokens=* delims=" %%i in ("%WORKINGSET_EXTERNAL_PATH:/=\\%") do (
  (echo.%%i) >> "%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%"
)

exit /b 0

:IGNORE_INNER_SUPPRESS_DUPLICATE_CHANGE

if %FLAG_WINDOW_PER_REPOROOT% EQU 0 exit /b 0

rem read repository Root
call "%%CONTOOLS_ROOT%%/scm/svn/extract_info_param.bat" "%%WORKINGSET_PATH_INFO_TEXT_TMP%%" "Repository Root"
rem ignore on error
if %ERRORLEVEL% NEQ 0 exit /b 0

set "REPOROOT=%RETURN_VALUE%"

rem count unique repository roots
findstr.exe /L "|%REPOROOT%|" "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set /A REPOROOT_INDEX+=1

for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%\") do ^
for /F "eol=	 tokens=* delims=" %%j in ("%REPOROOT%") do (echo.%%i^|%%j^|) >> "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%"

exit /b 0

:GET_WCDIR_PARENT
set "WCDIR_PARENT_PATH=%~dp1"
set "WCDIR_PARENT_PATH=%WCDIR_PARENT_PATH:~0,-1%"
exit /b

:FILTER_PATHFILE_BY_VERSIONED_CHANGES
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 0

rem create empty files
type nul > "%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%"

for /F "usebackq eol=	 tokens=* delims=" %%i in ("%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%") do (
  set WCDIR_PATH=%%i
  call :PROCESS_WCDIR_VERSIONED_CHANGES
)
goto PROCESS_WCDIR_VERSIONED_CHANGES_END

:PROCESS_WCDIR_VERSIONED_CHANGES
rem remove orphan externals only if it has no versioned changes recursively
if not exist "%TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%" goto PROCESS_WCDIR_VERSIONED_CHANGES_NOT_ORPHAN

findstr.exe /I /X /C:"%WCDIR_PATH:\=\\%" "%TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%" > nul
if %ERRORLEVEL% NEQ 0 goto PROCESS_WCDIR_VERSIONED_CHANGES_NOT_ORPHAN

call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -R -stat-exclude-? "%%WCDIR_PATH%%" >nul 2>nul
rem call anyway if error happened
if %ERRORLEVEL% EQU 0 ^
if %RETURN_VALUE% EQU 0 exit /b 0

rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%"
exit /b 0

:PROCESS_WCDIR_VERSIONED_CHANGES_NOT_ORPHAN
call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -stat-exclude-? "%%WCDIR_PATH%%" >nul 2>nul
rem call anyway if error happened
if %ERRORLEVEL% EQU 0 ^
if %RETURN_VALUE% EQU 0 exit /b 0

rem (special form of the echo command to ignore special characters in the echo value).
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%"
exit /b 0

:PROCESS_WCDIR_VERSIONED_CHANGES_END
rem ignore empty pathfiles
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 1

rem set filtered as input
( rename "%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%" "%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%.tmp" && ^
rename "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%" "%TORTOISEPROC_PATHFILE_FILTERED_NAME_ANSI_CRLF_TMP%" && ^
rename "%TORTOISEPROC_PATHFILE_FILTERED_ANSI_CRLF_TMP%.tmp" "%TORTOISEPROC_PATHFILE_NAME_ANSI_CRLF_TMP%" ) >nul

exit /b 0

:FILTER_PATHFILE_BY_NOT_ORPHAN_EXTERNALS
rem don't use empty pathfiles
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 1

rem apply the pathlist if empty externals list
if not exist "%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%" exit /b 0
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 0

findstr.exe /I /X /G:"%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%" "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%" > "%TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%"

rem apply the pathlist if the pathlist consist only of orthan externals not connected to each other
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_NOT_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 0

rem get list of orthan externals
findstr.exe /I /V /X /G:"%WORKINGSET_PATH_EXTERNALS_PATHS_TMP%" "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%" > "%TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%"

rem apply the pathlist if the pathlist consist only of not orthan externals not connected to each other.
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 0

type "%TORTOISEPROC_PATHFILE_ORTHAN_EXTERNALS_ANSI_CRLF_TMP%" > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

exit /b 0