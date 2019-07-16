@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem script flags
set FLAG_PAUSE_ON_EXIT=0
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %FLAG_PAUSE_ON_EXIT% NEQ 0 pause

exit /b %LASTERROR%

:MAIN
rem builtin defaults
if not defined TORTOISEPROC_MAX_SPAWN_CALLS set TORTOISEPROC_MAX_SPAWN_CALLS=10

rem script flags
set FLAG_CONVERT_FROM_UTF16=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set FLAG_PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-from_utf16" (
    set FLAG_CONVERT_FROM_UTF16=1
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "COMMAND=%~1"
set "PWD=%~2"
shift
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

set "INPUT_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.lst"

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

rem build filtered paths list
set "PROPS_PATH_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\props_path_list.lst"

rem calculate maximum busy tasks to wait after, open only TORTOISEPROC_MAX_SPAWN_CALLS windows at the same time
set MAX_SPAWN_TASKS=0

rem create empty file
type nul > "%PROPS_PATH_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%INPUT_LIST_FILE_TMP%") do (
  set "FILE_PATH=%%i"
  call :PROCESS_FILE_PATH
)

goto PROCESS_TASKS

:PROCESS_FILE_PATH
rem run COMMAND over selected files/directories in the PWD directory
if not defined FILE_PATH exit /b 1

rem reduce relative path to avoid . and .. characters
call "%%CONTOOLS_ROOT%%/reduce_relative_path.bat" "%%FILE_PATH%%"
set "FILE_PATH=%RETURN_VALUE%"

set "FILE_PATH_DECORATED=\%FILE_PATH%\"

rem cut off suffix with .svn subdirectory
if "%FILE_PATH_DECORATED:\.svn\=%" == "%FILE_PATH_DECORATED%" goto IGNORE_FILE_PATH_WCROOT_PATH_CUTOFF

set "FILE_PATH_WCROOT_SUFFIX=%FILE_PATH_DECORATED:*.svn\=%"

set "FILE_PATH_WCROOT_PREFIX=%FILE_PATH_DECORATED%"
if not defined FILE_PATH_WCROOT_SUFFIX goto CUTOFF_WCROOT_PREFIX

call set "FILE_PATH_WCROOT_PREFIX=%%FILE_PATH_DECORATED:\%FILE_PATH_WCROOT_SUFFIX%=%%"

:CUTOFF_WCROOT_PREFIX
rem remove bounds character and extract diretory path
if "%FILE_PATH_DECORATED:~-1%" == "\" set "FILE_PATH_DECORATED=%FILE_PATH_DECORATED:~0,-1%"
call "%%CONTOOLS_ROOT%%/split_pathstr.bat" "%%FILE_PATH_DECORATED:~1%%" \ "" FILE_PATH

rem should not be empty
if not defined FILE_PATH set FILE_PATH=.

:IGNORE_FILE_PATH_WCROOT_PATH_CUTOFF

rem safe echo call
setlocal ENABLEDELAYEDEXPANSION
for /F "eol=	 tokens=* delims=" %%i in ("!FILE_PATH!") do (
  endlocal
  (echo.%%i) >> "%PROPS_PATH_LIST_FILE_TMP%"
)

set /A MAX_SPAWN_TASKS+=1

exit /b

:PROCESS_TASKS
call :SPAWN_TASKS "%%CONTOOLS_ROOT%%/tasks/spawn_tasks.bat" "%%MAX_SPAWN_TASKS%%" "%%TORTOISEPROC_MAX_SPAWN_CALLS%%" 0 call "%%TOTALCMD_ROOT%%/scm/tortoisesvn/TortoiseProc_read_path_from_stdin.bat"
exit /b

:SPAWN_TASKS
echo.^>%*
(
  %*
) < "%PROPS_PATH_LIST_FILE_TMP%"
