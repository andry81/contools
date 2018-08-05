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
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

title %?~nx0%: %CD%

:NOPWD

if not defined PWD exit /b 1

set "CREATE_DIRS_IN_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\create_dirs_in_dirs_list.txt"
set "CREATE_DIRS_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\create_dirs_list.txt"

rem recreate empty lists
type nul > "%CREATE_DIRS_IN_LIST_FILE_TMP%"
type nul > "%CREATE_DIRS_LIST_FILE_TMP%"

if not "%~1" == "" (
  rem read selected file paths from file
  for /F "usebackq eol=	 tokens=* delims=" %%i in ("%~1") do (
    (echo.%%i) >> "%CREATE_DIRS_IN_LIST_FILE_TMP%"
  )
) else (
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
)

for /f "usebackq eol=# tokens=* delims=" %%j in ("%CREATE_DIRS_LIST_FILE_TMP%") do (
  set "CREATE_DIR_PATH=%%j"
  call :PROCESS_CREATE_DIRS
)

call :CMD popd

exit /b 0

:PROCESS_CREATE_DIRS
if not defined CREATE_DIR_PATH exit /b 1

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
