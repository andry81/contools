@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive file(s) from a project single build output
rem   directory into a stage of calling project (build pipeline inside one
rem   project). The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stage.bat "stage-in project debug information" "stage" ^
rem    "%%STAGE_IN.PROJECT_STAGE_PDB_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" ^
rem    "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
rem    "%%PROJECT_STAGE_PDB_PATH%%/%%STAGE_IN.PROJECT_NAME%%_pdb_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
rem    "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" || exit /b 1

setlocal

set "?~n0=%~n0"
set "?~nx0=%~nx0"

set "MSG_TOKEN=%~1"
set "STAGE_NAME=%~2"
set "COPY_FROM_STAGE_DIR_PATH=%~3"
set "COPY_TO_STAGE_DIR_PATH=%~4"
set "ARCHIVE_COPY_FROM_OFFSET=%~5"
set "ARCHIVE_FILE_PATH=%~6"
set "ARCHIVE_FILE_LIST=%~7"
set "COPY_FILE_LIST=%~8"
set "XCOPY_FILE_FLAGS=%~9"

rem Drop last error level
cd .

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0.."
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

set LASTERROR=0

if not exist "%COPY_FROM_STAGE_DIR_PATH%" (
  echo.%?~nx0%: error: COPY_FROM_STAGE_DIR_PATH path does not exist: "%COPY_FROM_STAGE_DIR_PATH%"
  exit /b 1
) >&2

if not "%ARCHIVE_COPY_FROM_OFFSET%" == "" (
  set "ARCHIVE_FROM_STAGE_DIR_PATH=%COPY_FROM_STAGE_DIR_PATH%/%ARCHIVE_COPY_FROM_OFFSET%"
) else (
  set "ARCHIVE_FROM_STAGE_DIR_PATH=%COPY_FROM_STAGE_DIR_PATH%"
)

rem suppress offset over 1 file directory level
set "ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH=%COPY_FROM_STAGE_DIR_PATH%/dummy/%ARCHIVE_COPY_FROM_OFFSET%"

call :FILE_PATH "%%ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH%%"
set "ARCHIVE_FROM_STAGE_DIR_DUMMY_FILE_PATH=%FILE_PATH%"

call :BASE_PATH "%%ARCHIVE_FROM_STAGE_DIR_DUMMY_PATH%%"
set "ARCHIVE_FROM_STAGE_DIR_DUMMY_BASE_PATH=%BASE_PATH%"

if "%ARCHIVE_FROM_STAGE_DIR_DUMMY_FILE_PATH%" == "%ARCHIVE_FROM_STAGE_DIR_DUMMY_BASE_PATH%" (
  echo.%?~nx0%: error: COPY_FROM_STAGE_DIR_PATH/ARCHIVE_COPY_FROM_OFFSET path can not exist: "%ARCHIVE_FROM_STAGE_DIR_PATH%"
  exit /b 2
) >&2

call :FILE_PATH "%%ARCHIVE_FILE_PATH%%"
set "ARCHIVE_FILE_FILE_PATH=%FILE_PATH%"

call :BASE_PATH "%%ARCHIVE_FILE_PATH%%"
set "ARCHIVE_FILE_BASE_PATH=%BASE_PATH%"

if "%ARCHIVE_FILE_FILE_PATH%" == "%ARCHIVE_FILE_BASE_PATH%" (
  echo.%?~nx0%: error: ARCHIVE_FILE_PATH base path can not exist: "%ARCHIVE_FILE_PATH%"
  exit /b 3
) >&2

call :FILE_PATH "%%COPY_TO_STAGE_DIR_PATH%%"
set "COPY_TO_STAGE_DIR_FILE_PATH=%FILE_PATH%"

call :BASE_PATH "%%COPY_TO_STAGE_DIR_PATH%%"
set "COPY_TO_STAGE_DIR_BASE_PATH=%BASE_PATH%"

if "%COPY_TO_STAGE_DIR_FILE_PATH%" == "%COPY_TO_STAGE_DIR_BASE_PATH%" (
  echo.%?~nx0%: error: TO_STAGE_DIR_PATH base path can not exist: "%COPY_TO_STAGE_DIR_PATH%"
  exit /b 4
) >&2

call :FILE_PATH "%%COPY_FROM_STAGE_DIR_PATH%%"
set "COPY_FROM_STAGE_DIR_PATH=%FILE_PATH%"

call :FILE_PATH "%%ARCHIVE_FROM_STAGE_DIR_PATH%%"
set "ARCHIVE_FROM_STAGE_DIR_PATH=%FILE_PATH%"

set "ARCHIVE_FILE_PATH=%ARCHIVE_FILE_FILE_PATH%"
set "COPY_TO_STAGE_DIR_PATH=%COPY_TO_STAGE_DIR_FILE_PATH%"

