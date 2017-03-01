@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to export common project environment variables into the file to
rem   import them later in another project in the build pipeline.

rem Examples:
rem 1. call export_build_vars.bat c:\_b\MyProject\build\vars\build.vars

setlocal

set "EXPORT_VARS_FILE=%~1"

rem Drop last error level
cd .

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

call :WRITE_VAR_FILE PROJECT_NAME                   "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_BRANCH_PATH            "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_TRUNK_PATH             "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE APP_BUILD_DATE                 "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE APP_BUILD_TIME                 "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PROJECT_BUILD_DATE             "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_BUILD_TIME             "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE SOURCES_BASE_PATH              "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE SOURCES_ROOT_BRANCH_PATH       "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE BUILD_SCM_BRANCH               "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PUBLISH_BUILDS_ROOT            "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PUBLISH_APP_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PUBLISH_APP_DIR                "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PUBLISH_APP_DIR_BUILD_TOKEN    "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PUBLISH_APP_DIR_USER_TOKEN     "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PROJECT_BUILD_BUILD_PATH       "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_BUILD_STAGE_PATH       "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_BUILD_PATH             "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PROJECT_BIN_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_PDB_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_LIB_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_GEN_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_VAR_PATH               "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_STAGE_BIN_PATH         "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_STAGE_PDB_PATH         "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_STAGE_LIB_PATH         "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_STAGE_GEN_PATH         "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PROJECT_STAGE_VAR_PATH         "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PROJECT_TYPE                   "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE TARGET_NAME                    "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE APP_TARGET_NAME                "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PARENT.PRODUCT_VERSION         "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PARENT.BUILD_NUMBER            "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE PRODUCT_VERSION                "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE PRODUCT_VERSION_FILE_SUFFIX    "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE BUILD_NUMBER                   "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE APP_PATH                       "%%EXPORT_VARS_FILE%%" || goto :EOF
call :WRITE_VAR_FILE APP_DIR                        "%%EXPORT_VARS_FILE%%" || goto :EOF

call :WRITE_VAR_FILE F_ENABLE_STAGE_OUT_TO_ARCHIVE  "%%EXPORT_VARS_FILE%%" || goto :EOF

exit /b 0

:WRITE_VAR_FILE
call "%%TOOLS_PATH%%/build/write_var_to_file.bat" %%* || goto :EOF
exit /b 0
