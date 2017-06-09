@echo off

setlocal

call "%%~dp0__init__.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

if %FLAG_ALL_IN_ONE% EQU 0 goto IGNORE_OUTTER_PROCESS

rem ignore empty lists
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 goto IGNORE_OUTTER_PROCESS

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

:IGNORE_OUTTER_PROCESS

:EXIT_MAIN
rem cleanup temporary files
rmdir /S /Q "%TEMP_FILE_OUTTER_DIR%"

rem if %FLAG_WAIT_EXIT% EQU 0 (
rem   rem delete the external file in case if left behind
rem   del /F /Q /A:-D "%TORTOISEPROC_PATHFILE_UCS16LE_TMP%"
rem )

exit /b %LASTERROR%

:MAIN
rem builtin defaults
if "%TORTOISEPROC_MAX_CALLS%" == "" set TORTOISEPROC_MAX_CALLS=10

rem script flags
set FLAG_WAIT_EXIT=0
rem single window for all changes
set FLAG_ALL_IN_ONE=0
rem window per WC directory
set FLAG_WINDOW_PER_WCDIR=0

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
    shift
  ) else if "%FLAG%" == "-window-per-wcdir" (
    set FLAG_ALL_IN_ONE=0
    set FLAG_WINDOW_PER_WCDIR=1
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

rem window-per-wcroot by default in case of other commands
if %FLAG_ALL_IN_ONE%%FLAG_WINDOW_PER_WCDIR% EQU 0 (
  if %COMMAND_REPOSTATUS% NEQ 0 (
    rem all-in-one by default in case of repostatus command
    set FLAG_ALL_IN_ONE=1
  ) else if %COMMAND_COMMIT% NEQ 0 (
    rem window-per-wcroot by default in case of commit command
    set FLAG_WINDOW_PER_WCDIR=1
  ) else (
    rem window-per-wcroot by default in case of other commands
    set FLAG_WINDOW_PER_WCDIR=1
  )
)

call "%%CONTOOLS_ROOT%%/get_datetime.bat"
set "TEMP_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
set "TEMP_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

set "TEMP_FILE_OUTTER_DIR=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%"

rem create temporary files to store local context output
if exist "%TEMP_FILE_OUTTER_DIR%\" (
  echo.%?~nx0%: error: temporary generated directory TEMP_FILE_OUTTER_DIR is already exist: "%TEMP_FILE_OUTTER_DIR%"
  exit /b 1
) >&2

mkdir "%TEMP_FILE_OUTTER_DIR%"

if %FLAG_ALL_IN_ONE% EQU 0 goto IGNORE_OUTTER_INIT

set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ansi-crlf.lst"
set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ansi-cr.lst"

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP_FILE_OUTTER_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%.pathfile-ucs-16LE.lst"
)

rem create empty files
type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

:IGNORE_OUTTER_INIT

if "%PWD%" == "" goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD
rem count only success calls
set CALL_INDEX=0
rem task per subdir
set OUTTER_TASK_INDEX=0

rem run COMMAND over selected files/directories in the PWD directory
:CURDIR_LOOP
rem run only first TORTOISEPROC_MAX_CALLS
if %CALL_INDEX% GEQ %TORTOISEPROC_MAX_CALLS% exit /b 0

set "FILENAME=%~1"
if "%FILENAME%" == "" exit /b 0

rem ignore files selection
if not exist "%FILENAME%\" goto NEXT_CURDIR

rem reduce relative path to avoid . and .. characters
call "%%CONTOOLS_ROOT%%/reduce_relative_path.bat" "%%FILENAME%%"
set "FILENAME=%RETURN_VALUE%"

set "FILENAME_DECORATED=\%FILENAME%\"

rem cut off suffix with .svn subdirectory
if "%FILENAME_DECORATED:\.svn\=%" == "%FILENAME_DECORATED%" goto IGNORE_FILENAME_WCROOT_PATH_CUTOFF

set "FILENAME_WCROOT_SUFFIX=%FILENAME_DECORATED:*.svn\=%"

set "FILENAME_WCROOT_PREFIX=%FILENAME_DECORATED%"
if "%FILENAME_WCROOT_SUFFIX%" == "" goto CUTOFF_WCROOT_PREFIX

call set "FILENAME_WCROOT_PREFIX=%%FILENAME_DECORATED:\%FILENAME_WCROOT_SUFFIX%=%%"

