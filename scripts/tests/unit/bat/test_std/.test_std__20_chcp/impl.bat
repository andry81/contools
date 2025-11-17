@echo off

setlocal

if "%CMD_SCRIPT_NAME%" == "chcp" (
  call "%%CONTOOLS_ROOT%%/std/%%CMD_SCRIPT_NAME%%.bat" "%%CURRENT_CP_REF%%"
) else call "%%CONTOOLS_ROOT%%/std/%%CMD_SCRIPT_NAME%%.bat"

set "TEST_IMPL_ERROR=%ERRORLEVEL%"

(
  endlocal
  set "TEST_IMPL_ERROR=%TEST_IMPL_ERROR%"
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
  exit /b 0
)
