@echo off

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

rem builtin defaults
if "%TORTOISEPROC_MAX_CALLS%" == "" set TORTOISEPROC_MAX_CALLS=10
if "%TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS%" == "" set TORTOISEPROC_WINDOW_PER_REPOROOT_MAX_CALLS=20

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

if %FLAG_ALL_IN_ONE% EQU 0 goto IGNORE_OUTTER_ALL_IN_ONE_PROCESS

rem ignore empty lists
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 goto IGNORE_OUTTER_ALL_IN_ONE_PROCESS

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

:IGNORE_OUTTER_ALL_IN_ONE_PROCESS

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
rem for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH% %REPOROOT%") do (echo.%%i)
set "REPOROOT_DECORATED=%REPOROOT:\=--%"
set "REPOROOT_DECORATED=%REPOROOT_DECORATED:/=--%"
set "REPOROOT_DECORATED=%REPOROOT_DECORATED::=--%"

set "REPOROOT_TASK_INDEX_DIR=%TEMP_FILE_OUTTER_DIR%\reporoots_index\%REPOROOT_DECORATED%"
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
set "REPOROOT_TASK_DIR=%TEMP_FILE_OUTTER_DIR%\reporoots\%REPOROOT_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\pathfile-ansi-crlf.lst"

if not exist "%REPOROOT_TASK_DIR%\" (
  mkdir "%REPOROOT_TASK_DIR%"
  rem create empty files
  type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"
)

rem save to pathfile associated with repository root
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

exit /b

:OUTTER_WINDOW_PER_REPOROOT_PREPROCESS_END
if not exist "%TEMP_FILE_OUTTER_DIR%\reporoots" goto OUTTER_WINDOW_PER_REPOROOT_PROCESS_END

rem count only success calls
set CALL_INDEX=0

for /F "usebackq eol=	 tokens=1,2 delims==" %%i in (`@pushd "%TEMP_FILE_OUTTER_DIR%\reporoots" ^&^& ^( dir /B /A:D "*=*" 2^>nul ^& popd ^)`) do (
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
set "REPOROOT_TASK_DIR=%TEMP_FILE_OUTTER_DIR%\reporoots\%REPOROOT_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%REPOROOT_TASK_DIR%\pathfile-ansi-crlf.lst"
set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%REPOROOT_TASK_DIR%\pathfile-ansi-cr.lst"

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%REPOROOT_TASK_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%TEMP_DATE%.%TEMP_TIME%.%REPOROOT_TASK_DIR_DECORATED%.lst"
)

rem ignore empty lists
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 exit /b 0

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
rmdir /S /Q "%TEMP_FILE_OUTTER_DIR%"

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
rem window per WC root (WC root directories found by searching from directories in the command line arguments)
set FLAG_WINDOW_PER_WCROOT=0
rem window per repository root (WC root directories found by searching from directories in the command line arguments and groupped by unique repository roots)
set FLAG_WINDOW_PER_REPOROOT=0
rem Force use workingset paths with out versioned changes.
rem Has meaning only for /command:commit and if -all-in-one flag is not set.
set FLAG_FORCE_USE_WORKINGSET_PATHS_WITHOUT_VERSIONED_CHANGES=0

rem internal flags
set FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
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

if %FLAG_ALL_IN_ONE%%FLAG_WINDOW_PER_WCDIR%%FLAG_WINDOW_PER_REPOROOT% EQU 0 (
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

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "TEMP_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "TEMP_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "TEMP_FILE_OUTTER_DIR=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%"

rem special initialized
if %FLAG_WINDOW_PER_WCDIR% EQU 0 set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ansi-crlf.lst"
set "WORKINGSET_PATH_INFO_TMP=%TEMP_FILE_OUTTER_DIR%\$info.txt"

rem create temporary files to store local context output
if exist "%TEMP_FILE_OUTTER_DIR%\" (
  echo.%?~nx0%: error: temporary generated directory TEMP_FILE_OUTTER_DIR is already exist: "%TEMP_FILE_OUTTER_DIR%"
  exit /b 1
) >&2

