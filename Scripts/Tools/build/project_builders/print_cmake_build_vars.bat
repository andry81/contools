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

echo."SOLUTION_BRANCH_ROOT=%SOLUTION_BRANCH_ROOT%"

echo."PROJECT_NAME=%PROJECT_NAME%"
echo."PROJECT_ROOT=%PROJECT_ROOT%"
echo."PROJECT_BRANCH_ROOT=%PROJECT_BRANCH_ROOT%"
echo."PROJECT_TRUNK_ROOT=%PROJECT_TRUNK_ROOT%"

echo."BUILD_SCM_BRANCH=%BUILD_SCM_BRANCH%"

echo."PROJECT_BUILD_DATE=%PROJECT_BUILD_DATE%"
echo."PROJECT_BUILD_TIME=%PROJECT_BUILD_TIME%"

echo."BUILD_DEV_COMPILER=%BUILD_DEV_COMPILER%"
echo."BUILD_DEV_COMPILER_DIR=%BUILD_DEV_COMPILER_DIR%"
echo."BUILD_DEV_ADDRESS_MODEL=%BUILD_DEV_ADDRESS_MODEL%"
echo."CMAKE_GENERATOR_TOOLSET=%CMAKE_GENERATOR_TOOLSET%"

echo."PROJECT_SRCS_ROOT=%PROJECT_SRCS_ROOT%"
echo."PROJECT_LIBS_ROOT=%PROJECT_LIBS_ROOT%"
echo."PROJECT_INCLUDES_ROOT=%PROJECT_INCLUDES_ROOT%"

echo."PROJECT_STAGE_BUILD_ROOT=%PROJECT_STAGE_BUILD_ROOT%"
echo."PROJECT_STAGE_POSTBUILD_ROOT=%PROJECT_STAGE_POSTBUILD_ROOT%"

echo."PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR=%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%"
echo."PROJECT_STAGE_BUILD_ROOT.BIN_DIR=%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%"
echo."PROJECT_STAGE_BUILD_ROOT.PDB_DIR=%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%"
echo."PROJECT_STAGE_BUILD_ROOT.LIB_DIR=%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%"
echo."PROJECT_STAGE_BUILD_ROOT.GEN_DIR=%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%"
echo."PROJECT_STAGE_BUILD_ROOT.VAR_DIR=%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%"

echo."STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR=%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%"
echo."STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR=%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%"
echo."STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR=%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%"
echo."STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR=%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%"
echo."STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR=%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%"

echo."PUBLISH_BUILDS_ROOT=%PUBLISH_BUILDS_ROOT%"
echo."PUBLISH_APP_ROOT=%PUBLISH_APP_ROOT%"
echo."PUBLISH_APP_DIR=%PUBLISH_APP_DIR%"
echo."PUBLISH_APP_DIR_BUILD_TOKEN=%PUBLISH_APP_DIR_BUILD_TOKEN%"
echo."PUBLISH_APP_DIR_USER_TOKEN=%PUBLISH_APP_DIR_USER_TOKEN%"

echo."APP_ROOT=%APP_ROOT%"
echo."APP_DIR=%APP_DIR%"

echo."APP_TARGET_NAME=%APP_TARGET_NAME%"
echo."TARGET_NAME=%TARGET_NAME%"
echo."PROJECT_TYPE=%PROJECT_TYPE%"

echo."APP_TARGETS_LIST=%APP_TARGETS_LIST%"
echo."TARGETS_LIST=%TARGETS_LIST%"
echo.
( call; & set "APP_INTEGRATION_" 2>nul ) && echo.
echo.  Build flags:
( call; & set "F_DISABLE_" 2>nul ) && echo.
( call; & set "F_ENABLE_" 2>nul ) && echo.

exit /b 0
