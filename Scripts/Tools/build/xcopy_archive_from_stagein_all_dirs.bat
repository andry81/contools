@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive the build stage directories set of a project build
rem   output (basically the last build stage output of previous project in a
rem   build pipeline) into a stage of calling project.
rem   The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stagein_all_dirs.bat "../.." ^
rem    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" ^
rem    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" || exit /b

setlocal

set "?~dp0=%~dp0"

set "ARCHIVE_COPY_FROM_OFFSET=%~1"
shift

set "PROJECT_PDB_ROOT=%~1"
set "PROJECT_STAGE_PDB_ROOT=%~2"
set "PROJECT_LIB_ROOT=%~3"
set "PROJECT_STAGE_LIB_ROOT=%~4"
set "PROJECT_GEN_ROOT=%~5"
set "PROJECT_STAGE_GEN_ROOT=%~6"
set "PROJECT_VAR_ROOT=%~7"
set "PROJECT_STAGE_VAR_ROOT=%~8"

call "%%?~dp0%%__init__.bat" || exit /b

:PDB_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%" goto PDB_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "stage-in project debug information" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" "%%PROJECT_STAGE_PDB_ROOT%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_PDB_ROOT%%/%%STAGE_IN.PROJECT_NAME%%_pdb_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
  "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" || exit /b 1

:PDB_STAGE_END

:LIB_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%" goto LIB_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "stage-in project library" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" "%%PROJECT_STAGE_LIB_ROOT%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_LIB_ROOT%%/%%STAGE_IN.PROJECT_NAME%%_lib_%%STAGE_IN.BUILD_SCM_BRANCH%%_%%STAGE_IN.PROJECT_TYPE%%_%%STAGE_IN.APP_TARGET_NAME%%_v%%STAGE_IN.PRODUCT_VERSION_FILE_SUFFIX%%.lib.7z" ^
  "*.lib:*.exp" "*.lib.7z" "/S /Y /H" || exit /b 2

:LIB_STAGE_END

:GEN_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%" goto GEN_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "stage-in project generated" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" "%%PROJECT_STAGE_GEN_ROOT%%/%%STAGE_IN.PROJECT_NAME%%" "*.*" "/S /Y /H" || exit /b 3

:GEN_STAGE_END

:VAR_STAGE
if not exist "%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%" goto VAR_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "stage-in project variables" "stage" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_VAR_ROOT%%/%%STAGE_IN.PROJECT_NAME%%" "*.*" "/S /Y /H" || exit /b 4

:VAR_STAGE_END

exit /b 0
