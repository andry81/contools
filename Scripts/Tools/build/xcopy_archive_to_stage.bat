@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive file(s) from a project single build output
rem   directory into a stage of calling project (build pipeline inside one
rem   project). The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stage.bat "stage-in project debug information" "stage" ^
rem    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" ^
rem    "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
rem    "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%/%%STAGE_IN.PROJECT_NAME%%_pdb_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
rem    "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" ^
rem    "@archive_exclude_file_list.lst|*.lib|*.exp" || exit /b

setlocal

set "?~n0=%~n0"
set "?~nx0=%~nx0"
set "?~dp0=%~dp0"

set "MSG_TOKEN=%~1"
set "STAGE_NAME=%~2"
set "COPY_FROM_STAGE_ROOT=%~3"
set "COPY_TO_STAGE_ROOT=%~4"
set "ARCHIVE_COPY_FROM_OFFSET=%~5"
set "ARCHIVE_FILE_PATH=%~6"
set "ARCHIVE_FILE_LIST=%~7"
set "COPY_FILE_LIST=%~8"
set "XCOPY_FILE_FLAGS=%~9"
shift
shift
set "ARCHIVE_EXCLUDE_FILES_LIST=%~8"
set "ARCHIVE_EXCLUDE_DIRS_LIST=%~9"

rem Drop last error level
type nul>nul

call "%%?~dp0%%__init__.bat" || exit /b

set LASTERROR=0

if not exist "%COPY_FROM_STAGE_ROOT%" (
  echo.%?~nx0%: error: COPY_FROM_STAGE_ROOT path does not exist: "%COPY_FROM_STAGE_ROOT%"
  exit /b 1
) >&2

if defined ARCHIVE_COPY_FROM_OFFSET (
  set "ARCHIVE_FROM_STAGE_DIR_ROOT=%COPY_FROM_STAGE_ROOT%/%ARCHIVE_COPY_FROM_OFFSET%"
) else (
  set "ARCHIVE_FROM_STAGE_DIR_ROOT=%COPY_FROM_STAGE_ROOT%"
)

call :ABS_PATH "%%ARCHIVE_FROM_STAGE_DIR_ROOT%%"
set "ARCHIVE_FROM_STAGE_DIR_ROOT=%ABS_PATH%"

rem rem suppress offset over 1 file directory level
rem set "ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH=%COPY_FROM_STAGE_ROOT%/dummy/%ARCHIVE_COPY_FROM_OFFSET%"
rem 
rem call :FILE_PATH "%%ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH%%"
rem set "ARCHIVE_FROM_STAGE_DIR_DUMMY_FILE_PATH=%FILE_PATH%"
rem 
rem call :PARENT_PATH "%%ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH%%"
rem set "ARCHIVE_FROM_STAGE_DIR_DUMMY_PARENT_PATH=%PARENT_PATH%"
rem 
rem if "%ARCHIVE_FROM_STAGE_DIR_DUMMY_FILE_PATH%" == "%ARCHIVE_FROM_STAGE_DIR_DUMMY_PARENT_PATH%" (
rem   echo.%?~nx0%: error: COPY_FROM_STAGE_ROOT/ARCHIVE_COPY_FROM_OFFSET path can not exist: "%ARCHIVE_FROM_STAGE_DIR_ROOT%"
rem   exit /b 2
rem ) >&2

call :FILE_PATH "%%ARCHIVE_FILE_PATH%%"
set "ARCHIVE_FILE_FILE_PATH=%FILE_PATH%"

call :PARENT_PATH "%%ARCHIVE_FILE_PATH%%"
set "ARCHIVE_FILE_PARENT_ROOT=%PARENT_PATH%"

if "%ARCHIVE_FILE_FILE_PATH%" == "%ARCHIVE_FILE_PARENT_ROOT%" (
  echo.%?~nx0%: error: ARCHIVE_FILE_PATH base path can not exist: "%ARCHIVE_FILE_PATH%"
  exit /b 3
) >&2

call :FILE_PATH "%%COPY_TO_STAGE_ROOT%%"
set "COPY_TO_STAGE_DIR_FILE_PATH=%FILE_PATH%"

call :PARENT_PATH "%%COPY_TO_STAGE_ROOT%%"
set "COPY_TO_STAGE_DIR_PARENT_PATH=%PARENT_PATH%"

if "%COPY_TO_STAGE_DIR_FILE_PATH%" == "%COPY_TO_STAGE_DIR_PARENT_PATH%" (
  echo.%?~nx0%: error: TO_STAGE_DIR_PATH base path can not exist: "%COPY_TO_STAGE_ROOT%"
  exit /b 4
) >&2

call :FILE_PATH "%%COPY_FROM_STAGE_ROOT%%"
set "COPY_FROM_STAGE_ROOT=%FILE_PATH%"

call :FILE_PATH "%%ARCHIVE_FROM_STAGE_DIR_ROOT%%"
set "ARCHIVE_FROM_STAGE_DIR_ROOT=%FILE_PATH%"

set "ARCHIVE_FILE_PATH=%ARCHIVE_FILE_FILE_PATH%"
set "COPY_TO_STAGE_ROOT=%COPY_TO_STAGE_DIR_FILE_PATH%"

rem <ARCHIVE_DIR_PREFIX_PATH> = <COPY_FROM_STAGE_ROOT> - <ARCHIVE_FROM_STAGE_DIR_ROOT>
call "%%CONTOOLS_ROOT%%/filesys/subtract_path.bat" "%%ARCHIVE_FROM_STAGE_DIR_ROOT%%" "%%COPY_FROM_STAGE_ROOT%%"
set "ARCHIVE_DIR_PREFIX_PATH=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT%%/uuidgen.bat"
set "XCOPY_ARCHIVE_EXCLUDES_FILE=%TEMP%\%?~n0%.%RETURN_VALUE%.txt"

