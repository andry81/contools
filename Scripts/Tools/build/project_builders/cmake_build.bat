@echo off

setlocal

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

if defined BUILD_NEST_LVL set /A BUILD_NEST_LVL+=1
if not defined BUILD_NEST_LVL set BUILD_NEST_LVL=1

call "%%BUILD_TOOLS_ROOT%%/set_project_build_time.bat"
call "%%BUILD_TOOLS_ROOT%%/env_generators\base.bat" || exit /b 10
call "%%BUILD_TOOLS_ROOT%%/env_generators\cmake.bat" || exit /b 11
call "%%BUILD_TOOLS_ROOT%%/env_generators\cmake_cmd_line.bat" "%%BUILD_CONFIG_ROOT%%" || exit /b 12

if exist "%BUILD_SCRIPTS_ROOT%/pre_validate_vars.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/pre_validate_vars.bat" || exit /b 13
) else call "%%~dp0cmake_pre_validate_vars.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 || exit /b 13

if %F_DISABLE_PRE_BUILD%0 EQU 0 ( call "%%BUILD_SCRIPTS_ROOT%%/pre_build.bat" || exit /b 14 )

rem safe title call
setlocal DISABLEDELAYEDEXPANSION
for /F "eol=	 tokens=* delims=" %%i in ("build %PROJECT_NAME% %BUILD_SCM_BRANCH% %PROJECT_TYPE% %APP_TARGET_NAME% %TARGET_NAME%") do (
  endlocal
  title %%i
)

echo.Build started: %PROJECT_BUILD_DATE% - %PROJECT_BUILD_TIME%

call "%%BUILD_SCRIPTS_ROOT%%/post_validate_vars.bat" || exit /b 15

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/lock_mutex.bat" %PROJECT_LOCK_TOKEN%_build
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_build_start
)

if %FLAGS_REBUILD%0 EQU 10 (
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BUILD_DIR: "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.CACHE_DIR: "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BIN_DIR: "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.PDB_DIR: "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.LIB_DIR: "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.GEN_DIR: "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%" > nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.VAR_DIR: "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%" > nul

  rem delete only if declared, because not all projects may has cmake as nested builder
  if defined PROJECT_CMAKE_BUILD_ROOT (
    echo Deleting PROJECT_CMAKE_BUILD_ROOT: "%PROJECT_CMAKE_BUILD_ROOT%"
    rmdir /S /Q "%PROJECT_CMAKE_BUILD_ROOT%" > nul
  )
  if defined PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR (
    echo Deleting PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR: "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%"
    rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%" > nul
  )
)

if not exist "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%" ( call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%%" || exit /b 20 )
if not exist "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%" ( call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%%" || exit /b 21 )
if not exist "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%" ( call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" || exit /b 22 )
if not exist "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%" ( call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" || exit /b 23 )

if defined PROJECT_CMAKE_BUILD_ROOT (
  if not exist "%PROJECT_CMAKE_BUILD_ROOT%" call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_CMAKE_BUILD_ROOT%%"
)
if defined PROJECT_CMAKE_INSTALL_ROOT (
  if not exist "%PROJECT_CMAKE_INSTALL_ROOT%" call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%PROJECT_CMAKE_INSTALL_ROOT%%"
)

echo.

pushd "%PROJECT_CMAKE_BUILD_ROOT%" || exit /b 30

rem cmake configure
call :CMD cmake "%%PROJECT_CMAKE_LIST_ROOT%%" %%CMAKE_CMD_LINE.CONFIGURE%%
set LASTERROR=%ERRORLEVEL%
popd

if %LASTERROR% NEQ 0 exit /b %LASTERROR%

:IGNORE_CMAKE_CONFIGURE

if %FLAGS_REGEN%0 NEQ 0 exit /b 0

rem SCM branch workingset
if %F_DISABLE_GEN_BRANCH_INFO%0 EQU 0 ^
if exist "%BUILD_SCRIPTS_ROOT%\gen_scm_branch_workingset.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_scm_branch_workingset.bat" || exit /b 31
)

rem cmake make
call :CMD cmake %%CMAKE_CMD_LINE.MAKE%% || goto :EOF

if not defined CMAKE_CMD_LINE.INSTALL goto IGNORE_CMAKE_INSTALL

rem cmake install
call :CMD cmake %%CMAKE_CMD_LINE.INSTALL%% || goto :EOF

:IGNORE_CMAKE_INSTALL

(
  echo."APP_BUILD_DATE=%APP_BUILD_DATE%"
  echo."APP_BUILD_TIME=%APP_BUILD_TIME%"
  echo."PROJECT_BUILD_DATE=%PROJECT_BUILD_DATE%"
  echo."PROJECT_BUILD_TIME=%PROJECT_BUILD_TIME%"
) > "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%\build.vars"

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_build
)

if %F_DISABLE_POST_BUILD%0 EQU 0 ( call "%%BUILD_SCRIPTS_ROOT%%/post_build.bat" || goto :EOF )

exit /b 0

:CMD
echo.^>%*
echo.
(%*)
exit /b
