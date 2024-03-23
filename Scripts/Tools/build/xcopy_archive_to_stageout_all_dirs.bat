@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive the build stage directories set of a project build
rem   output (basically the previous build stage output of the same project in
rem   a project build pipeline) into a stage of calling project.
rem   The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stageout_all_dirs.bat "stage" "../.." ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" ^
rem    "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" ^
rem    "@%%PROJECT_ROOT%%\_scripts\stage_bin_excludes.lst" || exit /b 32

setlocal

set "?~dp0=%~dp0"

set "STAGE_NAME=%~1"
set "ARCHIVE_COPY_FROM_OFFSET=%~2"
shift
shift

set "PROJECT_BIN_ROOT=%~1"
set "PROJECT_STAGE_BIN_ROOT=%~2"
set "PROJECT_PDB_ROOT=%~3"
set "PROJECT_STAGE_PDB_ROOT=%~4"
set "PROJECT_LIB_ROOT=%~5"
set "PROJECT_STAGE_LIB_ROOT=%~6"
set "PROJECT_GEN_ROOT=%~7"
set "PROJECT_STAGE_GEN_ROOT=%~8"
shift
shift
set "PROJECT_VAR_ROOT=%~7"
set "PROJECT_STAGE_VAR_ROOT=%~8"
set "PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST=%~9"

call "%%?~dp0%%__init__.bat" || exit /b

:BIN_STAGE
if not exist "%PROJECT_BIN_ROOT%" goto BIN_STAGE_END

if defined PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST set "PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST=%PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST%|"

if %F_ENABLE_STAGE_OUT_TO_ARCHIVE%0 EQU 0 (
  set "PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST=%PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST%@%CONTOOLS_ROOT:/=\%\excludes\xcopy_msvc_debug_info_files.lst"
) else (
  set "PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST=%PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST%@%CONTOOLS_ROOT:/=\%\excludes\7zip_msvc_debug_info_files.lst"
)

if %F_ENABLE_STAGE_OUT_TO_ARCHIVE%0 EQU 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project binaries w/o debug information" "%%STAGE_NAME%%" ^
    "%%PROJECT_BIN_ROOT%%" "%%PROJECT_STAGE_BIN_ROOT%%" "*.*" "/E /Y /H" ^
    "%%PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST%%" || exit /b 1
) else (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project binaries" "%%STAGE_NAME%%" ^
    "%%PROJECT_BIN_ROOT%%" "%%PROJECT_STAGE_BIN_ROOT%%" ^
    "" ^
    "%%PROJECT_STAGE_BIN_ROOT%%/%%PROJECT_NAME%%_bin_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.bin.7z" ^
    "" "*.bin.7z" "/S /Y /H" "%%PROJECT_BIN_ROOT_EXCLUDES_FILE_LIST%%" || exit /b 2
)

:BIN_STAGE_END

:PDB_STAGE
if not exist "%PROJECT_BIN_ROOT%" goto PDB_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project debug information" "%%STAGE_NAME%%" ^
  "%%PROJECT_BIN_ROOT%%" "%%PROJECT_STAGE_PDB_ROOT%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_PDB_ROOT%%/%%PROJECT_NAME%%_pdb_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
  "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" || exit /b 3

if not exist "%PROJECT_PDB_ROOT%" goto PDB_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project debug information" "%%STAGE_NAME%%" ^
  "%%PROJECT_PDB_ROOT%%" "%%PROJECT_STAGE_PDB_ROOT%%" "*.*" "/S /Y /H" || exit /b 4

:PDB_STAGE_END

:LIB_STAGE
if not exist "%PROJECT_LIB_ROOT%" goto LIB_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project library" "%%STAGE_NAME%%" ^
  "%%PROJECT_LIB_ROOT%%" "%%PROJECT_STAGE_LIB_ROOT%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_LIB_ROOT%%/%%PROJECT_NAME%%_lib_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.lib.7z" ^
  "*.lib:*.exp" "*.lib.7z" "/S /Y /H" || exit /b 5

:LIB_STAGE_END

:GEN_STAGE
if not exist "%PROJECT_GEN_ROOT%" goto GEN_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project generated" "%%STAGE_NAME%%" ^
  "%%PROJECT_GEN_ROOT%%" "%%PROJECT_STAGE_GEN_ROOT%%" "*.*" "/S /Y /H" || exit /b 6

:GEN_STAGE_END

:VAR_STAGE
if not exist "%PROJECT_VAR_ROOT%" goto VAR_STAGE_END
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project variables" "%%STAGE_NAME%%" ^
  "%%PROJECT_VAR_ROOT%%" "%%PROJECT_STAGE_VAR_ROOT%%" "*.*" "/S /Y /H" || exit /b 7

:VAR_STAGE_END

exit /b 0
