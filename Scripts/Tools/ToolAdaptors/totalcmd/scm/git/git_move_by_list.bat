@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

rem script flags
set PAUSE_ON_EXIT=0
set RESTORE_LOCALE=0

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

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
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

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

if "%~1" == "" exit /b 0

set "MOVE_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.lst"
set "MOVE_TO_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\move_to_file_list.lst"

if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
  rem to convert from unicode
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001
  set RESTORE_LOCALE=1

  rem Recreate files and recode files w/o BOM applience (do use UTF-16 instead of UCS-2LE/BE for that!)
  rem See for details: https://stackoverflow.com/questions/11571665/using-iconv-to-convert-from-utf-16be-to-utf-8-without-bom/11571759#11571759
  rem
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16 UTF-8 "%%~1" > "%MOVE_FROM_LIST_FILE_TMP%"
) else (
  set "MOVE_FROM_LIST_FILE_TMP=%~1"
)

rem recreate empty lists
type nul > "%MOVE_TO_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%MOVE_FROM_LIST_FILE_TMP%") do (
  set "FILE_PATH=%%i"
  call :FILL_TO_LIST_FILE_TMP
)

goto FILL_TO_LIST_FILE_TMP_END

:FILL_TO_LIST_FILE_TMP

rem always remove trailing slash character
if "%FILE_PATH:~-1%" == "\" set "FILE_PATH=%FILE_PATH:~0,-1%"

call :GET_FILE_PATH_COMPONENTS PARENT_DIR FILE_NAME "%%FILE_PATH%%"

for /F "eol=	 tokens=* delims=" %%i in ("%PARENT_DIR%|%FILE_NAME%") do (
  (echo.%%i) >> "%MOVE_TO_LIST_FILE_TMP%"
)

exit /b 0

:FILL_TO_LIST_FILE_TMP_END

call "%%TOTALCMD_ROOT%%/notepad_edit_files.bat" -wait -npp -nosession -multiInst -notabbar "" "%%MOVE_TO_LIST_FILE_TMP%%"

rem trick with simultaneous iteration over 2 list in the same time
(
  for /f "usebackq eol=# tokens=* delims=" %%i in ("%MOVE_TO_LIST_FILE_TMP%") do (
    set /P "FROM_FILE_PATH="
    set "TO_FILE_PATH=%%i"
    call :PROCESS_MOVE
  )
) < "%MOVE_FROM_LIST_FILE_TMP%"

exit /b

:PROCESS_MOVE
if not defined FROM_FILE_PATH exit /b 1
if not defined TO_FILE_PATH exit /b 2

rem always remove trailing slash character
if "%FROM_FILE_PATH:~-1%" == "\" set "FROM_FILE_PATH=%FROM_FILE_PATH:~0,-1%"
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

rem extract destination path components
for /F "eol=	 tokens=1,* delims=|" %%i in ("%TO_FILE_PATH%") do (
  set "TO_FILE_DIR=%%i"
  set "TO_FILE_NAME=%%j"
)

rem concatenate
set "TO_FILE_PATH=%TO_FILE_PATH:|=%"

rem file is not moved
if /i "%FROM_FILE_PATH%" == "%TO_FILE_PATH%" exit /b 0

if not exist "%FROM_FILE_PATH%" (
  echo.%?~n0%: error: FROM_FILE_PATH is not found: "%FROM_FILE_PATH%".
  exit /b 4
) >&2

rem check recursion only if FROM_FILE_PATH is a directory
if not exist "%FROM_FILE_PATH%\" goto IGNORE_TO_FILE_PATH_CHECK

call "%%CONTOOLS_ROOT%%/subtract_path.bat" "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
if %ERRORLEVEL% EQU 0 (
  echo.%?~n0%: error: TO_FILE_PATH directory path must not contain FROM_FILE_PATH directory path: FROM_FILE_PATH="%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b 5
) >&2

:IGNORE_TO_FILE_PATH_CHECK

rem check if destination name is changed and print warning
call :GET_FILE_PATH_COMPONENTS FROM_FILE_DIR FROM_FILE_NAME "%%FROM_FILE_PATH%%"

if not "%FROM_FILE_NAME%" == "%TO_FILE_NAME%" (
  echo.%?~n0%: warning: move does not imply rename, destination file name should not change ^(rename ignored^): FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b 6
)

if "%FROM_FILE_PATH:~-1%" == "\" set "FROM_FILE_PATH=%FROM_FILE_PATH:~0,-1%"
if "%TO_FILE_DIR:~-1%" == "\" set "TO_FILE_DIR=%TO_FILE_DIR:~0,-1%"

rem check if file is under GIT version control

rem WORKAROUND:
rem  Git ignores absolute path as an command argument and anyway searches current working directory for the repository.
rem  Use `pushd` to set the current directory to parent directory of being processed item.
rem

call :CMD pushd "%%FROM_FILE_DIR%%" && (
  call :CMD git ls-files --error-unmatch "%%FROM_FILE_PATH%%" >nul 2>nul && (
    call :MOVE_FILE GIT
    rem to avoid trigger the shell copy block on not zero return code from above command
    goto MOVE_END
  ) || (
    rem move through the shell
    call :MOVE_FILE SHELL
  )
)

:MOVE_END
set LASTERROR=%ERRORLEVEL%

call :CMD popd

exit /b %LASTERROR%

:MOVE_FILE
set "MODE=%~1"

call "%%CONTOOLS_ROOT%%/get_shared_path.bat" "%%FROM_FILE_PATH%%" "%%TO_FILE_DIR%%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~n0%: error: source file path and destination file directory must share a common root path: FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_DIR="%TO_FILE_DIR%".
  exit /b -253
) >&2

set "SHARED_ROOT=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/subtract_path.bat" "%%SHARED_ROOT%%" "%%TO_FILE_DIR%%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~n0%: error: shared path root is not a prefix to TO_FILE_DIR path: SHARED_ROOT="%SHARED_ROOT%" TO_FILE_DIR="%TO_FILE_DIR%".
  exit /b -252
) >&2

set "TO_FILE_DIR_SUFFIX=%RETURN_VALUE%"

goto %MODE%_MOVE_FILE

:GIT_MOVE_FILE
if not defined TO_FILE_DIR_SUFFIX goto GIT_MOVE_FILE_CMD

call :CMD pushd "%%SHARED_ROOT%%" && (
  call :CMD mkdir "%%TO_FILE_DIR_SUFFIX%%"
  call :CMD popd
)

:GIT_MOVE_FILE_CMD
set "TO_FILE_PATH=%SHARED_ROOT%\%TO_FILE_DIR_SUFFIX%"

rem always remove trailing slash character
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

call :CMD git mv "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"

exit /b

:SHELL_MOVE_FILE
if not defined TO_FILE_DIR_SUFFIX goto SHELL_MOVE_FILE_CMD

call :CMD pushd "%%SHARED_ROOT%%" && (
  call :CMD mkdir "%%TO_FILE_DIR_SUFFIX%%"
  call :CMD popd
)

:SHELL_MOVE_FILE_CMD
set "TO_FILE_PATH=%SHARED_ROOT%\%TO_FILE_DIR_SUFFIX%"

rem always remove trailing slash character
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

call :CMD move "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"

exit /b

:CMD
echo.^>%*
(%*)
exit /b

:GET_FILE_PATH_COMPONENTS
set "%~1=%~dp3"
set "%~2=%~nx3"
exit /b 0
