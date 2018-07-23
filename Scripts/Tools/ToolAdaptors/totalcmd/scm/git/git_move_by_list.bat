@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

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

:NOPWD

if "%~1" == "" exit /b 0

set "MOVE_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\move_from_file_list.txt"
set "MOVE_TO_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\move_to_file_list.txt"

rem recreate empty lists
type nul > "%MOVE_FROM_LIST_FILE_TMP%"
type nul > "%MOVE_TO_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 delims=" %%i in ("%~1") do (
  (echo.%%i) >> "%MOVE_FROM_LIST_FILE_TMP%"
  (echo.%%i) >> "%MOVE_TO_LIST_FILE_TMP%"
)

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

if "%FROM_FILE_PATH:~-1%" == "\" set "FROM_FILE_PATH=%FROM_FILE_PATH:~0,-1%"
if "%TO_FILE_PATH:~-1%" == "\" set "TO_FILE_PATH=%TO_FILE_PATH:~0,-1%"

rem check if file is under GIT version contorl
git ls-files --error-unmatch "%FROM_FILE_PATH%" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  call :MOVE_FILE GIT "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
) else (
  rem move through the shell
  call :MOVE_FILE SHELL "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
)

exit /b

:MOVE_FILE
set "MODE=%~1"
shift
set "FROM_FILE_DIR=%~dp1"
set "TO_FILE_DIR=%~dp2"

call "%%CONTOOLS_ROOT%%/get_shared_path.bat" "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~n0%: error: source file path and destination file path must share a common root path: FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b -253
) >&2

set "SHARED_ROOT=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/subtract_path.bat" "%%SHARED_ROOT%%" "%%TO_FILE_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  echo.%?~n0%: error: shared path root is not a prefix to TO_FILE_PATH path: SHARED_ROOT="%SHARED_ROOT%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b -252
) >&2

set "TO_FILE_PATH_SUFFIX=%RETURN_VALUE%"

goto %MODE%_MOVE_FILE

:GIT_MOVE_FILE
if not defined TO_FILE_PATH_SUFFIX goto GIT_MOVE_FILE_CMD

rem rem add to version control
rem call "%%CONTOOLS_ROOT%%/index_pathstr.bat" TO_FILE_PATH_SUFFIX \ "%%TO_FILE_PATH_SUFFIX%%"
rem set TO_FILE_PATH_SUFFIX_ARR_SIZE=%RETURN_VALUE%
rem 
rem if %TO_FILE_PATH_SUFFIX_ARR_SIZE% EQU 0 goto GIT_MOVE_FILE_CMD
rem 
rem set TO_FILE_PATH_SUFFIX_INDEX=1
rem 
rem call :CMD pushd "%%SHARED_ROOT%%" || goto GIT_MOVE_FILE_CMD
rem 
rem call :CMD mkdir "%%TO_FILE_PATH_SUFFIX%%"
rem 
rem :GIT_ADD_LOOP
rem call set "TO_FILE_PATH_SUFFIX_STR=%%TO_FILE_PATH_SUFFIX%TO_FILE_PATH_SUFFIX_INDEX%%%"
rem 
rem call :CMD git add "%%TO_FILE_PATH_SUFFIX_STR%%"
rem 
rem set /A TO_FILE_PATH_SUFFIX_INDEX+=1
rem 
rem if %TO_FILE_PATH_SUFFIX_INDEX% GTR %TO_FILE_PATH_SUFFIX_ARR_SIZE% goto GIT_ADD_LOOP_END
rem 
rem goto GIT_ADD_LOOP
rem 
rem :GIT_ADD_LOOP_END
rem 
rem call :CMD popd
rem 
rem :GIT_MOVE_FILE_CMD

call :CMD pushd "%%SHARED_ROOT%%" && (
  call :CMD mkdir "%%TO_FILE_PATH_SUFFIX%%"
  call :CMD popd
)

:GIT_MOVE_FILE_CMD
rem workaround to move directory/file into parent path directory
if not defined TO_FILE_PATH_SUFFIX set "TO_FILE_PATH_SUFFIX=."
if "%TO_FILE_PATH_SUFFIX:~-1%" == "\" set "TO_FILE_PATH_SUFFIX=%TO_FILE_PATH_SUFFIX%."

call :CMD git mv "%%~1" "%%SHARED_ROOT%%\%%TO_FILE_PATH_SUFFIX%%"

exit /b

:SHELL_MOVE_FILE
if not defined TO_FILE_PATH_SUFFIX goto SHELL_MOVE_FILE_CMD

call :CMD pushd "%%SHARED_ROOT%%" && (
  call :CMD mkdir "%%TO_FILE_PATH_SUFFIX%%"
  call :CMD popd
)

:SHELL_MOVE_FILE_CMD
rem workaround to move directory/file into parent path directory
if not defined TO_FILE_PATH_SUFFIX set "TO_FILE_PATH_SUFFIX=."
if "%TO_FILE_PATH_SUFFIX:~-1%" == "\" set "TO_FILE_PATH_SUFFIX=%TO_FILE_PATH_SUFFIX%."

call :CMD move "%%~1" "%%SHARED_ROOT%%\%%TO_FILE_PATH_SUFFIX%%"

exit /b

:CMD
echo.^>%*
(%*)
