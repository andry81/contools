@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy file(s) from a project single build output directory into a
rem   stage of the same project (build pipeline inside one project). The copy
rem   performs file filtering by pattern.

rem Examples:
rem 1. call xcopy_to_stage.bat "project binaries w/o debug information" "%%STAGE_NAME%%" ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" "*.*" "/E /Y /H" ^
rem    "%%PROJECT_BIN_ROOT_XCOPY_EXCLUDE_DIRS_FILE%%" ^
rem    "@xcopy_msvc_debug_info_files.lst" || exit /b 1

setlocal

set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

set "MSG_TOKEN=%~1"
set "STAGE_NAME=%~2"
set "FROM_STAGE_DIR_ROOT=%~3"
set "TO_STAGE_DIR_ROOT=%~4"
set "FROM_FILE_LIST=%~5"
set "XCOPY_FILE_FLAGS=%~6"
set "XCOPY_EXCLUDE_FILES_LIST=%~7"
set "XCOPY_EXCLUDE_DIRS_LIST=%~8"

if not exist "%FROM_STAGE_DIR_ROOT%" (
  echo.%?~nx0%: error: FROM_STAGE_DIR_ROOT path does not exist: "%FROM_STAGE_DIR_ROOT%"
  exit /b 1
) >&2

rem Drop last error level
type nul>nul

call "%%?~dp0%%__init__.bat" || exit /b

call :FILE_PATH "%%TO_STAGE_DIR_ROOT%%"
set "TO_STAGE_DIR_FILE_PATH=%FILE_PATH%"

call :BASE_PATH "%%TO_STAGE_DIR_ROOT%%"
set "TO_STAGE_DIR_BASE_PATH=%BASE_PATH%"

if "%TO_STAGE_DIR_FILE_PATH%" == "%TO_STAGE_DIR_BASE_PATH%" (
  echo.%?~nx0%: error: TO_STAGE_DIR_ROOT path can not exist: "%TO_STAGE_DIR_ROOT%"
  exit /b 2
) >&2

call :FILE_PATH "%%FROM_STAGE_DIR_ROOT%%"
set "FROM_STAGE_DIR_ROOT=%FILE_PATH%"

set "TO_STAGE_DIR_ROOT=%TO_STAGE_DIR_FILE_PATH%"

set FROM_FILE_INDEX=1
set MSG_PRINTED=0

:FROM_FILE_LOOP
set "FROM_FILE="
for /F "eol=# tokens=%FROM_FILE_INDEX% delims=:" %%i in ("%FROM_FILE_LIST%") do set "FROM_FILE=%%i"
if not defined FROM_FILE goto FROM_FILE_LOOP_END

set /A FROM_FILE_INDEX+=1

call "%%CONTOOLS_ROOT%%/has_dir_files.bat" /S "%%FROM_STAGE_DIR_ROOT%%/%%FROM_FILE%%" || goto FROM_FILE_LOOP

if %MSG_PRINTED% EQU 0 (
  echo.Coping %MSG_TOKEN% files into %STAGE_NAME%...
  set MSG_PRINTED=1
)

if not exist "%TO_STAGE_DIR_ROOT%" call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%TO_STAGE_DIR_ROOT%%"

call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" "%%FROM_STAGE_DIR_ROOT%%" "%%FROM_FILE%%" "%%TO_STAGE_DIR_ROOT%%" %%XCOPY_FILE_FLAGS%% || exit /b 127

goto FROM_FILE_LOOP

:FROM_FILE_LOOP_END

if %MSG_PRINTED% NEQ 0 echo.

exit /b 0

:FILE_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :FILE_PATH_IMPL "%%~1/."
exit /b

:FILE_PATH_IMPL
set "FILE_PATH=%~f1"
exit /b

:BASE_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :BASE_PATH_IMPL "%%~1/."
exit /b

:BASE_PATH_IMPL
set "BASE_PATH=%~dp1"
exit /b
