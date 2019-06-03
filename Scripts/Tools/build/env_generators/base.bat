@echo off

rem generate common environment
set "__PROJECT_NAME="
call :GEN_PROJECT_ENV %%*

rem generate per project environment
for %%i in (%PROJECTS_LIST%) do (
  set "__PROJECT_NAME=%%i"
  call :GEN_PROJECT_ENV
)

rem drop internal variables
(
  set "__BUILD_DEV_COMPILER="
  set "__BUILD_DEV_ADDRESS_MODEL="
)

exit /b

:GEN_PROJECT_ENV
if not defined __PROJECT_NAME set "__PROJECT_VAR_PREFIX="
if defined __PROJECT_NAME set "__PROJECT_VAR_PREFIX=%__PROJECT_NAME%."

call set "__BUILD_DEV_COMPILER=%%%__PROJECT_VAR_PREFIX%BUILD_DEV_COMPILER%%"
call set "__BUILD_DEV_ADDRESS_MODEL=%%%__PROJECT_VAR_PREFIX%BUILD_DEV_ADDRESS_MODEL%%"

rem common (not project) variables
if "%__BUILD_DEV_ADDRESS_MODEL%" == "32" (
  call :SET_IF_EMPTY %__PROJECT_VAR_PREFIX%BUILD_DEV_COMPILER_DIR "%%__BUILD_DEV_COMPILER%%_x86"
) else (
  call :SET_IF_EMPTY %__PROJECT_VAR_PREFIX%BUILD_DEV_COMPILER_DIR "%%__BUILD_DEV_COMPILER%%_x%%__BUILD_DEV_ADDRESS_MODEL%%"
)

rem drop temporary variables
(
  set "__PROJECT_NAME="
  set "__BUILD_DEV_COMPILER="
  set "__BUILD_DEV_ADDRESS_MODEL="
  set "__PROJECT_VAR_PREFIX="
)

exit /b 0

:SET_IF_EMPTY
setlocal
call set "__VALUE__=%%%~1%%"
if not "%~1" == "" ^
if not defined __VALUE__ (
  endlocal
  if %F_ENABLE_PRINT_USER_CONFIGURE_VARS_SET%0 NEQ 0 echo.%~1=%2
  set "%~1=%~2"
)
exit /b
