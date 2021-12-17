@echo off

setlocal

if not defined PROJECT_ROOT (
  echo.%~nx0: error: PROJECT_ROOT is not set.
  exit /b 1
) >&2

if not exist "%PROJECT_ROOT%\" (
  echo.%~nx0: error: path does not exist: PROJECT_ROOT="%PROJECT_ROOT%\".
  exit /b 2
) >&2

rem drop last error level
call;

rem get code page value from first parameter
set "LAST_CODE_PAGE="
set "CODE_PAGE=%~1"
set "NSIS_DEFINES_FILE_LIST=%~2"

shift
shift

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" %%CODE_PAGE%%

rem generate nsis_defines.nsi
echo.; autogenerated list of predefined names
call :DEFINE SOLUTION_BRANCH_ROOT "%%SOLUTION_BRANCH_ROOT%%"
echo.
call :DEFINE PROJECT_NAME "%%PROJECT_NAME%%"
call :DEFINE PROJECT_ROOT "%%PROJECT_ROOT%%"
call :DEFINE PROJECT_TRUNK_ROOT "%%PROJECT_TRUNK_ROOT%%"
call :DEFINE PROJECT_BRANCH_ROOT "%%PROJECT_BRANCH_ROOT%%"
echo.
call :DEFINE BUILD_SCM_BRANCH "%%BUILD_SCM_BRANCH%%"
echo.
call :DEFINE PROJECT_BUILD_DATE "%%PROJECT_BUILD_DATE%%"
call :DEFINE PROJECT_BUILD_TIME "%%PROJECT_BUILD_TIME%%"
echo.
call :DEFINE_NOCHECK APP_BUILD_DATE "%%APP_BUILD_DATE%%"
call :DEFINE_NOCHECK APP_BUILD_TIME "%%APP_BUILD_TIME%%"
echo.
call :DEFINE PROJECT_SRCS_ROOT "%%PROJECT_SRCS_ROOT%%"
call :DEFINE PROJECT_LIBS_ROOT "%%PROJECT_LIBS_ROOT%%"
call :DEFINE PROJECT_INCLUDES_ROOT "%%PROJECT_INCLUDES_ROOT%%"
echo.
call :DEFINE PUBLISH_BUILDS_ROOT "%%PUBLISH_BUILDS_ROOT%%"
call :DEFINE_NOCHECK PUBLISH_APP_ROOT "%%PUBLISH_APP_ROOT%%"
call :DEFINE_NOCHECK PUBLISH_APP_DIR "%%PUBLISH_APP_DIR%%"
call :DEFINE_NOCHECK PUBLISH_APP_DIR_BUILD_TOKEN "%%PUBLISH_APP_DIR_BUILD_TOKEN%%"
call :DEFINE_NOCHECK PUBLISH_APP_DIR_USER_TOKEN "%%PUBLISH_APP_DIR_USER_TOKEN%%"
echo.
call :DEFINE PROJECT_TYPE "%%PROJECT_TYPE%%"
call :DEFINE TARGET_NAME "%%TARGET_NAME%%"
call :DEFINE TARGETS_LIST "%%TARGETS_LIST%%"
call :DEFINE NUM_TARGETS "%%NUM_TARGETS%%"
echo.
call :DEFINE COMPONENTS_LIST "%%COMPONENTS_LIST%%"
echo.
call :DEFINE_NOCHECK PARENT.PRODUCT_VERSION "%%PARENT.PRODUCT_VERSION%%"
rem dump PARENT.PRODUCT_VERSION_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "PARENT.PRODUCT_VERSION_" 2^>nul`) do call :DEFINE "%%i" "%%j"
call :DEFINE_NOCHECK PARENT.BUILD_NUMBER "%%PARENT.BUILD_NUMBER%%"
call :DEFINE_NOCHECK PARENT.BUILD_NUMBER_VERSION_SUFFIX "%%PARENT.BUILD_NUMBER_VERSION_SUFFIX%%"
echo.
call :DEFINE PRODUCT_VERSION "%%PRODUCT_VERSION%%"
rem dump PRODUCT_VERSION_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "PRODUCT_VERSION_" 2^>nul`) do call :DEFINE "%%i" "%%j"
call :DEFINE_NOCHECK BUILD_NUMBER "%%BUILD_NUMBER%%"
call :DEFINE_NOCHECK BUILD_NUMBER_VERSION_SUFFIX "%%BUILD_NUMBER_VERSION_SUFFIX%%"
echo.

if not defined APP_TARGETS_LIST goto APP_TARGETS_LIST_END

rem dump variables with <app_target_name> as part of name
for %%i in (%APP_TARGETS_LIST%) do call :TARGET_APP_LIST_HANDLER %%%%i
echo.
goto APP_TARGETS_LIST_END

:TARGET_APP_LIST_HANDLER
setlocal
set "APP_TARGET_NAME_=%~1"
call set "TARGETS_LIST_=%%%APP_TARGET_NAME_%.TARGETS_LIST%%"
call set "NUM_TARGETS_=%%%APP_TARGET_NAME_%.NUM_TARGETS%%"
call :DEFINE %%APP_TARGET_NAME_%%.TARGETS_LIST "%%TARGETS_LIST_%%"
call :DEFINE %%APP_TARGET_NAME_%%.NUM_TARGETS "%%NUM_TARGETS_%%"
exit /b 0

:APP_TARGETS_LIST_END

call :DEFINE APP_TARGET_NAME "%%APP_TARGET_NAME%%"
call :DEFINE APP_TARGETS_LIST "%%APP_TARGETS_LIST%%"
call :DEFINE NUM_APP_TARGETS "%%NUM_APP_TARGETS%%"
echo.
call :DEFINE APP_ROOT "%%APP_ROOT%%"
call :DEFINE APP_DIR "%%APP_DIR%%"
echo.

call :DEFINE "PRODUCT_APP_DIR" "%%PRODUCT_APP_DIR%%"
call :DEFINE "APP_TITLE_FILE_NAME" "%%APP_TITLE_FILE_NAME%%"
call :DEFINE "APP_SETUP_FILE_NAME" "%%APP_SETUP_FILE_NAME%%"
echo.

rem dump APP_INTEGRATION_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "APP_INTEGRATION_" 2^>nul`) do call :DEFINE "%%i" "%%j"
echo.

rem dump F_ENABLE_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "F_ENABLE_" 2^>nul`) do call :DEFINE "%%i" "%%j"
echo.

rem dump F_DISABLE_* variables
for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "F_DISABLE_" 2^>nul`) do call :DEFINE "%%i" "%%j"
echo.

if not exist "%NSIS_DEFINES_FILE_LIST%" goto GEN_BY_LIST_END

echo.; autogenerated list from nsis_defines.lst

rem dump F_ENABLE_* variables
for /F "usebackq eol= tokens=* delims=" %%i in ("%NSIS_DEFINES_FILE_LIST%") do (
  set "__VAR_NAME=%%i"
  call :DEFINE_BY_VAR_NAME
)
echo.

:GEN_BY_LIST_END

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

exit /b 0

:DEFINE_BY_VAR_NAME
call :DEFINE "%%__VAR_NAME%%" "%%%__VAR_NAME%%%"
exit /b

:DEFINE
rem define ONLY if not empty
if not "%~2" == "" echo.!define %~1 "%~2"
exit /b

:DEFINE_NOCHECK
rem always define even if not empty
echo.!define %~1 "%~2"
exit /b
