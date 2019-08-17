@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem builtin defaults
if not defined NOTEPAD_WINDOW_PER_PROP_CLASS_MAX_CALLS set NOTEPAD_WINDOW_PER_PROP_CLASS_MAX_CALLS=10

rem script flags
set FLAG_PAUSE_ON_EXIT=0
set FLAG_PAUSE_ON_ERROR=0
set FLAG_PAUSE_TIMEOUT_SEC=0
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %FLAG_PAUSE_ON_EXIT% NEQ 0 (
  if %FLAG_PAUSE_TIMEOUT_SEC% NEQ 0 (
    timeout /T %FLAG_PAUSE_TIMEOUT_SEC%
  ) else pause
) else if %LASTERROR% NEQ 0 if %FLAG_PAUSE_ON_ERROR% NEQ 0 (
  if %FLAG_PAUSE_TIMEOUT_SEC% NEQ 0 (
    timeout /T %FLAG_PAUSE_TIMEOUT_SEC%
  ) else pause
)

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_WAIT_EXIT=0
set FLAG_CONVERT_FROM_UTF16=0
rem open an edit window per property class (`svn:ignore`, `svn.externals` and so on)
set FLAG_WINDOW_PER_PROP_CLASS=0
rem open an edit property classes filter window before open an edit properties window(s)
set FLAG_EDIT_FILTER_BY_PROP_CLASS=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set FLAG_PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-pause_on_error" (
    set FLAG_PAUSE_ON_ERROR=1
  ) else if "%FLAG%" == "-pause_timeout_sec" (
    set "FLAG_PAUSE_TIMEOUT_SEC=%~2"
    shift
  ) else if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
  ) else if "%FLAG%" == "-from_utf16" (
    set FLAG_CONVERT_FROM_UTF16=1
  ) else if "%FLAG%" == "-window_per_prop_class" (
    set FLAG_WINDOW_PER_PROP_CLASS=1
  ) else if "%FLAG%" == "-edit_filter_by_prop_class" (
    set FLAG_EDIT_FILTER_BY_PROP_CLASS=1
  ) else (
    set BARE_FLAGS=%BARE_FLAGS% %1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "CWD=%~1"
shift

if not defined CWD goto NOCWD
cd /d "%CWD%" || exit /b 1

rem safe title call
for /F "eol=	 tokens=* delims=" %%i in ("%?~nx0%: %CD%") do title %%i

:NOCWD

if "%~1" == "" exit /b 0

rem properties saved into files to compare with
set "PROPS_INOUT_FILES_DIR=%SCRIPT_TEMP_CURRENT_DIR%\inout"

set "INPUT_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.lst"
set "EDIT_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\edit_file_list.lst"
set "CHANGESET_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\changeset_file_list.lst"

if %FLAG_EDIT_FILTER_BY_PROP_CLASS% NEQ 0 goto USE_USER_PROPS_FILTER
set "PROPS_FILTER_FILE=%CONFIG_DIR%\svn_props_to_edit.lst.in"
goto LOAD_PROPS_FILTER

:USE_USER_PROPS_FILTER
call :CMD copy /B /Y "%%CONFIG_DIR%%\svn_props_to_edit.lst.in" "%%SCRIPT_TEMP_CURRENT_DIR%%\svn_props_to_edit.lst" || exit /b 10
set "PROPS_FILTER_FILE=%SCRIPT_TEMP_CURRENT_DIR%\svn_props_to_edit.lst"
rem goto LOAD_PROPS_FILTER

rem start to edit
call "%%TOTALCMD_ROOT%%/notepad_edit_files.bat" -wait -npp -nosession -multiInst -notabbar "" "%%PROPS_FILTER_FILE%%"

:LOAD_PROPS_FILTER
set PROPS_FILTER_DIR_INDEX=0
set PROPS_FILTER_FILE_INDEX=0
for /F "usebackq eol=# tokens=1,2 delims=|" %%i in ("%PROPS_FILTER_FILE%") do (
  set "FILTER_PROP_CLASS=%%i"
  set "FILTER_PROP_NAME=%%j"
  call :PROCESS_LOAD_PROPS_FILTER
)

if %PROPS_FILTER_DIR_INDEX% EQU 0 if %PROPS_FILTER_FILE_INDEX% EQU 0 (
  echo.%?~nx0%: error: no properties is selected, nothing to extract.
  exit /b 2
) >&2

goto PROCESS_LOAD_PROPS_FILTER_END

:PROCESS_LOAD_PROPS_FILTER
if "%FILTER_PROP_CLASS%" == "dir" (
  set "PROPS_FILTER[dir][%PROPS_FILTER_DIR_INDEX%]=%FILTER_PROP_NAME%"
  set /A PROPS_FILTER_DIR_INDEX+=1
) else if "%FILTER_PROP_CLASS%" == "file" (
  set "PROPS_FILTER[file][%PROPS_FILTER_FILE_INDEX%]=%FILTER_PROP_NAME%"
  set /A PROPS_FILTER_FILE_INDEX+=1
) else (
  echo.%?~nx0%: warning: ignored unsupported property class: "%FILTER_PROP_CLASS%|%FILTER_PROP_NAME%"
  exit /b 1
) >&2

exit /b 0

:PROCESS_LOAD_PROPS_FILTER_END

mkdir "%PROPS_INOUT_FILES_DIR%" || exit /b 11

if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
  rem to convert from unicode
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001
  set RESTORE_LOCALE=1

  rem Recreate files and recode files w/o BOM applience (do use UTF-16 instead of UCS-2LE/BE for that!)
  rem See for details: https://stackoverflow.com/questions/11571665/using-iconv-to-convert-from-utf-16be-to-utf-8-without-bom/11571759#11571759
  rem
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16 UTF-8 "%%~1" > "%INPUT_LIST_FILE_TMP%"
) else (
  set "INPUT_LIST_FILE_TMP=%~1"
)

