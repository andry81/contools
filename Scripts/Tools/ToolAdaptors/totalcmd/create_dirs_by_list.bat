@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

rem script flags
set PAUSE_ON_EXIT=0

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

if %PAUSE_ON_EXIT% NEQ 0 pause

exit /b %LASTERROR%

:MAIN
rem script flags
set FLAG_CONVERT_FROM_UTF16=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-pause_on_exit" (
    set PAUSE_ON_EXIT=1
  ) else if "%FLAG%" == "-from_utf16" (
    set FLAG_CONVERT_FROM_UTF16=1
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

rem safe title call
setlocal ENABLEDELAYEDEXPANSION
for /F "eol=	 tokens=* delims=" %%i in ("%?~nx0%: !CD!") do (
  endlocal
  title %%i
)

:NOPWD

if not defined PWD exit /b 1

set "CREATE_DIRS_IN_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\create_dirs_in_dirs_list.lst"
set "CREATE_DIRS_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\create_dirs_list.lst"

set "INPUT_LIST_FILE_UTF8_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.lst"

if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
  rem to convert from unicode
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001
)

if not "%~1" == "" (
  if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
    rem Recreate files and recode files w/o BOM applience (do use UTF-16 instead of UCS-2LE/BE for that!)
    rem See for details: https://stackoverflow.com/questions/11571665/using-iconv-to-convert-from-utf-16be-to-utf-8-without-bom/11571759#11571759
    rem
    call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16 UTF-8 "%%~1" > "%INPUT_LIST_FILE_UTF8_TMP%"
  ) else (
    set "INPUT_LIST_FILE_UTF8_TMP=%~1"
  )
)

rem recreate empty lists
type "%CONTOOLS_ROOT:/=\%\encoding\boms\efbbbf.bin" > "%CREATE_DIRS_LIST_FILE_TMP%"

if not "%~1" == "" (
  rem recreate files
  copy "%INPUT_LIST_FILE_UTF8_TMP%" "%CREATE_DIRS_IN_LIST_FILE_TMP%" /B /Y > nul
) else (
  rem recreate empty lists
  type nul > "%CREATE_DIRS_IN_LIST_FILE_TMP%"

  rem use working directory path as base directory path
  setlocal ENABLEDELAYEDEXPANSION
  for /F "eol=	 tokens=* delims=" %%i in ("!CD!") do (
    endlocal
    (echo.%%i) >> "%CREATE_DIRS_IN_LIST_FILE_TMP%"
  )
)

call "%%TOTALCMD_ROOT%%/notepad_edit_files.bat" -wait -npp -nosession -multiInst -notabbar "" "%%CREATE_DIRS_LIST_FILE_TMP%%"

for /f "usebackq eol=# tokens=* delims=" %%i in ("%CREATE_DIRS_IN_LIST_FILE_TMP%") do (
  set "CREATE_DIRS_IN_DIR_PATH=%%i"
  call :PROCESS_CREATE_DIRS_IN_DIR
)

exit /b 0

:PROCESS_CREATE_DIRS_IN_DIR
call :CMD pushd "%%CREATE_DIRS_IN_DIR_PATH%%" || (
  echo.%?~n0%: error: CREATE_DIRS_IN_DIR_PATH does not exist to create subdirectories in it: CREATE_DIRS_IN_DIR_PATH="%CREATE_DIRS_IN_DIR_PATH%".
  exit /b 2
) >&2

set LINE_INDEX=0
for /f "usebackq eol=# tokens=* delims=" %%j in ("%CREATE_DIRS_LIST_FILE_TMP%") do (
  set "CREATE_DIR_PATH=%%j"
  call :PROCESS_CREATE_DIRS
)

call :CMD popd

exit /b 0

:PROCESS_CREATE_DIRS
set /A LINE_INDEX+=1

if not defined CREATE_DIR_PATH exit /b 1

if %FLAG_CONVERT_FROM_UTF16% EQU 0 goto IGNORE_CONVERT_FROM_UTF16

rem trick to remove BOM in the first line
if %LINE_INDEX% EQU 1 set "CREATE_DIR_PATH=%CREATE_DIR_PATH:~1%"

if not defined CREATE_DIR_PATH exit /b 1

:IGNORE_CONVERT_FROM_UTF16
if exist "%CREATE_DIR_PATH%\" exit /b 0

call "%%CONTOOLS_ROOT%%/subtract_path.bat" "%%CD%%" "%%CREATE_DIR_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~n0%: error: CREATE_DIR_PATH must point inside of selected directory: CREATE_DIR_PATH="%CREATE_DIR_PATH%" CD="%CD%".
  exit /b 3
) >&2

set "CREATE_DIR_PATH_REL=%RETURN_VALUE%"

if "%CREATE_DIR_PATH_REL:~-1%" == "\" set "CREATE_DIR_PATH_REL=%CREATE_DIR_PATH_REL:~0,-1%"

call :CMD mkdir "%%CREATE_DIR_PATH_REL%%"

exit /b

:CMD
echo.^>%*
(%*)
