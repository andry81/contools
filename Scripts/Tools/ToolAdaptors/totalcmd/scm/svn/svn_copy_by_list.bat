@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

pause

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
  if "%FLAG%" == "-from_utf16" (
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

if "%~1" == "" exit /b 0

set "COPY_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\copy_from_file_list.txt"
set "COPY_TO_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\copy_to_file_list.txt"

set "INPUT_LIST_FILE_UTF8_TMP=%SCRIPT_TEMP_CURRENT_DIR%\input_file_list_utf_8.txt"

if %FLAG_CONVERT_FROM_UTF16% NEQ 0 (
  rem to convert from unicode
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001

  rem Recreate files and recode files w/o BOM applience (do use UTF-16 instead of UCS-2LE/BE for that!)
  rem See for details: https://stackoverflow.com/questions/11571665/using-iconv-to-convert-from-utf-16be-to-utf-8-without-bom/11571759#11571759
  rem
  call "%%CONTOOLS_ROOT%%/encoding/ansi2any.bat" UTF-16 UTF-8 "%%~1" > "%INPUT_LIST_FILE_UTF8_TMP%"
) else (
  set "INPUT_LIST_FILE_UTF8_TMP=%~1"
)

rem recreate files
copy "%INPUT_LIST_FILE_UTF8_TMP%" "%COPY_FROM_LIST_FILE_TMP%" /B /Y > nul

rem recreate empty lists
type nul > "%COPY_TO_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%INPUT_LIST_FILE_UTF8_TMP%") do (
  set "FILE_PATH=%%i"
  call :FILL_TO_LIST_FILE_TMP
)

goto FILL_TO_LIST_FILE_TMP_END

:FILL_TO_LIST_FILE_TMP

rem always remove trailing slash character
if "%FILE_PATH:~-1%" == "\" set "FILE_PATH=%FILE_PATH:~0,-1%"

call :GET_FILE_PATH_COMPONENTS PARENT_DIR FILE_NAME "%%FILE_PATH%%"

for /F "eol=	 tokens=* delims=" %%i in ("%PARENT_DIR%|%FILE_NAME%") do (
  (echo.%%i) >> "%COPY_TO_LIST_FILE_TMP%"
)

exit /b 0

:FILL_TO_LIST_FILE_TMP_END

call "%%TOTALCMD_ROOT%%/notepad_edit_files.bat" -wait -npp -nosession -multiInst -notabbar "" "%%COPY_TO_LIST_FILE_TMP%%"

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

rem trick with simultaneous iteration over 2 list in the same time
(
  for /f "usebackq eol=# tokens=* delims=" %%i in ("%COPY_TO_LIST_FILE_TMP%") do (
    set /p "FROM_FILE_PATH="
    set "TO_FILE_PATH=%%i"
    call :PROCESS_COPY
  )
) < "%COPY_FROM_LIST_FILE_TMP%"

endlocal

exit /b 0

:PROCESS_COPY
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

rem file being copied to itself
if /i "%FROM_FILE_PATH%" == "%TO_FILE_PATH%" exit /b 0

if not exist "%FROM_FILE_PATH%" (
  echo.%?~n0%: error: FROM_FILE_PATH is not found: "%FROM_FILE_PATH%".
  exit /b 4
) >&2

rem check recursion only if FROM_FILE_PATH is a directory
if not exist "%FROM_FILE_PATH%\" goto IGNORE_TO_FILE_PATH_CHECK

call "%%CONTOOLS_ROOT%%/subtract_path.bat" "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
if %ERRORLEVEL% EQU 0 (
  echo.%?~n0%: error: TO_FILE_PATH file path must not contain FROM_FILE_PATH file path: FROM_FILE_PATH="%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b 5
) >&2

:IGNORE_TO_FILE_PATH_CHECK

rem check if destination name is changed and print warning
call :GET_FILE_PATH_COMPONENTS FROM_FILE_DIR FROM_FILE_NAME "%%FROM_FILE_PATH%%"

if "%FROM_FILE_PATH:~-1%" == "\" set "FROM_FILE_PATH=%FROM_FILE_PATH:~0,-1%"
if "%TO_FILE_DIR:~-1%" == "\" set "TO_FILE_DIR=%TO_FILE_DIR:~0,-1%"

rem check if file is under SVN version control
svn info "%FROM_FILE_PATH%" --non-interactive >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  call :COPY_FILE SVN
) else (
  rem copy through the shell
  call :COPY_FILE SHELL
)

exit /b

:COPY_FILE
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

goto %MODE%_COPY_FILE

:SVN_COPY_FILE
if not defined TO_FILE_DIR_SUFFIX goto SVN_COPY_FILE_CMD

call "%%CONTOOLS_ROOT%%/index_pathstr.bat" TO_FILE_DIR_SUFFIX \ "%%TO_FILE_DIR_SUFFIX%%"
set TO_FILE_DIR_SUFFIX_ARR_SIZE=%RETURN_VALUE%

:IGNORE_TO_FILE_DIR_SUFFIX_INDEX

rem add to version control
if %TO_FILE_DIR_SUFFIX_ARR_SIZE% EQU 0 goto SVN_COPY_FILE_CMD

set TO_FILE_DIR_SUFFIX_INDEX=1

call :CMD pushd "%%SHARED_ROOT%%" || goto SVN_COPY_FILE_CMD

call :CMD mkdir "%%TO_FILE_DIR_SUFFIX%%"

:SVN_ADD_LOOP
call set "TO_FILE_DIR_SUFFIX_STR=%%TO_FILE_DIR_SUFFIX%TO_FILE_DIR_SUFFIX_INDEX%%%"

call :CMD svn add --depth immediates --non-interactive "%%TO_FILE_DIR_SUFFIX_STR%%"

set /A TO_FILE_DIR_SUFFIX_INDEX+=1

if %TO_FILE_DIR_SUFFIX_INDEX% GTR %TO_FILE_DIR_SUFFIX_ARR_SIZE% goto SVN_ADD_LOOP_END

goto SVN_ADD_LOOP

:SVN_ADD_LOOP_END

call :CMD popd

:SVN_COPY_FILE_CMD
set "TO_FILE_PATH=%SHARED_ROOT%\%TO_FILE_DIR_SUFFIX%"

rem always remove trailing slash character
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

call :CMD svn copy "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%\%%TO_FILE_NAME%%"

exit /b

:SHELL_COPY_FILE
if not defined TO_FILE_DIR_SUFFIX goto SHELL_COPY_FILE_CMD

call :CMD pushd "%%SHARED_ROOT%%" && (
  call :CMD mkdir "%%TO_FILE_DIR_SUFFIX%%"
  call :CMD popd
)

:SHELL_COPY_FILE_CMD
set "TO_FILE_PATH=%SHARED_ROOT%\%TO_FILE_DIR_SUFFIX%"

rem always remove trailing slash character
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

call :CMD copy /B /Y "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%\%%TO_FILE_NAME%%"

exit /b

:CMD
echo.^>%*
(%*)
exit /b

:GET_FILE_PATH_COMPONENTS
set "%~1=%~dp3"
set "%~2=%~nx3"
exit /b 0
