@echo off

rem Description:
rem   Main entry point script for tests on batch files.
rem
rem   The first argument must be user test script file name from which this
rem   script calls.
rem
rem   The user script must contain the test handlers in separated scripts in
rem   this file structure format:
rem     /<user_test_script>.bat
rem     /<user_test_script>.init.bat or /.<user_test_script>/init.bat
rem     /<user_test_script>.impl.bat or /.<user_test_script>/impl.bat
rem     /<user_test_script>.report.bat or /.<user_test_script>/report.bat
rem     /<user_test_script>.setup.bat or /.<user_test_script>/setup.bat
rem     /<user_test_script>.teardown.bat or /.<user_test_script>/teardown.bat
rem     /<user_test_script>.exit.bat or /.<user_test_script>/exit.bat
rem
rem , where:
rem     <user_test_script>.bat - a test user script
rem     *init.bat - initialization handler for a test, required to process
rem                 command line arguments
rem     *impl.bat - implementation handler for a test, does not have command
rem                 line arguments
rem     *report.bat - report handler for a test, to print user test result
rem     *setup.bat - a test first time setup handler
rem     *teardown.bat - a test last time teardown handler
rem     *exit.bat - exit handler for a test, useful if required to copy test
rem                 data out of temporary test script output directory
rem

setlocal

set LASTERROR=0
set INTERRORLEVEL=0
set "TEST_DATA_REF_FILE="

set /A TESTLIB__CURRENT_TESTS+=1
set /A TESTLIB__OVERALL_TESTS+=1

if %TESTLIB__TEST_SETUP%0 EQU 0 (
  set TESTLIB__TEST_DO_TEARDOWN=1
  call :TEST_SETUP || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT ) )
)

rem call user initialization script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/init%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
)

rem call user implementation script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else (
  rem the one big IF+AND operator
  (
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( type nul>nul ) else type 2>nul
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/impl%TEST_SCRIPT_FILE_EXT%" ( type nul>nul ) else type 2>nul
  ) && (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
) || (
  echo.%?~nx0%: error: test script implementation is not found: "%TEST_SCRIPT_FILE_NAME%".
  set "LASTERROR=-255"
) >&2

:TEST_EXIT
rem call user exit script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/exit%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LASTERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
  )
)

:TEST_REPORT
if %LASTERROR% EQU 0 (
  set /A TESTLIB__CURRENT_PASSED_TESTS+=1
  set /A TESTLIB__OVERALL_PASSED_TESTS+=1
)

rem call user report script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.report%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.report%%TEST_SCRIPT_FILE_EXT%%"
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/report%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/report%%TEST_SCRIPT_FILE_EXT%%"
) else (
  rem the one big IF+AND operator
  (
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( type nul>nul ) else type 2>nul
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/report%TEST_SCRIPT_FILE_EXT%" ( type nul>nul ) else type 2>nul
  ) && (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/report%%TEST_SCRIPT_FILE_EXT%%"
  )
)

goto TEST_END

:TEST_SETUP
if %TESTLIB__TEST_SETUP%0 NEQ 0 exit /b -1
set TESTLIB__TEST_SETUP=1
set "TESTLIB__TEST_TEARDOWN="

set LASTERROR=0
set INTERRORLEVEL=0

rem call user setup script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.setup%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.setup%%TEST_SCRIPT_FILE_EXT%%" || goto :EOF
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/setup%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/setup%%TEST_SCRIPT_FILE_EXT%%" || goto :EOF
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/setup%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/setup%%TEST_SCRIPT_FILE_EXT%%" || goto :EOF
  )
)

exit /b 0

:TEST_END
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set LASTERROR=%LASTERROR%
  set TESTLIB__OVERALL_PASSED_TESTS=%TESTLIB__OVERALL_PASSED_TESTS%
  set TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%
  set TESTLIB__CURRENT_PASSED_TESTS=%TESTLIB__CURRENT_PASSED_TESTS%
  set TESTLIB__CURRENT_TESTS=%TESTLIB__CURRENT_TESTS%
  set TESTLIB__TEST_SETUP=%TESTLIB__TEST_SETUP%
  set TESTLIB__TEST_DO_TEARDOWN=%TESTLIB__TEST_DO_TEARDOWN%
)

exit /b %LASTERROR%
