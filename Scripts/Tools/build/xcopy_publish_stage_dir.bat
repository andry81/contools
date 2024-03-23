@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy (publish) a single build stage directory from multiple
rem   projects into one output directory.

rem Examples:
rem 1. call xcopy_publish_stage_dir.bat ^
rem    "%%MYPROJECT1.PROJECT_STAGE_POSTBUILD_ROOT%%/pdb/%%MYPROJECT1.APP_TARGET_NAME%%/%%MYPROJECT1.PROJECT_TYPE%%|%%MYPROJECT2.PROJECT_STAGE_POSTBUILD_ROOT%%/pdb/%%MYPROJECT2.APP_TARGET_NAME%%/%%MYPROJECT2.PROJECT_TYPE%%" ^
rem    "%%PROJECT_STAGE_POSTBUILD_BASE_ROOT%%" "%%MYPROJECT.PUBLISH_APP_STAGE_ROOT%%/%%MYPROJECT.PUBLISH_APP_DIR%%" "/S /Y" || exit /b 22

setlocal

set "?~dp0=%~dp0"

set "PUBLISH_STAGE_ROOT_LIST=%~1"
set "FROM_BASE_ROOT=%~2"
set "TO_APP_DIR_ROOT=%~3"
set "XCOPY_FLAGS=%~4"

call "%%?~dp0%%__init__.bat" || exit /b

set PATH_INDEX=1

:PUBLISH_XCOPY_STAGE_ROOT_LOOP
set PUBLISH_STAGE_ROOT=
for /F "eol= tokens=%PATH_INDEX% delims=|" %%i in ("%PUBLISH_STAGE_ROOT_LIST%") do set "PUBLISH_STAGE_ROOT=%%i"
if not defined PUBLISH_STAGE_ROOT goto PUBLISH_XCOPY_STAGE_ROOT_LOOP_END

call :PUBLISH_XCOPY "%%PUBLISH_STAGE_ROOT%%" "%%FROM_BASE_ROOT%%" "%%TO_APP_DIR_ROOT%%" || exit /b 1

set /A PATH_INDEX+=1

goto PUBLISH_XCOPY_STAGE_ROOT_LOOP

:PUBLISH_XCOPY_STAGE_ROOT_LOOP_END

exit /b 0

:PUBLISH_XCOPY
setlocal

set "FROM_DIR_ROOT=%~1"
set "FROM_BASE_ROOT=%~2"
set "TO_APP_DIR_ROOT=%~3"

rem <XCOPY_SUFFIX_PATH> = <FROM_DIR_ROOT> - <FROM_BASE_ROOT>
call "%%CONTOOLS_ROOT%%/filesys/subtract_path.bat" "%%FROM_BASE_ROOT%%" "%%FROM_DIR_ROOT%%"
set "XCOPY_SUFFIX_PATH=%RETURN_VALUE:\=/%"

if defined XCOPY_SUFFIX_PATH (
  if exist "%FROM_DIR_ROOT%" (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%FROM_DIR_ROOT%%" "%%TO_APP_DIR_ROOT%%/%%XCOPY_SUFFIX_PATH%%" %%XCOPY_FLAGS%% || exit /b 1
  )
) else (
  if exist "%FROM_DIR_ROOT%" (
    call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%FROM_DIR_ROOT%%" "%%TO_APP_DIR_ROOT%%" %%XCOPY_FLAGS%% || exit /b 2
  )
)

exit /b
