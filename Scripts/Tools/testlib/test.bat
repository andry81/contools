@echo off & goto DOC_END

rem Description:
rem   Main entry point script for a user test script.
rem
rem   A user script must contain the handlers in separate scripts in this file
rem   structure format:
rem     /<user_test_script>.bat
rem     /<user_test_script>.init.bat or /.<user_test_script>/init.bat
rem     /<user_test_script>.impl.bat or /.<user_test_script>/impl.bat
rem     /<user_test_script>.report.bat or /.<user_test_script>/report.bat
rem     /<user_test_script>.setup.bat or /.<user_test_script>/setup.bat
rem     /<user_test_script>.teardown.bat or /.<user_test_script>/teardown.bat
rem     /<user_test_script>.exit.bat or /.<user_test_script>/exit.bat
rem
rem , where:
rem     <user_test_script>.bat - a test user script.
rem     *init.bat - initialization handler for a test, required to process
rem                 command line arguments.
rem     *impl.bat - implementation handler for a test, does not have command
rem                 line arguments.
rem     *report.bat - report handler for a test, to print user test result.
rem     *setup.bat - a test first time setup handler.
rem     *teardown.bat - a test last time tear down handler.
rem     *exit.bat - exit handler for a test, useful if required to copy test
rem                 data out of a test script temporary output directory.
rem
rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between
rem   calls and so accidental recode on a file read/write.
rem
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

rem reread current code page for each test, before run and after run

call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem must be assigned not to 65000 code page!
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

set "TESTLIB__EXEC_ON_ENDLOCAL="

call :MAIN %%*
set TEST_LAST_ERROR=%ERRORLEVEL%

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"
call "%%CONTOOLS_TESTLIB_ROOT%%/update_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" ^
  TEST_LAST_ERROR TEST_IMPL_ERROR
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_TEST_VARS_FILE_PATH%" >nul

rem restore outer code page
call "%%CONTOOLS_TESTLIB_ROOT%%/set_outer_cp.bat"

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal

  set "TEST_LAST_ERROR=%TEST_LAST_ERROR%"
  set "TESTLIB__OVERALL_PASSED_TESTS=%TESTLIB__OVERALL_PASSED_TESTS%"
  set "TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%"
  set "TESTLIB__CURRENT_PASSED_TESTS=%TESTLIB__CURRENT_PASSED_TESTS%"
  set "TESTLIB__CURRENT_TESTS=%TESTLIB__CURRENT_TESTS%"

  rem return user declared variables
  %TESTLIB__EXEC_ON_ENDLOCAL%
)

exit /b %TEST_LAST_ERROR%

:MAIN
call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"

rem return code from a user test script handler
set TEST_LAST_ERROR=0

rem return code from user test script implementation (`*impl.bat`)
set TEST_IMPL_ERROR=0

set /A TESTLIB__CURRENT_TESTS+=1
set /A TESTLIB__OVERALL_TESTS+=1

if %TESTLIB__OVERALL_TESTS% GTR %TESTLIB__CURRENT_TESTS% (
  set "TESTLIB__TEST_ORDER_NUMBER=%TESTLIB__OVERALL_TESTS%`%TESTLIB__CURRENT_TESTS%"
) else set "TESTLIB__TEST_ORDER_NUMBER=%TESTLIB__CURRENT_TESTS%"

rem call user initialization script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/init%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
)

rem restore outer code page
call "%%CONTOOLS_TESTLIB_ROOT%%/set_outer_cp.bat"

rem call user implementation script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else (
  rem the one big IF+AND operator
  (
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( call; ) else call
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/impl%TEST_SCRIPT_FILE_EXT%" ( call; ) else call
  ) && (
    ( call "%%TEST_SCRIPT_HANDLERS_DIR%%/impl%%TEST_SCRIPT_FILE_EXT%%" ) || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
) || (
  echo;%~nx0: error: test script implementation is not found: "%TEST_SCRIPT_FILE_NAME%".
  set "TEST_LAST_ERROR=255"
) >&2

:TEST_EXIT
rem call user exit script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/exit%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "TEST_LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
  )
)

:TEST_REPORT
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem must be assigned not to 65000 code page!
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

if %TEST_LAST_ERROR% EQU 0 (
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
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( call; ) else call
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/report%TEST_SCRIPT_FILE_EXT%" ( call; ) else call
  ) && (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/report%%TEST_SCRIPT_FILE_EXT%%"
  )
)

rem reset after load
set "TESTLIB__EXEC_ON_ENDLOCAL="

if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.return.vars" (
  call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_RETURN_VARS_FILE_PATH%%" "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.return.vars"
  copy /Y /B "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%" + "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" >nul
  move /Y "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" >nul
  for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.return.vars") do (
    set "__?RETURN_VAR_NAME=%%i"
    call :SET_EXEC_ON_ENDLOCAL
  )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/return.vars" (
  call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_RETURN_VARS_FILE_PATH%%" "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/return.vars"
  copy /Y /B "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%" + "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" >nul
  move /Y "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" >nul
  for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/return.vars") do (
    set "__?RETURN_VAR_NAME=%%i"
    call :SET_EXEC_ON_ENDLOCAL
  )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/return.vars" (
    call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_RETURN_VARS_FILE_PATH%%" "%%TEST_SCRIPT_HANDLERS_DIR%%/return.vars"
    copy /Y /B "%TEST_SCRIPT_RETURN_VARS_FILE_PATH%" + "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" >nul
    move /Y "%TEST_SCRIPT_SHARED_VARS_FILE_PATH_TMP%" "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" >nul
    for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/return.vars") do (
      set "__?RETURN_VAR_NAME=%%i"
      call :SET_EXEC_ON_ENDLOCAL
    )
  )
)

exit /b 0

:SET_EXEC_ON_ENDLOCAL
if defined TESTLIB__EXEC_ON_ENDLOCAL (
  setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1,* delims=|"eol^= %%i in ("!TESTLIB__EXEC_ON_ENDLOCAL!|!%__?RETURN_VAR_NAME%!") do (
    endlocal
    set TESTLIB__EXEC_ON_ENDLOCAL=%%i ^& set "%__?RETURN_VAR_NAME%=%%j"
  )
) else setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=1,* delims=|"eol^= %%i in (".|!%__?RETURN_VAR_NAME%!") do (
  endlocal
  set TESTLIB__EXEC_ON_ENDLOCAL=set "%__?RETURN_VAR_NAME%=%%j"
)

exit /b 0
