@echo off & goto DOC_END

rem Description:
rem   The tests exit script. Must be called one time in a user test script
rem   after the last call to the `test.bat` script.

rem CAUTION:
rem   This script must be called without the `call` prefix!
rem
:DOC_END

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat"

if %TESTLIB__TEST_DO_TEARDOWN%0 NEQ 0 call :TEST_TEARDOWN
set TESTLIB__TEST_TEARDOWN=0

rem negative return code to indicate no error in the teardown
if %TESTLIB__CURRENT_PASSED_TESTS% LSS %TESTLIB__CURRENT_TESTS% (
  set /A LAST_ERROR=TESTLIB__CURRENT_PASSED_TESTS-TESTLIB__CURRENT_TESTS
) else set LAST_ERROR=0

set /A TESTLIB__NEST_LVL-=1

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat"

if %TESTLIB__NEST_LVL%0 EQU 0 (
  echo    %TESTLIB__OVERALL_PASSED_TESTS% of %TESTLIB__OVERALL_TESTS% tests is passed.
  echo;^
  if defined OEMCP ( call "%%CONTOOLS_ROOT%%/std/pause.bat" -chcp "%%OEMCP%%" ) else call "%%CONTOOLS_ROOT%%/std/pause.bat"
)

exit /b %LAST_ERROR%

:TEST_TEARDOWN
set "TESTLIB__TEST_DO_TEARDOWN="
if %TESTLIB__TEST_SETUP%0 EQU 0 exit /b -1
set "TESTLIB__TEST_SETUP="
set TESTLIB__TEST_TEARDOWN=1

rem call user teardown script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.teardown%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/teardown%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/teardown%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
  )
)

exit /b 0
