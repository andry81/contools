@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive the build stage directories set of a project build
rem   output (basically the last build stage output of previous project in a
rem   build pipeline) into a stage of calling project.
rem   The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stagein_all_dirs.bat ^
rem    "../.." ^
rem    "%%STAGE_IN.PROJECT_STAGE_PDB_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_LIB_PATH%%" "%%PROJECT_STAGE_LIB_PATH%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_GEN_PATH%%" "%%PROJECT_STAGE_GEN_PATH%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_VAR_PATH%%" "%%PROJECT_STAGE_VAR_PATH%%" || exit /b 31

setlocal

set "ARCHIVE_COPY_FROM_OFFSET=%~1"
shift

set "PROJECT_PDB_PATH=%~1"
set "PROJECT_STAGE_PDB_PATH=%~2"
set "PROJECT_LIB_PATH=%~3"
set "PROJECT_STAGE_LIB_PATH=%~4"
set "PROJECT_GEN_PATH=%~5"
set "PROJECT_STAGE_GEN_PATH=%~6"
set "PROJECT_VAR_PATH=%~7"
set "PROJECT_STAGE_VAR_PATH=%~8"

rem Drop last error level
type nul>nul

call "%%~dp0__init__.bat" || goto :EOF

:PDB_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_PDB_PATH%" goto PDB_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "stage-in project debug information" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_PDB_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_PDB_PATH%%/%%STAGE_IN.PROJECT_NAME%%_pdb_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
  "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" || exit /b 1

:PDB_STAGE_END

:LIB_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_LIB_PATH%" goto LIB_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "stage-in project library" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_LIB_PATH%%" "%%PROJECT_STAGE_LIB_PATH%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_LIB_PATH%%/%%STAGE_IN.PROJECT_NAME%%_lib_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.lib.7z" ^
  "*.lib:*.exp" "*.lib.7z" "/S /Y /H" || exit /b 2

:LIB_STAGE_END

:GEN_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_GEN_PATH%" goto GEN_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "stage-in project generated" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_GEN_PATH%%" "%%PROJECT_STAGE_GEN_PATH%%/%%STAGE_IN.PROJECT_NAME%%" "*.*" "/S /Y /H" || exit /b 3

:GEN_STAGE_END

:VAR_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_VAR_PATH%" goto VAR_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "stage-in project variables" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_VAR_PATH%%" "%%PROJECT_STAGE_VAR_PATH%%/%%STAGE_IN.PROJECT_NAME%%" "*.*" "/S /Y /H" || exit /b 4

:VAR_STAGE_END

exit /b 0
