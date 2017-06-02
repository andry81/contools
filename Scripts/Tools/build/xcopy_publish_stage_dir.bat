@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy (publish) a single build stage directory from multiple
rem   projects into one output directory.

rem Examples:
rem 1. call xcopy_publish_stage_dir.bat ^
rem    "%%MYPROJECT1.STAGE_PATH%%/pdb/%%MYPROJECT1.APP_TARGET_NAME%%/%%MYPROJECT1.PROJECT_TYPE%%|%%MYPROJECT2.STAGE_PATH%%/pdb/%%MYPROJECT2.APP_TARGET_NAME%%/%%MYPROJECT2.PROJECT_TYPE%%" ^
rem    "%%PROJECT_STAGE_BASE_PATH%%" "%%MYPROJECT.PUBLISH_APP_STAGE_PATH%%/%%MYPROJECT.PUBLISH_APP_DIR%%" "/S /Y" || exit /b 22

setlocal

set "PUBLISH_STAGE_PATH_LIST=%~1"
set "FROM_BASE_PATH=%~2"
set "TO_APP_DIR_PATH=%~3"
set "XCOPY_FLAGS=%~4"

rem Drop last error level
cd .

call "%%~dp0__init__.bat" || goto :EOF

set PATH_INDEX=1

:PUBLISH_XCOPY_STAGE_PATH_LOOP
set PUBLISH_STAGE_PATH=
for /F "eol=	 tokens=%PATH_INDEX% delims=|" %%i in ("%PUBLISH_STAGE_PATH_LIST%") do set "PUBLISH_STAGE_PATH=%%i"
if "%PUBLISH_STAGE_PATH%" == "" goto PUBLISH_XCOPY_STAGE_PATH_LOOP_END

call :PUBLISH_XCOPY "%%PUBLISH_STAGE_PATH%%" "%%FROM_BASE_PATH%%" "%%TO_APP_DIR_PATH%%" || exit /b 1

set /A PATH_INDEX+=1

goto PUBLISH_XCOPY_STAGE_PATH_LOOP

:PUBLISH_XCOPY_STAGE_PATH_LOOP_END

exit /b 0

:PUBLISH_XCOPY
setlocal

set "FROM_DIR_PATH=%~1"
set "FROM_BASE_PATH=%~2"
set "TO_APP_DIR_PATH=%~3"

rem <XCOPY_SUFFIX_PATH> = <FROM_DIR_PATH> - <FROM_BASE_PATH>
call "%%CONTOOLS_ROOT%%/get_path_subtract.bat" "%%FROM_BASE_PATH%%" "%%FROM_DIR_PATH%%"
set "XCOPY_SUFFIX_PATH=%RETURN_VALUE:\=/%"

if not "%XCOPY_SUFFIX_PATH%" == "" (
  if exist "%FROM_DIR_PATH%" (
    mkdir "%TO_APP_DIR_PATH%/%XCOPY_SUFFIX_PATH%"
    call :XCOPY_DIR "%%FROM_DIR_PATH%%" "%%TO_APP_DIR_PATH%%/%%XCOPY_SUFFIX_PATH%%" %%XCOPY_FLAGS%% || exit /b 1
  )
) else (
  if exist "%FROM_DIR_PATH%" (
    mkdir "%TO_APP_DIR_PATH%"
    call :XCOPY_DIR "%%FROM_DIR_PATH%%" "%%TO_APP_DIR_PATH%%" %%XCOPY_FLAGS%% || exit /b 2
  )
)

goto :EOF

:XCOPY_DIR
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" %%* || goto :EOF
exit /b 0
