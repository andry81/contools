@echo off

setlocal

if "%CMD_SCRIPT_NAME%" == "chcp" (
  call "%%CONTOOLS_ROOT%%/std/%%CMD_SCRIPT_NAME%%.bat" "%%CURRENT_CP_REF%%"
) else (
  call "%%CONTOOLS_ROOT%%/std/%%CMD_SCRIPT_NAME%%.bat"
)

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TEST_REPORT_PREFIX_STR=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TEST_REPORT_PREFIX_STR=%TESTLIB__CURRENT_TESTS%"

if "%CURRENT_CP_REF%" == "%CURRENT_CP%" if "%LAST_CP_REF%" == "%LAST_CP%" if "%CP_HISTORY_LIST_REF%" == "%CP_HISTORY_LIST%" (
  "%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "PASSED: %TEST_REPORT_PREFIX_STR%: CURRENT_CP=`${CURRENT_CP}` LAST_CP=`${LAST_CP}` CP_HISTORY_LIST=`${CP_HISTORY_LIST}`"
  set LAST_ERROR=0
  goto EXIT
)

"%CONTOOLS_UTILS_BIN_ROOT%/contools/printf.exe" "FAILED: %TEST_REPORT_PREFIX_STR%: CURRENT_CP=`${CURRENT_CP}`==`${CURRENT_CP_REF}` LAST_CP=`${LAST_CP}`==`${LAST_CP_REF}` CP_HISTORY_LIST=`${CP_HISTORY_LIST}`==`${CP_HISTORY_LIST_REF}`"
set LAST_ERROR=1

:EXIT
rem return script values
(
  endlocal
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
  exit /b %LAST_ERROR%
)
