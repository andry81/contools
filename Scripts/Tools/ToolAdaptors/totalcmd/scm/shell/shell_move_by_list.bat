@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

title %?~nx0%: %CD%

call "%%?~dp0%%__init__.bat" || goto :EOF

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
rem set FLAG_WAIT_EXIT=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

rem if defined FLAG (
rem   if "%FLAG%" == "-wait" (
rem     set FLAG_WAIT_EXIT=1
rem     shift
rem   ) else (
rem     echo.%?~nx0%: error: invalid flag: %FLAG%
rem     exit /b -255
rem   )
rem 
rem   rem read until no flags
rem   goto FLAGS_LOOP
rem )

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

title %?~nx0%: %CD%

:NOPWD

if "%~1" == "" exit /b 0

set "MOVE_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\move_from_file_list.txt"
set "MOVE_TO_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\move_to_file_list.txt"

rem recreate empty lists
type nul > "%MOVE_FROM_LIST_FILE_TMP%"
type nul > "%MOVE_TO_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%~1") do (
  (echo.%%i) >> "%MOVE_FROM_LIST_FILE_TMP%"
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

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

(
  for /f "usebackq eol=# tokens=* delims=" %%i in ("%MOVE_TO_LIST_FILE_TMP%") do (
    set /p "FROM_FILE_PATH="
    set "TO_FILE_PATH=%%i"
    call :PROCESS_MOVE
  )
) < "%MOVE_FROM_LIST_FILE_TMP%"

endlocal

exit /b 0

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

if not "%FROM_FILE_NAME%" == "%TO_FILE_NAME%" (
  echo.%?~n0%: warning: move does not imply rename, destination file name should not change ^(rename ignored^): FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
)

if "%FROM_FILE_PATH:~-1%" == "\" set "FROM_FILE_PATH=%FROM_FILE_PATH:~0,-1%"
if "%TO_FILE_DIR:~-1%" == "\" set "TO_FILE_DIR=%TO_FILE_DIR:~0,-1%"

rem move through the shell
rem :MOVE_FILE SHELL

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