rem recreate empty lists
type nul > "%EDIT_LIST_FILE_TMP%"

rem read selected file paths from file
set PATH_INDEX=0
set NUM_PATHS_TO_EDIT=0
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%INPUT_LIST_FILE_TMP%") do (
  set "FILE_PATH=%%i"
  call :EDIT_FILE_PATH
  set /A PATH_INDEX+=1
)

if %NUM_PATHS_TO_EDIT% EQU 0 (
  echo.%?~nx0%: warning: no properties is left to process, nothing to edit.
  pause
  exit /b 12
) >&2

rem start to edit
call "%%TOTALCMD_ROOT%%/notepad_edit_files_by_list.bat"%%BARE_FLAGS%% -wait -nosession -multiInst "" "%%EDIT_LIST_FILE_TMP%%"
echo.

rem read edited property paths from list file
for /F "usebackq eol=	 tokens=1,2,* delims=|" %%i in ("%CHANGESET_LIST_FILE_TMP%") do (
  if %NUM_PATHS_TO_EDIT% EQU 0 echo.Writing properties...
  set "PROP_NAME=%%i"
  set "PROP_VALUE_FILE=%%j"
  set "PROP_FILE_PATH=%%k"
  call :UPDATE_PROPS
)

exit /b 0

:EDIT_FILE_PATH
if %PATH_INDEX% EQU 0 echo.Reading properties...

if "%FILE_PATH:~-1%" == "\" set "FILE_PATH=%FILE_PATH:~0,-1%"

call :GET_FILE_NAME "%%FILE_PATH%%"
goto GET_FILE_NAME_END

:GET_FILE_NAME
set "FILE_NAME=%~nx1"
exit /b 0

:GET_FILE_NAME_END
set /A PROPS_FILTER_PATH_INDEX=0
if exist "%FILE_PATH%\" goto EDIT_DIR_PATH

if %PROPS_FILTER_PATH_INDEX% GEQ %PROPS_FILTER_FILE_INDEX% (
  echo.%?~nx0%: warning: no properties selected for the path: "%FILE_PATH%"
  exit /b 0
) >&2

:EDIT_FILE_PATH_LOOP

set "PATH_INDEX_STR=%PATH_INDEX%"
if %PATH_INDEX% LSS 100 set "PATH_INDEX_STR=0%PATH_INDEX_STR%"
if %PATH_INDEX% LSS 10 set "PATH_INDEX_STR=0%PATH_INDEX_STR%"