mkdir "%TEMP_FILE_OUTTER_DIR%"

rem create empty files
if %FLAG_WINDOW_PER_WCDIR% EQU 0 type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

if %FLAG_ALL_IN_ONE% EQU 0 ^
if %FLAG_WINDOW_PER_REPOROOT% EQU 0 goto IGNORE_OUTTER_INIT

set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ansi-cr.lst"
set "TORTOISEPROC_PATHFILE_WORKINGSET_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-workingset.lst"
set "TASKS_NUM_VARFILE_TMP=%TEMP_FILE_OUTTER_DIR%\num_tasks.var"

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%TEMP_DATE%.%TEMP_TIME%.lst"
)

rem create empty files
if %FLAG_WINDOW_PER_REPOROOT% NEQ 0 ( type nul > "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%" )

:IGNORE_OUTTER_INIT

if "%PWD%" == "" goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD
rem count only success calls
set CALL_INDEX=0
rem count unique repository roots
set REPOROOT_INDEX=-1
rem task per subdir
set OUTTER_TASK_INDEX=0

rem run COMMAND over selected files/directories in the PWD directory
:CURDIR_LOOP
rem run only first TORTOISEPROC_MAX_CALLS
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 0

set "FILEPATH=%~1"
if "%FILEPATH%" == "" exit /b 0

rem ignore files selection
if not exist "%FILEPATH%\" goto NEXT_CURDIR

rem reduce relative path to avoid . and .. characters
call "%%CONTOOLS_ROOT%%/reduce_relative_path.bat" "%%FILEPATH%%"
set "FILEPATH=%RETURN_VALUE%"

set "FILEPATH_DECORATED=\%FILEPATH%\"

rem cut off suffix with .svn subdirectory
if "%FILEPATH_DECORATED:\.svn\=%" == "%FILEPATH_DECORATED%" goto IGNORE_FILEPATH_WCROOT_PATH_CUTOFF

set "FILEPATH_WCROOT_SUFFIX=%FILEPATH_DECORATED:*.svn\=%"

set "FILEPATH_WCROOT_PREFIX=%FILEPATH_DECORATED%"
if "%FILEPATH_WCROOT_SUFFIX%" == "" goto CUTOFF_WCROOT_PREFIX

call set "FILEPATH_WCROOT_PREFIX=%%FILEPATH_DECORATED:\%FILEPATH_WCROOT_SUFFIX%=%%"

:CUTOFF_WCROOT_PREFIX
rem remove bounds character and extract diretory path
if "%FILEPATH_DECORATED:~-1%" == "\" set "FILEPATH_DECORATED=%FILEPATH_DECORATED:~0,-1%"
call "%%CONTOOLS_ROOT%%/split_pathstr.bat" "%%FILEPATH_DECORATED:~1%%" \ "" FILEPATH

rem should not be empty
if "%FILEPATH%" == "" set FILEPATH=.

:IGNORE_FILEPATH_WCROOT_PATH_CUTOFF

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCDIR_INIT

set INNER_TASK_INDEX=%OUTTER_TASK_INDEX%

set "FILEPATH_DECORATED=%FILEPATH:\=--%"
set "FILEPATH_DECORATED=%FILEPATH_DECORATED:/=--%"
set "FILEPATH_DECORATED=%FILEPATH_DECORATED::=--%"

if "%INNER_TASK_INDEX:~1,1%" == "" set INNER_TASK_INDEX=0%INNER_TASK_INDEX%

set "FILEPATH_TASK_DIR_DECORATED=%INNER_TASK_INDEX%=%FILEPATH_DECORATED%"
set "FILEPATH_TASK_DIR=%TEMP_FILE_OUTTER_DIR%\wcdirs\%FILEPATH_TASK_DIR_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%FILEPATH_TASK_DIR%\pathfile-ansi-crlf.lst"
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
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.pathfile-ucs-16LE.%TEMP_DATE%.%TEMP_TIME%.lst"
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

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCDIR_PROCESS

