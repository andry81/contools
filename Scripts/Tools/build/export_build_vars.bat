@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to export common project environment variables into the file to
rem   import them later in another project in the build pipeline.

rem Examples:
rem 1. call export_build_vars.bat c:\_b\MyProject\build\vars\build.vars

setlocal

set "EXPORT_VARS_FILE=%~1"

call "%%~dp0__init__.bat" || exit /b

call :WRITE_VAR_FILE SOLUTION_BRANCH_ROOT           "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_NAME                   "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_ROOT                   "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_TRUNK_ROOT             "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_BRANCH_ROOT            "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE BUILD_SCM_BRANCH               "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_BUILD_DATE             "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_BUILD_TIME             "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE APP_BUILD_DATE                 "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE APP_BUILD_TIME                 "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE BUILD_DEV_COMPILER             "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE BUILD_DEV_COMPILER_DIR         "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE BUILD_DEV_ADDRESS_MODEL        "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_SRCS_ROOT              "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_LIBS_ROOT              "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_INCLUDES_ROOT          "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT       "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT   "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.BIN_DIR     "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.PDB_DIR     "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.LIB_DIR     "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.GEN_DIR     "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_BUILD_ROOT.VAR_DIR     "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PUBLISH_BUILDS_ROOT            "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PUBLISH_APP_ROOT               "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PUBLISH_APP_DIR                "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PUBLISH_APP_DIR_BUILD_TOKEN    "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PUBLISH_APP_DIR_USER_TOKEN     "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE APP_ROOT                       "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE APP_DIR                        "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE APP_TARGET_NAME                "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE TARGET_NAME                    "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PROJECT_TYPE                   "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PARENT.PRODUCT_VERSION         "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PARENT.BUILD_NUMBER            "%%EXPORT_VARS_FILE%%" || exit /b

call :WRITE_VAR_FILE PRODUCT_VERSION                "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE PRODUCT_VERSION_FILE_SUFFIX    "%%EXPORT_VARS_FILE%%" || exit /b
call :WRITE_VAR_FILE BUILD_NUMBER                   "%%EXPORT_VARS_FILE%%" || exit /b

for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "F_DISABLE_" 2^>nul`) do (
  call :WRITE_VAR_FILE "%%i" "%%EXPORT_VARS_FILE%%" || exit /b
)

for /F "usebackq eol= tokens=1,* delims==" %%i in (`@set "F_ENABLE_" 2^>nul`) do (
  call :WRITE_VAR_FILE "%%i" "%%EXPORT_VARS_FILE%%" || exit /b
)

exit /b 0

:WRITE_VAR_FILE
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/write_var_to_file.bat" %%* || exit /b
exit /b 0