set "PROPS_INOUT_PATH_DIR=%PROPS_INOUT_FILES_DIR%\%PATH_INDEX_STR%\%FILE_NAME%"
call set "PROP_NAME=%%PROPS_FILTER[file][%PROPS_FILTER_PATH_INDEX%]%%"
set "PROP_NAME_DECORATED=%PROP_NAME::=--%"

(
  type nul > nul
  if %PROPS_FILTER_PATH_INDEX% EQU 0 ( call :CMD mkdir "%%PROPS_INOUT_PATH_DIR%%" )
) && (
  svn pget "%PROP_NAME%" "%FILE_PATH%" --non-interactive 2>nul >"%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%"
) && (
  copy "%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%" "%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%.orig" /B /Y 2>&1 >nul
  for /F "eol=	 tokens=* delims=" %%i in ("%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%") do (echo.%%i) >> "%EDIT_LIST_FILE_TMP%"
  for /F "eol=	 tokens=* delims=" %%i in ("%PROP_NAME%|%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%|%FILE_PATH%") do (echo.%%i) >> "%CHANGESET_LIST_FILE_TMP%"
  set /A NUM_PATHS_TO_EDIT+=1
)

set /A PROPS_FILTER_PATH_INDEX+=1

if %PROPS_FILTER_PATH_INDEX% LSS %PROPS_FILTER_FILE_INDEX% goto EDIT_FILE_PATH_LOOP

exit /b 0

:EDIT_DIR_PATH
if %PROPS_FILTER_PATH_INDEX% GEQ %PROPS_FILTER_DIR_INDEX% (
  echo.%?~nx0%: warning: no properties selected for the path: "%FILE_PATH%"
  exit /b 0
) >&2

:EDIT_DIR_PATH_LOOP
set "PATH_INDEX_STR=%PATH_INDEX%"
if %PATH_INDEX% LSS 100 set "PATH_INDEX_STR=0%PATH_INDEX_STR%"
if %PATH_INDEX% LSS 10 set "PATH_INDEX_STR=0%PATH_INDEX_STR%"

set "PROPS_INOUT_PATH_DIR=%PROPS_INOUT_FILES_DIR%\%PATH_INDEX_STR%\%FILE_NAME%"
call set "PROP_NAME=%%PROPS_FILTER[dir][%PROPS_FILTER_PATH_INDEX%]%%"
set "PROP_NAME_DECORATED=%PROP_NAME::=--%"

(
  type nul > nul
  if %PROPS_FILTER_PATH_INDEX% EQU 0 ( call :CMD mkdir "%%PROPS_INOUT_PATH_DIR%%" )
) && (
  svn pget "%PROP_NAME%" "%FILE_PATH%" --non-interactive 2>nul >"%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%"
) && (
  copy "%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%" "%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%.orig" /B /Y 2>&1 >nul
  for /F "eol=	 tokens=* delims=" %%i in ("%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%") do (echo.%%i) >> "%EDIT_LIST_FILE_TMP%"
  for /F "eol=	 tokens=* delims=" %%i in ("%PROP_NAME%|%PROPS_INOUT_PATH_DIR%\.%PROP_NAME_DECORATED%|%FILE_PATH%") do (echo.%%i) >> "%CHANGESET_LIST_FILE_TMP%"
  set /A NUM_PATHS_TO_EDIT+=1
)

set /A PROPS_FILTER_PATH_INDEX+=1

if %PROPS_FILTER_PATH_INDEX% LSS %PROPS_FILTER_DIR_INDEX% goto EDIT_DIR_PATH_LOOP

exit /b 0

:UPDATE_PROPS
fc "%PROP_VALUE_FILE%" "%PROP_VALUE_FILE%.orig" > nul
if %ERRORLEVEL% EQU 0 exit /b 0

call :CMD svn pset "%%PROP_NAME%%" "%%PROP_FILE_PATH%%" -F "%%PROP_VALUE_FILE%%" --non-interactive
exit /b

:CMD
echo.^>%*
(%*)