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

title prebuild %PROJECT_NAME% %BUILD_SCM_BRANCH% %PROJECT_TYPE% %APP_TARGET_NAME% %TARGET_NAME%

if defined UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR if exist "%UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%/post_build.vars" (
  rem load staged out project build variables as stage in
  call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%UPSTREAM.PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%/post_build.vars" "" STAGE_IN. || goto :EOF
)

if exist "%BUILD_SCRIPTS_ROOT%/apply_patches.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/apply_patches.bat" || goto :EOF
)

rem load user post variables
call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%BUILD_USER_VARS_ROOT%%/setup.user.post.vars" || goto :EOF

if %F_ENABLE_PRE_BUILD_PRINT_ENV%0 NEQ 0 (
  rem print all environment variables before cmake call
  echo.-------------------------------------------------------------------------------
  set
  echo.-------------------------------------------------------------------------------
)

exit /b 0
