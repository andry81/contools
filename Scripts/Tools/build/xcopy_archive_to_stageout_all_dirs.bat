@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to copy/archive the build stage directories set of a project build
rem   output (basically the previous build stage output of the same project in
rem   a project build pipeline) into a stage of calling project.
rem   The copy performs file filtering and archiving by pattern.

rem Examples:
rem 1. call xcopy_archive_to_stageout_all_dirs.bat ^
rem    "stage" "../.." ^
rem    "%%PROJECT_BIN_PATH%%" "%%PROJECT_STAGE_BIN_PATH%%" "%%PROJECT_PATH%%\_scripts\stage_bin_excludes.lst" ^
rem    "%%PROJECT_PDB_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" ^
rem    "%%PROJECT_LIB_PATH%%" "%%PROJECT_STAGE_LIB_PATH%%" ^
rem    "%%PROJECT_GEN_PATH%%" "%%PROJECT_STAGE_GEN_PATH%%" ^
rem    "%%PROJECT_VAR_PATH%%" "%%PROJECT_STAGE_VAR_PATH%%" || exit /b 32

setlocal

set "STAGE_NAME=%~1"
set "ARCHIVE_COPY_FROM_OFFSET=%~2"
shift
shift

set "PROJECT_BIN_PATH=%~1"
set "PROJECT_STAGE_BIN_PATH=%~2"
set "PROJECT_BIN_PATH_XCOPY_EXCLUDE_DIRS_FILE=%~3"
set "PROJECT_PDB_PATH=%~4"
set "PROJECT_STAGE_PDB_PATH=%~5"
set "PROJECT_LIB_PATH=%~6"
set "PROJECT_STAGE_LIB_PATH=%~7"
set "PROJECT_GEN_PATH=%~8"
set "PROJECT_STAGE_GEN_PATH=%~9"
shift
shift
set "PROJECT_VAR_PATH=%~8"
set "PROJECT_STAGE_VAR_PATH=%~9"

rem Drop last error level
type nul>nul

call "%%~dp0__init__.bat" || goto :EOF

:BIN_STAGE
if not exist "%PROJECT_BIN_PATH%" goto BIN_STAGE_END

if %F_ENABLE_STAGE_OUT_TO_ARCHIVE%0 EQU 0 (
  call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project binaries w/o debug information" "%%STAGE_NAME%%" ^
    "%%PROJECT_BIN_PATH%%" "%%PROJECT_STAGE_BIN_PATH%%" "*.*" "/E /Y /H" ^
    "%%PROJECT_BIN_PATH_XCOPY_EXCLUDE_DIRS_FILE%%" ^
    "%%CONTOOLS_ROOT:/=\%%\excludes\xcopy_msvc_debug_info_files.lst" || exit /b 1
) else (
  call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project binaries" "%%STAGE_NAME%%" ^
    "%%PROJECT_BIN_PATH%%" "%%PROJECT_STAGE_BIN_PATH%%" ^
    "" ^
    "%%PROJECT_STAGE_BIN_PATH%%/%%PROJECT_NAME%%_bin_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.bin.7z" ^
    "" "*.bin.7z" "/S /Y /H" || exit /b 2
)

:BIN_STAGE_END

:PDB_STAGE
if not exist "%PROJECT_BIN_PATH%" goto PDB_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project debug information" "%%STAGE_NAME%%" ^
  "%%PROJECT_BIN_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_PDB_PATH%%/%%PROJECT_NAME%%_pdb_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.pdb.7z" ^
  "*.pdb:*.ilk:*.map" "*.pdb.7z" "/S /Y /H" || exit /b 3

if not exist "%PROJECT_PDB_PATH%" goto PDB_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project debug information" "%%STAGE_NAME%%" ^
  "%%PROJECT_PDB_PATH%%" "%%PROJECT_STAGE_PDB_PATH%%" "*.*" "/S /Y /H" || exit /b 4

:PDB_STAGE_END

:LIB_STAGE
if not exist "%PROJECT_LIB_PATH%" goto LIB_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stage.bat" "project library" "%%STAGE_NAME%%" ^
  "%%PROJECT_LIB_PATH%%" "%%PROJECT_STAGE_LIB_PATH%%" ^
  "%%ARCHIVE_COPY_FROM_OFFSET%%" ^
  "%%PROJECT_STAGE_LIB_PATH%%/%%PROJECT_NAME%%_lib_%%BUILD_SCM_BRANCH%%_%%PROJECT_TYPE%%_%%APP_TARGET_NAME%%_v%%PRODUCT_VERSION_FILE_SUFFIX%%.lib.7z" ^
  "*.lib:*.exp" "*.lib.7z" "/S /Y /H" || exit /b 5

:LIB_STAGE_END

:GEN_STAGE
if not exist "%PROJECT_GEN_PATH%" goto GEN_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project generated" "%%STAGE_NAME%%" ^
  "%%PROJECT_GEN_PATH%%" "%%PROJECT_STAGE_GEN_PATH%%" "*.*" "/S /Y /H" || exit /b 6

:GEN_STAGE_END

:VAR_STAGE
if not exist "%PROJECT_VAR_PATH%" goto VAR_STAGE_END
call "%%BUILD_TOOLS_ROOT%%/xcopy_to_stage.bat" "project variables" "%%STAGE_NAME%%" ^
  "%%PROJECT_VAR_PATH%%" "%%PROJECT_STAGE_VAR_PATH%%" "*.*" "/S /Y /H" || exit /b 7

:VAR_STAGE_END

exit /b 0
