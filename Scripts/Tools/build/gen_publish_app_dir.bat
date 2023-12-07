@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script returns a project publish directory name consisting of input
rem   arguments.

rem Command arguments:
rem %1 - Prefix name for PUBLISH_APP_DIR variable for return (MY_PROJECT.).
rem %2 - Date of publish.
rem %3 - Time of publish.
rem %4 - Name of project which build is publishing (my_project).
rem %5 - Name of branch with sources that has been built (current/stable/custom/etc).
rem %6 - Type of project which has been built (release/debug).
rem %7 - Application target name which has been built
rem      (internal application featured target name).
rem %8 - File suffix of product version (1_0_0_0)
rem %9 - Product build number, for example, from build server. Can be empty.
rem %10 - User token to be in project publish directory name at the end.
rem %11 - Build token to be in project publish directory name at the end.

rem Examples:
rem 1. call gen_publish_app_dir.bat MY_PROJECT. 2016_05_10 23_59_59 my_project current release full 1_0_0_0 10

setlocal

set "?~dp0=%~dp0"

set "PUBLISH_APP_DIR_VAR_PREFIX=%~1"
rem PUBLISH_DATE/PUBLISH_TIME should be in filename compatible form
set "PUBLISH_DATE=%~2"
set "PUBLISH_TIME=%~3"

set "PROJECT_NAME=%~4"
set "BUILD_BRANCH_NAME=%~5"
set "PROJECT_TYPE=%~6"
set "APP_TARGET_NAME=%~7"
set "PRODUCT_VERSION_FILE_SUFFIX=%~8"
set "PRODUCT_BUILD_NUMBER=%~9"
shift
shift
set "PUBLISH_APP_DIR_USER_TOKEN=%~8"
set "PUBLISH_APP_DIR_BUILD_TOKEN=%~9"

call set "PUBLISH_APP_DIR_VALUE=%%%PUBLISH_APP_DIR_VAR_PREFIX%PUBLISH_APP_DIR%%"

if defined PUBLISH_APP_DIR_VALUE exit /b 0

call "%%?~dp0%%__init__.bat" || exit /b

call "%%CONTOOLS_WMI_ROOT%%\get_wmic_local_datetime.bat"
if not defined PUBLISH_DATE set "PUBLISH_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
if not defined PUBLISH_TIME set "PUBLISH_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

if not defined PUBLISH_APP_DIR goto GEN_PUBLISH_APP_DIR
goto PUBLISH

:GEN_PUBLISH_APP_DIR
set "DATE_TIME=%PUBLISH_DATE%!%PUBLISH_TIME%"

if defined PUBLISH_APP_DIR_BUILD_TOKEN (
  set "PUBLISH_APP_DIR_BUILD_TOKEN=!%PUBLISH_APP_DIR_BUILD_TOKEN%"
  if defined PUBLISH_APP_DIR_USER_TOKEN set "PUBLISH_APP_DIR_USER_TOKEN=!%PUBLISH_APP_DIR_USER_TOKEN%"
) else (
  if defined PUBLISH_APP_DIR_USER_TOKEN set "PUBLISH_APP_DIR_USER_TOKEN=!!%PUBLISH_APP_DIR_USER_TOKEN%"
)

if defined PRODUCT_BUILD_NUMBER (
  set "PRODUCT_VERSION_FILE_SUFFIX=%PRODUCT_VERSION_FILE_SUFFIX%!b%PRODUCT_BUILD_NUMBER%"
)

set "APP_TARGET_DESC=%PROJECT_TYPE%"
if not defined APP_TARGET_NAME goto IGNORE_APP_TARGET_NAME

rem set APP_TARGET_NAME to upper case for more readability
call "%%CONTOOLS_ROOT%%/strupcase.bat" /v APP_TARGET_NAME
set "APP_TARGET_NAME=%RETURN_VALUE%"
set "APP_TARGET_DESC=%APP_TARGET_NAME%_%PROJECT_TYPE%"

:IGNORE_APP_TARGET_NAME
set "PUBLISH_APP_DIR=%PROJECT_NAME%_%BUILD_SCM_BRANCH%_%PRODUCT_VERSION_FILE_SUFFIX%!%DATE_TIME%!%APP_TARGET_DESC%%PUBLISH_APP_DIR_BUILD_TOKEN%%PUBLISH_APP_DIR_USER_TOKEN%"

(
  endlocal
  set "%PUBLISH_APP_DIR_VAR_PREFIX%PUBLISH_APP_DIR=%PUBLISH_APP_DIR%"
)

exit /b