:CUTOFF_WCROOT_PREFIX
rem remove bounds character and extract diretory path
if "%FILENAME_DECORATED:~-1%" == "\" set "FILENAME_DECORATED=%FILENAME_DECORATED:~0,-1%"
call "%%CONTOOLS_ROOT%%/split_pathstr.bat" "%%FILENAME_DECORATED:~1%%" \ "" FILENAME

rem should not be empty
if "%FILENAME%" == "" set FILENAME=.

:IGNORE_FILENAME_WCROOT_PATH_CUTOFF

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_INIT

set INNER_TASK_INDEX=%OUTTER_TASK_INDEX%

set "FILENAME_DECORATED=%FILENAME:\=--%"
set "FILENAME_DECORATED=%FILENAME_DECORATED:/=--%"
set "FILENAME_DECORATED=%FILENAME_DECORATED::=--%"
set "FILENAME_DECORATED=%FILENAME_DECORATED:.=%"

if "%INNER_TASK_INDEX:~1,1%" == "" set INNER_TASK_INDEX=0%INNER_TASK_INDEX%

set "TEMP_FILE_INNER_DIR=%TEMP_FILE_OUTTER_DIR%\%INNER_TASK_INDEX%=%FILENAME_DECORATED%"
set "TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP=%TEMP_FILE_INNER_DIR%\pathfile-ansi-crlf.lst"
set "TORTOISEPROC_PATHFILE_ANSI_LF_TMP=%TEMP_FILE_INNER_DIR%\pathfile-ansi-cr.lst"

rem create temporary files to store local context output
if exist "%TEMP_FILE_INNER_DIR%\" (
  echo.%?~nx0%: error: temporary generated directory TEMP_FILE_INNER_DIR is already exist: "%TEMP_FILE_INNER_DIR%"
  exit /b 2
) >&2

if %FLAG_WAIT_EXIT% NEQ 0 (
  rem use temporary file inside script temporary directory
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP_FILE_INNER_DIR%\pathfile-ucs-16LE.lst"
) else (
  rem use temporary file outside script temporary directory, delegate to TortoiseProc.exe it's deletion
  set "TORTOISEPROC_PATHFILE_UCS16LE_TMP=%TEMP%\%?~n0%.%TEMP_DATE%.%TEMP_TIME%.pathfile-ucs-16LE.lst"
)

mkdir "%TEMP_FILE_INNER_DIR%"

rem recreate empty files
type nul > "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

:IGNORE_INNER_INIT

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /S /B /A:D "%FILENAME%\*.svn" 2^>nul`) do (
  set DIR_PATH=%%i
  call :PROCESS_DIR_PATH
)

set /A CALL_INDEX+=1

if %FLAG_WINDOW_PER_WCDIR% EQU 0 goto IGNORE_INNER_PROCESS

rem ignore empty lists
call "%%CONTOOLS_ROOT%%/get_filesize.bat" "%%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%%"
if %ERRORLEVEL% EQU 0 goto IGNORE_INNER_PROCESS

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

:IGNORE_INNER_PROCESS

:NEXT_CURDIR
set /A OUTTER_TASK_INDEX+=1

shift

goto CURDIR_LOOP

:CMD
echo.^>%*
(%*)
exit /b

:PROCESS_DIR_PATH
call :GET_DIR_PARENT "%%DIR_PATH%%"
set "WCROOT_PATH=%DIR_PARENT_PATH%"

if %COMMAND_COMMIT% EQU 0 goto IGNORE_STATUS_REQUEST

call "%%SVNCMD_TOOLS_ROOT%%/svn_has_changes.bat" -stat-exclude-? "%%WCROOT_PATH%%" >nul 2>nul
rem call anyway if error happened
if %ERRORLEVEL% EQU 0 ^
if %RETURN_VALUE% EQU 0 exit /b 0

:IGNORE_STATUS_REQUEST

rem write to path file (special form of the echo command to ignore special characters in the WCROOT_PATH value)
rem set "WCROOT_PATH=%WCROOT_PATH:\=/%"
for /F "tokens=* delims=" %%i in ("%WCROOT_PATH%") do (echo.%%i) >> "%TORTOISEPROC_PATHFILE_ANSI_CRLF_TMP%"

exit /b

:GET_ABS_PATH
set "ABS_PATH=%~dpf1"
exit /b

:GET_DIR_PARENT
set "DIR_PARENT_PATH=%~dp1"
rem remove last back slash in case if not the root directory of a drive
if not "%DIR_PARENT_PATH:~-2,1%" == ":" set "DIR_PARENT_PATH=%DIR_PARENT_PATH:~0,-1%"
exit /b