rem <ARCHIVE_DIR_PREFIX_PATH> = <COPY_FROM_STAGE_DIR_PATH> - <ARCHIVE_FROM_STAGE_DIR_PATH>
call "%%TOOLS_PATH%%/get_path_subtract.bat" "%%ARCHIVE_FROM_STAGE_DIR_PATH%%" "%%COPY_FROM_STAGE_DIR_PATH%%"
set "ARCHIVE_DIR_PREFIX_PATH=%RETURN_VALUE%"

call "%%TOOLS_PATH%%/uuidgen.bat"
set "XCOPY_ARCHIVE_EXCLUDE_FILES_FILE=%TEMP%\%?~n0%.%RETURN_VALUE%.txt"

call :DEL_XCOPY_ARCHIVE_EXCLUDE_FILES_FILE || exit /b 10

set "ARCHIVE_STAGE_FILE_PATH_LIST="
set FROM_FILE_INDEX=1
set MSG_PRINTED=0

:CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST
if "%ARCHIVE_FILE_LIST%" == "" set "ARCHIVE_FILE_LIST=*.*"

set "FROM_FILE="
for /F "eol=# tokens=%FROM_FILE_INDEX% delims=:" %%i in ("%ARCHIVE_FILE_LIST%") do set "FROM_FILE=%%i"
if "%FROM_FILE%" == "" goto CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST_END

set /A FROM_FILE_INDEX+=1

set ARCHIVE_STAGE_FILE_PATH_LIST=%ARCHIVE_STAGE_FILE_PATH_LIST% "%COPY_FROM_STAGE_DIR_PATH%/%FROM_FILE%"
(echo.%FROM_FILE:*.=.%)>> "%XCOPY_ARCHIVE_EXCLUDE_FILES_FILE%"

goto CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST

:CONVERT_ARCHIVE_FILE_LIST_TO_PATH_LIST_END

:ARCHIVE_STAGE
call "%%TOOLS_PATH%%/has_dir_files.bat" /S %%ARCHIVE_STAGE_FILE_PATH_LIST%% || goto COPY_STAGE

echo.Archiving %MSG_TOKEN% files into %STAGE_NAME%...

if not exist "%COPY_TO_STAGE_DIR_PATH%" mkdir "%COPY_TO_STAGE_DIR_PATH%"

set FROM_FILE_INDEX=1

:ARCHIVE_FILE_LIST
set "TO_FILE="
for /F "eol=# tokens=%FROM_FILE_INDEX% delims=:" %%i in ("%ARCHIVE_FILE_LIST%") do set "TO_FILE=%%i"
if "%TO_FILE%" == "" goto ARCHIVE_FILE_LIST_END

set /A FROM_FILE_INDEX+=1

if not "%ARCHIVE_DIR_PREFIX_PATH%" == "" (
  call "%%TOOLS_PATH%%/build/add_files_to_archive.bat" "%%ARCHIVE_FROM_STAGE_DIR_PATH%%" "%%ARCHIVE_DIR_PREFIX_PATH%%/%%TO_FILE%%" "%%ARCHIVE_FILE_PATH%%" || ( set LASTERROR=11 & goto EXIT )
) else (
  call "%%TOOLS_PATH%%/build/add_files_to_archive.bat" "%%ARCHIVE_FROM_STAGE_DIR_PATH%%" "%%TO_FILE%%" "%%ARCHIVE_FILE_PATH%%" || ( set LASTERROR=12 & goto EXIT )
)

goto ARCHIVE_FILE_LIST

:ARCHIVE_FILE_LIST_END

echo.

:COPY_STAGE
call "%%TOOLS_PATH%%/build/xcopy_to_stage.bat" "%%MSG_TOKEN%%" "%%STAGE_NAME%%" "%%COPY_FROM_STAGE_DIR_PATH%%" "%%COPY_TO_STAGE_DIR_PATH%%" "%%COPY_FILE_LIST%%" ^
  "%%XCOPY_FILE_FLAGS%%" "" "%%XCOPY_ARCHIVE_EXCLUDE_FILES_FILE%%" || ( set LASTERROR=13 & goto EXIT )

goto :EXIT

:DEL_FILE
call "%%TOOLS_PATH%%/del_file.bat" %%* || goto :EOF
exit /b 0

:FILE_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :FILE_PATH_IMPL "%%~1/."
goto :EOF

:FILE_PATH_IMPL
set "FILE_PATH=%~dpf1"
goto :EOF

:BASE_PATH
rem add /. to the end to suppress trailing slash misinterpretation
call :BASE_PATH_IMPL "%%~1/."
goto :EOF

:BASE_PATH_IMPL
set "BASE_PATH=%~dp1"
goto :EOF

:DEL_XCOPY_ARCHIVE_EXCLUDE_FILES_FILE
if exist "%XCOPY_ARCHIVE_EXCLUDE_FILES_FILE%" ( call :DEL_FILE "%%XCOPY_ARCHIVE_EXCLUDE_FILES_FILE%%" /F /Q /A:-D >nul || exit /b 1 )
exit /b 0

:EXIT
call :DEL_XCOPY_ARCHIVE_EXCLUDE_FILES_FILE
exit /b %LASTERROR%
