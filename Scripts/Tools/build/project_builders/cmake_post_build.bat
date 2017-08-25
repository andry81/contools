@echo off

set "BUILD_CONFIG_ROOT=%~1"
set "BUILD_SCRIPTS_ROOT=%~2"
set "BUILD_USER_VARS_ROOT=%~3"

if defined BUILD_CONFIG_ROOT (
  if "\" == "%BUILD_CONFIG_ROOT:~0,1%" exit /b 1
  if "\" == "%BUILD_CONFIG_ROOT:~-1%" set "BUILD_CONFIG_ROOT=%BUILD_CONFIG_ROOT:~0,-1%"
)

if not defined BUILD_CONFIG_ROOT (
  echo.%~nx0: error: BUILD_CONFIG_ROOT must be defined.
  exit /b 1
) >&2

if defined BUILD_SCRIPTS_ROOT (
  if "\" == "%BUILD_SCRIPTS_ROOT:~0,1%" exit /b 2
  if "\" == "%BUILD_SCRIPTS_ROOT:~-1%" set "BUILD_SCRIPTS_ROOT=%BUILD_SCRIPTS_ROOT:~0,-1%"
)

if not defined BUILD_SCRIPTS_ROOT (
  echo.%~nx0: error: BUILD_SCRIPTS_ROOT must be defined.
  exit /b 2
) >&2

if defined BUILD_USER_VARS_ROOT (
  if "\" == "%BUILD_USER_VARS_ROOT:~0,1%" exit /b 3
  if "\" == "%BUILD_USER_VARS_ROOT:~-1%" set "BUILD_USER_VARS_ROOT=%BUILD_USER_VARS_ROOT:~0,-1%"
)

if defined UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR if exist "%UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%/post_build.vars" (
  rem load staged out project build variables as stage in
  call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%/post_build.vars" "" STAGE_IN. || exit /b 10
)

rem load build generated variables
call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%/build.vars" "" || exit /b 11

call "%%BUILD_SCRIPTS_ROOT%%/pre_validate_vars.bat" || exit /b 12

rem load user post variables
call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%BUILD_USER_VARS_ROOT%%/setup.user.post.vars" || exit /b 13

title postbuild %PROJECT_NAME% %BUILD_SCM_BRANCH% %PROJECT_TYPE% %APP_TARGET_NAME% %TARGET_NAME%

echo.%~nx0: %PROJECT_NAME%: Executing post build step...
echo.

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/lock_mutex.bat" %PROJECT_LOCK_TOKEN%_post_build
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_post_build_start
)

echo Deleting PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR: "%PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%"
rmdir /S /Q "%PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%" > nul
echo Deleting PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR: "%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%"
rmdir /S /Q "%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%" > nul
echo Deleting PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR: "%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%"
rmdir /S /Q "%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%" > nul
echo Deleting PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR: "%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%"
rmdir /S /Q "%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%" > nul
echo Deleting PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR: "%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%"
rmdir /S /Q "%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%" > nul

echo.

rem read product version
if exist "%BUILD_SCRIPTS_ROOT%/read_product_ver.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/read_product_ver.bat" || exit /b 30
)

echo.

rem user post build
if exist "%BUILD_SCRIPTS_ROOT%/post_build.user.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/post_build.user.bat" || exit /b 22
  echo.
)

call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_from_stagein_all_dirs.bat" "../.." ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" ^
  "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" || exit /b 31

set "STAGE_BIN_EXCLUDES_FILE_LIST="
set "STAGE_BIN_EXCLUDES_FILE=%BUILD_CONFIG_ROOT%\stage_bin_excludes.lst"
if exist "%STAGE_BIN_EXCLUDES_FILE%" set "STAGE_BIN_EXCLUDES_FILE_LIST=@%STAGE_BIN_EXCLUDES_FILE%"

call "%%BUILD_TOOLS_ROOT%%/xcopy_archive_to_stageout_all_dirs.bat" "stage" "../.." ^
  "%%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" ^
  "%%STAGE_BIN_EXCLUDES_FILE_LIST%%" || exit /b 32

rem saving data for next build step into stage directory
echo.Exporting build variables into stage...
if not exist "%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%" call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%"
call "%%BUILD_TOOLS_ROOT%%/export_build_vars.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%\post_build.vars" || exit /b 33
echo.

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_post_build
)

exit /b 0