call :DEL_XCOPY_ARCHIVE_EXCLUDES_FILE || exit /b 10

set "ARCHIVE_STAGE_FILE_PATH_LIST="
set FROM_FILE_INDEX=1
set MSG_PRINTED=0

:CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST
if not defined ARCHIVE_FILE_LIST set "ARCHIVE_FILE_LIST=*.*"

set "FROM_FILE="
for /F "eol=# tokens=%FROM_FILE_INDEX% delims=:" %%i in ("%ARCHIVE_FILE_LIST%") do set "FROM_FILE=%%i"
if not defined FROM_FILE goto CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST_END

set /A FROM_FILE_INDEX+=1

set ARCHIVE_STAGE_FILE_PATH_LIST=%ARCHIVE_STAGE_FILE_PATH_LIST% "%COPY_FROM_STAGE_ROOT%/%FROM_FILE%"
(echo.%FROM_FILE:*.=.%)>> "%XCOPY_ARCHIVE_EXCLUDES_FILE%"

goto CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST

:CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST_END

set "ARCHIVE_7ZIP_EXCLUDES_CMD="

if not defined ARCHIVE_EXCLUDE_FILES_LIST goto IGNORE_ARCHIVE_EXCLUDES

call "%%CONTOOLS_ROOT%%/xcopy/convert_excludes_to_7zip.bat" "%%ARCHIVE_EXCLUDE_FILES_LIST%%" "%%ARCHIVE_EXCLUDE_DIRS_LIST%%"
if %ERRORLEVEL% EQU 0 set ARCHIVE_7ZIP_EXCLUDES_CMD=%RETURN_VALUE%

:IGNORE_ARCHIVE_EXCLUDES

:ARCHIVE_STAGE
call "%%CONTOOLS_ROOT%%/has_dir_files.bat" /S %%ARCHIVE_STAGE_FILE_PATH_LIST%% || goto COPY_STAGE

echo.Archiving %MSG_TOKEN% files into %STAGE_NAME%...

if not exist "%COPY_TO_STAGE_ROOT%" call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%COPY_TO_STAGE_ROOT%%"

set FROM_FILE_INDEX=1

:ARCHIVE_FILE_LIST
set "TO_FILE="
for /F "eol=# tokens=%FROM_FILE_INDEX% delims=:" %%i in ("%ARCHIVE_FILE_LIST%") do set "TO_FILE=%%i"
if not defined TO_FILE goto ARCHIVE_FILE_LIST_END

set /A FROM_FILE_INDEX+=1

if defined ARCHIVE_DIR_PREFIX_PATH (
  call "%%BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%ARCHIVE_FROM_STAGE_DIR_ROOT%%" "%%ARCHIVE_DIR_PREFIX_PATH%%/%%TO_FILE%%" "%%ARCHIVE_FILE_PATH%%"%%ARCHIVE_7ZIP_EXCLUDES_CMD%% || ( set LASTERROR=11 & goto EXIT )
) else (
  call "%%BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%ARCHIVE_FROM_STAGE_DIR_ROOT%%" "%%TO_FILE%%" "%%ARCHIVE_FILE_PATH%%"%%ARCHIVE_7ZIP_EXCLUDES_CMD%% || ( set LASTERROR=11 & goto EXIT )
)

goto ARCHIVE_FILE_LIST

:ARCHIVE_FILE_LIST_END

echo.

:COPY_STAGE
if exist "%XCOPY_ARCHIVE_EXCLUDES_FILE%" (
  call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "%%MSG_TOKEN%%" "%%STAGE_NAME%%" "%%COPY_FROM_STAGE_ROOT%%" "%%COPY_TO_STAGE_ROOT%%" "%%COPY_FILE_LIST%%" ^
    "%%XCOPY_FILE_FLAGS%%" "@%%XCOPY_ARCHIVE_EXCLUDES_FILE%%" || ( set LASTERROR=12 & goto EXIT )
) else (
  call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "%%MSG_TOKEN%%" "%%STAGE_NAME%%" "%%COPY_FROM_STAGE_ROOT%%" "%%COPY_TO_STAGE_ROOT%%" "%%COPY_FILE_LIST%%" ^
    "%%XCOPY_FILE_FLAGS%%" || ( set LASTERROR=12 & goto EXIT )
)

goto :EXIT

:ABS_PATH
set "ABS_PATH=%~dpf1"
exit /b

:FILE_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :FILE_PATH_IMPL "%%~1/."
exit /b

:FILE_PATH_IMPL
set "FILE_PATH=%~dpf1"
exit /b

:PARENT_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :PARENT_PATH_IMPL "%%~1/."
exit /b

:PARENT_PATH_IMPL
set "PARENT_PATH=%~dp1"
exit /b

:EXIT
call :DEL_XCOPY_ARCHIVE_EXCLUDES_FILE
exit /b %LASTERROR%

:DEL_XCOPY_ARCHIVE_EXCLUDES_FILE
if exist "%XCOPY_ARCHIVE_EXCLUDES_FILE%" ( call "%%CONTOOLS_ROOT%%/std/del_file.bat" "%%XCOPY_ARCHIVE_EXCLUDES_FILE%%" /A:-D /F /Q >nul || exit /b 1 )
exit /b 0
