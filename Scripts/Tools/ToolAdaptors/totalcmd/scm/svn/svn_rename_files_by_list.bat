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

set "RENAME_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\rename_from_file_list.txt"
set "RENAME_TO_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\rename_to_file_list.txt"

rem recreate empty lists
type nul > "%RENAME_FROM_LIST_FILE_TMP%"
type nul > "%RENAME_TO_LIST_FILE_TMP%"

rem read selected file paths from file
for /F "usebackq eol=	 delims=" %%i in ("%~1") do (
  rem must be files, not sub directories
  if not exist "%%i\" (
    (echo.%%i) >> "%RENAME_FROM_LIST_FILE_TMP%"
    (echo.%%i) >> "%RENAME_TO_LIST_FILE_TMP%"
  )
)

call "%%TOTALCMD_ROOT%%/notepad_edit_files.bat" -wait -npp -nosession -multiInst -notabbar "" "%%RENAME_TO_LIST_FILE_TMP%%"

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

(
    for /f "usebackq eol=# tokens=* delims=" %%i in ("%RENAME_TO_LIST_FILE_TMP%") do (
        set /p "FROM_FILE_PATH="
        set "TO_FILE_PATH=%%i"
        call :PROCESS_RENAME
    )
) < "%RENAME_FROM_LIST_FILE_TMP%"

endlocal

exit /b 0

:PROCESS_RENAME
if not defined FROM_FILE_PATH exit /b 1
if not defined TO_FILE_PATH exit /b 2

if /i "%FROM_FILE_PATH%" == "%TO_FILE_PATH%" exit /b 0

if exist "%TO_FILE_PATH%" (
  echo.%?~n0%: error: TO_FILE_PATH already exists: "%TO_FILE_PATH%".
  exit /b 3
) >&2

if not exist "%FROM_FILE_PATH%" (
  echo.%?~n0%: error: FROM_FILE_PATH is not found: "%FROM_FILE_PATH%".
  exit /b 4
) >&2

rem check if file is under SVN version contorl
set "SVN_STATUS_OUT="
for /F "usebackq eol=	 tokens=* delims=" %%i in (`svn status "%FROM_FILE_PATH%" --depth files --non-interactive 2^>nul`) do (
  set "SVN_STATUS_OUT=%%i"
  goto FOR_BREAK
)

:FOR_BREAK

if not defined SVN_STATUS_OUT goto SVN_RENAME
if "%SVN_STATUS_OUT:~0,1%" == "?" goto SHELL_RENAME

:SVN_RENAME
call :SVN_RENAME_FILE "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
goto SHELL_RENAME_END

:SHELL_RENAME
call :SHELL_RENAME_FILE "%%FROM_FILE_PATH%%" "%%TO_FILE_PATH%%"
goto SHELL_RENAME_END

:SHELL_RENAME_END

exit /b

:SVN_RENAME_FILE
set "FROM_FILE_DIR=%~dp1"
set "TO_FILE_DIR=%~dp2"
if /i "%FROM_FILE_DIR%" == "%TO_FILE_DIR%" (
  call :CMD svn rename "%%~1" "%%~nx2"
) else (
  echo.%?~n0%: error: file directory path must stay the same: FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b -254
) >&2

exit /b

:SHELL_RENAME_FILE
set "FROM_FILE_DIR=%~dp1"
set "TO_FILE_DIR=%~dp2"
if /i "%FROM_FILE_DIR%" == "%TO_FILE_DIR%" (
  call :CMD rename "%%~1" "%%~nx2"
) else (
  echo.%?~n0%: error: file directory path must stay the same: FROM_FILE_PATH=%FROM_FILE_PATH%" TO_FILE_PATH="%TO_FILE_PATH%".
  exit /b -254
) >&2

exit /b

:CMD
echo.^>%*
(%*)