rem ignore empty lists
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 goto IGNORE_INNER_WINDOW_PER_WCDIR_PROCESS

rem convert dos line returns to unix
call "%%CONTOOLS_ROOT%%/encoding/dos2unix.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%" > "%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%" || goto NEXT_CURDIR
rem convert to UCS-16BE w/o bom
call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" "" UCS-2LE "%%TORTOISEPROC_PATHFILE_ANSI_LF_TMP%%" > "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%" || goto NEXT_CURDIR
rem execute path file
if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%"
) else (
  call :CMD start /B "" TortoiseProc.exe %%COMMAND%% /pathfile:"%%TORTOISEPROC_PATHFILE_UCS16LE_TMP%%" /deletepathfile
)

:IGNORE_INNER_WINDOW_PER_WCDIR_PROCESS

:NEXT_CURDIR
set /A OUTTER_TASK_INDEX+=1

shift

goto CURDIR_LOOP

:CMD
echo.^>%*
(%*)
exit /b

rem can process versioned and unversioned directories together
:PROCESS_WCDIR_PATH
rem run only first TORTOISEPROC_MAX_CALLS
if %FLAG_WINDOW_PER_WCROOT% NEQ 0 ^
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 1

call :GET_WCDIR_PARENT "%%WCDIR_PATH%%"
set "WCDIR_PATH=%WCDIR_PARENT_PATH%"

rem test path on version control presence and get file path svn info
svn info "%WCDIR_PATH%" > "%WORKINGSET_PATH_INFO_TMP%" 2>nul
rem ignore on error
if %ERRORLEVEL% NEQ 0 exit /b 0

if %FLAG_INTERNAL_USE_ONLY_WORKINGSET_PATHS_WITH_VERSIONED_CHANGES% EQU 0 goto IGNORE_STATUS_REQUEST

call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -stat-exclude-? "%%WCDIR_PATH%%" >nul 2>nul
rem call anyway if error happened
if %ERRORLEVEL% EQU 0 ^
if %RETURN_VALUE% EQU 0 exit /b 0

:IGNORE_STATUS_REQUEST

rem Write to path file (special form of the echo command to ignore special characters in the WCDIR_PATH value),
rem even if file is not required (for debugging purposes).
rem set "WCDIR_PATH=%WCDIR_PATH:\=/%"
for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

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

if %FLAG_WINDOW_PER_REPOROOT% EQU 0 exit /b 0

rem read repository Root
call "%%CONTOOLS_ROOT%%/scm/svn/extract_info_param.bat" "%%WORKINGSET_PATH_INFO_TMP%%" "Repository Root"
rem ignore on error
if %ERRORLEVEL% NEQ 0 exit /b 0

set "REPOROOT=%RETURN_VALUE%"

rem count unique repository roots
type "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%" | findstr.exe /L "|%REPOROOT%|" >nul 2>nul
if %ERRORLEVEL% NEQ 0 set /A REPOROOT_INDEX+=1

for /F "eol=	 tokens=* delims=" %%i in ("%WCDIR_PATH%") do ^
for /F "eol=	 tokens=* delims=" %%j in ("%REPOROOT%") do (echo.%%i^|%%j^|) >> "%TORTOISEPROC_PATHFILE_WORKINGSET_TMP%"

exit /b 0

:GET_ABS_PATH
set "ABS_PATH=%~dpf1"
exit /b

:GET_WCDIR_PARENT
set "WCDIR_PARENT_PATH=%~dp1"
rem remove last back slash in case if not the root directory of a drive
if not "%WCDIR_PARENT_PATH:~-2,1%" == ":" set "WCDIR_PARENT_PATH=%WCDIR_PARENT_PATH:~0,-1%"
exit /b
