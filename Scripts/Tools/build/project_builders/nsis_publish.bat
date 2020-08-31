@echo off

setlocal

set "PROJECT_NAMESPACE=%~1"
set "PROJECT_DIR_SUFFIX=%~2"
set "BUILD_CONFIG_ROOT=%~3"
set "BUILD_SCRIPTS_ROOT=%~4"
set "BUILD_USER_VARS_ROOT=%~5"

if not defined PROJECT_NAMESPACE (
  echo.%~nx0: error: PROJECT_NAMESPACE must be defined.
  exit /b 1
) >&2

if defined PROJECT_DIR_SUFFIX set "PROJECT_DIR_SUFFIX=/%PROJECT_DIR_SUFFIX:\=/%"

if defined BUILD_CONFIG_ROOT (
  if "\" == "%BUILD_CONFIG_ROOT:~0,1%" exit /b 2
  if "\" == "%BUILD_CONFIG_ROOT:~-1%" set "BUILD_CONFIG_ROOT=%BUILD_CONFIG_ROOT:~0,-1%"
)

if not defined BUILD_CONFIG_ROOT (
  echo.%~nx0: error: BUILD_CONFIG_ROOT must be defined.
  exit /b 2
) >&2

if defined BUILD_SCRIPTS_ROOT (
  if "\" == "%BUILD_SCRIPTS_ROOT:~0,1%" exit /b 3
  if "\" == "%BUILD_SCRIPTS_ROOT:~-1%" set "BUILD_SCRIPTS_ROOT=%BUILD_SCRIPTS_ROOT:~0,-1%"
)

if not defined BUILD_SCRIPTS_ROOT (
  echo.%~nx0: error: BUILD_SCRIPTS_ROOT must be defined.
  exit /b 3
) >&2

if defined BUILD_USER_VARS_ROOT (
  if "\" == "%BUILD_USER_VARS_ROOT:~0,1%" exit /b 4
  if "\" == "%BUILD_USER_VARS_ROOT:~-1%" set "BUILD_USER_VARS_ROOT=%BUILD_USER_VARS_ROOT:~0,-1%"
)

rem safe title call
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("publish %PROJECT_NAMESPACE%/%PROJECT_NAME% %BUILD_SCM_BRANCH%") do (
  endlocal
  title %%i
)

if exist "%BUILD_SCRIPTS_ROOT%/pre_validate_vars.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/pre_validate_vars.bat" || exit /b 10
) else call "%%~dp0nsis_pre_validate_vars.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 || exit /b 10

if exist "%BUILD_CONFIG_ROOT%/setup.post.vars" (
  rem load system post variables
  call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%BUILD_CONFIG_ROOT%%/setup.post.vars" || exit /b 11
)

rem load user post variables
call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%BUILD_USER_VARS_ROOT%%/setup.user.post.vars" || exit /b 12

rem gen
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%" (
  call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%"
  call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%" /E /Y /D || exit /b 20
)
rem pdb
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%" (
  call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%"
  call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%" /E /Y /D || exit /b 21
)
rem lib
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%" (
  call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%"
  call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%" /E /Y /D || exit /b 22
)
rem var
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%" (
  call "%%CONTOOLS_ROOT%%/std/mkdir.bat" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%"
  call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%/%%PROJECT_NAME%%%%PROJECT_DIR_SUFFIX%%" /E /Y /D || exit /b 23
)

exit /b 0
