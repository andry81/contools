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

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/set_project_build_time.bat"

if exist "%BUILD_SCRIPTS_ROOT%/pre_validate_vars.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/pre_validate_vars.bat" || exit /b 10
) else call "%%~dp0project_directory_pre_validate_vars.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 || exit /b 10

if %F_DISABLE_PRE_BUILD%0 EQU 0 ( call "%%BUILD_SCRIPTS_ROOT%%/pre_build.bat" || exit /b 11 )

rem safe title call
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("build %PROJECT_NAME% %BUILD_SCM_BRANCH% %PROJECT_TYPE% %APP_TARGET_NAME% %TARGET_NAME%") do (
  endlocal
  title %%i
)

echo.Build started: %PROJECT_BUILD_DATE% - %PROJECT_BUILD_TIME%

call "%%BUILD_SCRIPTS_ROOT%%/post_validate_vars.bat" || exit /b 12

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/lock_mutex.bat" %PROJECT_LOCK_TOKEN%_build
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_build_start
)

if %FLAGS_REBUILD%0 EQU 10 (
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BUILD_DIR: "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.CACHE_DIR: "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BIN_DIR: "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.PDB_DIR: "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.LIB_DIR: "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.GEN_DIR: "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.VAR_DIR: "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%" >nul

  rem delete only if declared, because not all projects may has cmake as nested builder
  if defined PROJECT_CMAKE_BUILD_ROOT (
    echo Deleting PROJECT_CMAKE_BUILD_ROOT: "%PROJECT_CMAKE_BUILD_ROOT%"
    rmdir /S /Q "%PROJECT_CMAKE_BUILD_ROOT%" >nul
  )
  if defined PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR (
    echo Deleting PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR: "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%"
    rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%" >nul
  )
)

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" || exit /b

echo.

exit /b 0
