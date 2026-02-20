@echo off & goto DOC_END

rem USAGE:
rem   set_test_failed.bat
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

if %TESTLIB__INIT%0 EQU 0 (
  echo;%~nx0: error: test is not initialized.
  exit /b 255
) >&2

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

if not defined SETUP_CP goto SKIP_SETUP_CP
if not defined CHCP goto SKIP_SETUP_CP
if %NO_CHCP%0 NEQ 0 goto SKIP_SETUP_CP

rem reread current code page for each test, before run and after run

rem reads the current code page into `TESTLIB__TEST_CP` variable
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem assigns the inner code page (`CHCP`, must be not 65000) if is different with a current code page (`TESTLIB__TEST_CP`)
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

:SKIP_SETUP_CP

set /A TESTLIB__CURRENT_TESTS+=1
set /A TESTLIB__OVERALL_TESTS+=1

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TESTLIB__TEST_ORDER_NUMBER=%TESTLIB__OVERALL_TESTS%'%TESTLIB__CURRENT_TESTS%"
) else set "TESTLIB__TEST_ORDER_NUMBER=%TESTLIB__CURRENT_TESTS%"

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"
call "%%CONTOOLS_TESTLIB_ROOT%%/update_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" TEST_LAST_ERROR TEST_IMPL_ERROR
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_TEST_VARS_FILE_PATH%" >nul

rem restores an outer code page (`TESTLIB__TEST_CP`) if is different with the inner code page (`CHCP`, must be not 65000)
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_outer_cp.bat"

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal

  rem set "TESTLIB__OVERALL_PASSED_TESTS=%TESTLIB__OVERALL_PASSED_TESTS%"
  set "TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%"
  rem set "TESTLIB__CURRENT_PASSED_TESTS=%TESTLIB__CURRENT_PASSED_TESTS%"
  set "TESTLIB__CURRENT_TESTS=%TESTLIB__CURRENT_TESTS%"
  set "TESTLIB__TEST_ORDER_NUMBER=%TESTLIB__TEST_ORDER_NUMBER%"
)

exit /b 0
