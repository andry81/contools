@echo off

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
rem     *teardown.bat - a test last time teardown handler.
rem     *exit.bat - exit handler for a test, useful if required to copy test
rem                 data out of a test script temporary output directory.
rem

setlocal

rem must be assigned not to 65000 codepage!
if defined CURRENT_CP ^
if "%CURRENT_CP%" == "65000" (
  chcp 866 >nul
)

rem workaround for the plus sign control character under a unicode codepage
set "?5=+"

rem restore back
if defined CURRENT_CP ^
if "%CURRENT_CP%" == "65000" (
  chcp 65000 >nul
)

set LAST_ERROR=0
set INTERRORLEVEL=0
set "TEST_DATA_REF_FILE="

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat"

set /A TESTLIB__CURRENT_TESTS%?5%=1
set /A TESTLIB__OVERALL_TESTS%?5%=1

if %TESTLIB__TEST_SETUP%0 EQU 0 (
  set TESTLIB__TEST_DO_TEARDOWN=1
  call :TEST_SETUP || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT ) )
  set TESTLIB__TEST_SETUP=0
)

rem call user initialization script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/init%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/init%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/init%%TEST_SCRIPT_FILE_EXT%%" %%* || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
)

rem call user implementation script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/impl%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/impl%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
) else (
  rem the one big IF+AND operator
  (
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( call; ) else type 2>nul
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/impl%TEST_SCRIPT_FILE_EXT%" ( call; ) else type 2>nul
  ) && (
    ( call "%%TEST_SCRIPT_HANDLERS_DIR%%/impl%%TEST_SCRIPT_FILE_EXT%%" ) || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_EXIT )
  )
) || (
  echo.%?~nx0%: error: test script implementation is not found: "%TEST_SCRIPT_FILE_NAME%".
  set "LAST_ERROR=-255"
) >&2

:TEST_EXIT
rem call user exit script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/exit%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/exit%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/exit%%TEST_SCRIPT_FILE_EXT%%" || ( call set "LAST_ERROR=%%ERRORLEVEL%%" & goto TEST_REPORT )
  )
)

:TEST_REPORT
if %LAST_ERROR% EQU 0 (
  set /A TESTLIB__CURRENT_PASSED_TESTS%?5%=1
  set /A TESTLIB__OVERALL_PASSED_TESTS%?5%=1
)

rem call user report script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.report%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.report%%TEST_SCRIPT_FILE_EXT%%"
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/report%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/report%%TEST_SCRIPT_FILE_EXT%%"
) else (
  rem the one big IF+AND operator
  (
    if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" ( call; ) else type 2>nul
  ) && (
    if exist "%TEST_SCRIPT_HANDLERS_DIR%/report%TEST_SCRIPT_FILE_EXT%" ( call; ) else type 2>nul
  ) && (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/report%%TEST_SCRIPT_FILE_EXT%%"
  )
)

goto TEST_END

:TEST_SETUP
if %TESTLIB__TEST_SETUP%0 NEQ 0 exit /b -1
set TESTLIB__TEST_SETUP=1
set "TESTLIB__TEST_TEARDOWN="

set LAST_ERROR=0
set INTERRORLEVEL=0

rem call user setup script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.setup%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.setup%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/setup%TEST_SCRIPT_FILE_EXT%" (
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/setup%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/setup%TEST_SCRIPT_FILE_EXT%" (
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/setup%%TEST_SCRIPT_FILE_EXT%%" || exit /b
  )
)

exit /b 0

:TEST_END
set "TESTLIB__EXEC_ON_ENDLOCAL="

if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.return.vars" (
  call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.return.vars"
  for /F "usebackq eol=# tokens=* delims=" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.return.vars") do (
    set "__?RETURN_VAR_NAME=%%i"
    call :SET_EXEC_ON_ENDLOCAL
  )
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/return.vars" (
  call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/return.vars"
  for /F "usebackq eol=# tokens=* delims=" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/return.vars") do (
    set "__?RETURN_VAR_NAME=%%i"
    call :SET_EXEC_ON_ENDLOCAL
  )
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/return.vars" (
    call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_HANDLERS_DIR%%/return.vars"
    for /F "usebackq eol=# tokens=* delims=" %%i in ("%TEST_SCRIPT_HANDLERS_DIR%/return.vars") do (
      set "__?RETURN_VAR_NAME=%%i"
      call :SET_EXEC_ON_ENDLOCAL
    )
  ) else call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat"
) else call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat"

goto EXIT

:SET_EXEC_ON_ENDLOCAL
if defined TESTLIB__EXEC_ON_ENDLOCAL (
  setlocal ENABLEDELAYEDEXPANSION
  for /F "eol= tokens=* delims=" %%i in ("!TESTLIB__EXEC_ON_ENDLOCAL!") do (
    endlocal
    call set TESTLIB__EXEC_ON_ENDLOCAL=%%i {{AND}} set "%%__?RETURN_VAR_NAME%%=%%%__?RETURN_VAR_NAME%%%"
  )
) else call set TESTLIB__EXEC_ON_ENDLOCAL=set "%%__?RETURN_VAR_NAME%%=%%%__?RETURN_VAR_NAME%%%"

exit /b 0

:EXIT
if defined TESTLIB__EXEC_ON_ENDLOCAL set TESTLIB__EXEC_ON_ENDLOCAL=%TESTLIB__EXEC_ON_ENDLOCAL:{{AND}}=^&%

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal

  set "LAST_ERROR=%LAST_ERROR%"
  set "TESTLIB__OVERALL_PASSED_TESTS=%TESTLIB__OVERALL_PASSED_TESTS%"
  set "TESTLIB__OVERALL_TESTS=%TESTLIB__OVERALL_TESTS%"
  set "TESTLIB__CURRENT_PASSED_TESTS=%TESTLIB__CURRENT_PASSED_TESTS%"
  set "TESTLIB__CURRENT_TESTS=%TESTLIB__CURRENT_TESTS%"
  set "TESTLIB__TEST_DO_TEARDOWN=%TESTLIB__TEST_DO_TEARDOWN%"

  rem return user declared variables
  %TESTLIB__EXEC_ON_ENDLOCAL%
)

exit /b %LAST_ERROR%
