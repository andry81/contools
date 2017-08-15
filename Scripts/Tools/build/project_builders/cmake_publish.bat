@echo off

setlocal

set "PROJECT_NAMESPACE=%~1"
set "BUILD_CONFIG_ROOT=%~2"
set "BUILD_SCRIPTS_ROOT=%~3"
set "BUILD_USER_VARS_ROOT=%~4"

if not defined PROJECT_NAMESPACE (
  echo.%~nx0: error: PROJECT_NAMESPACE must be defined.
  exit /b 1
) >&2

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

call "%%~dp0pre_validate_vars.bat" || exit /b 10

rem load user post variables
call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" "%%PWSOURCES.SETUP.PROJECT_ROOT%%/setup.user.post.vars" || goto :EOF

title publish %PROJECT_NAMESPACE%/%PROJECT_NAME% %BUILD_SCM_BRANCH%

rem gen
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%" (
  call mkdir "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/%%PROJECT_NAME%%"
  call :XCOPY_DIR "%%PROJECT_STAGE_POSTBUILD_ROOT.GEN_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/%%PROJECT_NAME%%" /E /Y /D || goto :EOF
)
rem pdb
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%" (
  call mkdir "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%/%%PROJECT_NAME%%"
  call :XCOPY_DIR "%%PROJECT_STAGE_POSTBUILD_ROOT.PDB_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.PDB_DIR%%/%%PROJECT_NAME%%" /E /Y /D || goto :EOF
)
rem lib
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%" (
  mkdir "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%/%%PROJECT_NAME%%"
  call :XCOPY_DIR "%%PROJECT_STAGE_POSTBUILD_ROOT.LIB_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.LIB_DIR%%/%%PROJECT_NAME%%" /E /Y /D || goto :EOF
)
rem var
if exist "%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%" (
  mkdir "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%/%%PROJECT_NAME%%"
  call :XCOPY_DIR "%%PROJECT_STAGE_POSTBUILD_ROOT.VAR_DIR%%" "%%%PROJECT_NAMESPACE%.PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%/%%PROJECT_NAME%%" /E /Y /D || goto :EOF
)

exit /b 0

:XCOPY_DIR
call "%%CONTOOLS_ROOT%%/xcopy_dir.bat" %%* || goto :EOF
exit /b 0
