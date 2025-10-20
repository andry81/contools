@echo off & goto DOC_END

rem Description:
rem   The tests exit script. Must be called one time in a user test script
rem   after the last call to the `test.bat` script.

rem CAUTION:
rem   This script must be called without the `call` prefix!
rem
rem CAUTION:
rem   We must use an uniform code page to avoid a code page change between calls
rem   and so accidental recode on a file read/write.
rem
rem CAUTION:
rem   The script can be nest called, but nesting is limited up to 31 calls.
:DOC_END

if %TESTLIB__INIT%0 EQU 0 (
  echo;%~nx0: error: test is not initialized.
  exit /b 255
) >&2

if not defined TESTLIB__CHCP_EXE (
  echo;%~nx0: error: `TESTLIB__CHCP_EXE` is not initialized.
  exit /b 255
) >&2

rem reread current code page for each test, before exit and after exit

if not defined SETUP_CP goto SKIP_SETUP_CP
if not defined CHCP goto SKIP_SETUP_CP
if %NO_CHCP%0 NEQ 0 goto SKIP_SETUP_CP

rem reads the current code page into `TESTLIB__TEST_CP` variable
call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

rem assigns the inner code page (`CHCP`, must be not 65000) if is different with a current code page (`TESTLIB__TEST_CP`)
call "%%CONTOOLS_TESTLIB_ROOT%%/set_inner_cp.bat"

:SKIP_SETUP_CP

call :MAIN %%*
set TEST_LAST_ERROR=%ERRORLEVEL%

if %TESTLIB__TEST_TEARDOWN_CALLED% EQU 0 goto SKIP_UPDATE_CURRENT_CP

rem reads the current code page into `TESTLIB__TEST_CP` variable
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/getcp.bat"

:SKIP_UPDATE_CURRENT_CP

rem calls to `set_inner_cp.bat` at the beginning
call "%%CONTOOLS_TESTLIB_ROOT%%/update_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" TEST_LAST_ERROR TESTLIB__INIT TESTLIB__PREV_CP TESTLIB__TEST_CP
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_EXIT_VARS_FILE_PATH%" >nul

rem restores a previous code page before the init (`TESTLIB__PREV_CP`) if is different with an outer code page (`TESTLIB__TEST_CP`)
if defined SETUP_CP if defined CHCP if %NO_CHCP%0 EQU 0 call "%%CONTOOLS_TESTLIB_ROOT%%/set_prev_cp.bat"

exit /b %TEST_LAST_ERROR%

:MAIN
call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%"

rem cast to integer
set /A "TESTLIB__INIT+=0" & rem nest level

set /A "TESTLIB__TEST_TEARDOWN=TESTLIB__TEST_SETUP & (1 << TESTLIB__INIT - 1)"
set /A "TESTLIB__TEST_SETUP&=~TESTLIB__TEST_TEARDOWN"
set TESTLIB__TEST_TEARDOWN_CALLED=0

call :TEST_TEARDOWN
set TEST_LAST_ERROR=%ERRORLEVEL%

set /A TESTLIB__INIT-=1

set "TEST_SCRIPT_NEST_LVL_DIR_NAME=%TESTLIB__INIT%"

if "%TEST_SCRIPT_NEST_LVL_DIR_NAME:~1,1%" == "" set "TEST_SCRIPT_NEST_LVL_DIR_NAME=0%TEST_SCRIPT_NEST_LVL_DIR_NAME%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH "%%TEST_SCRIPT_SHARED_DIR%%/%%TEST_SCRIPT_NEST_LVL_DIR_NAME%%.vars"

setlocal DISABLEDELAYEDEXPANSION

call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat" "" "%%TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH%%"

set "BEGIN_TIME=%TESTLIB__BEGIN_TIME%"

call "%%CONTOOLS_ROOT%%/time/end_time.bat" 1
set "TESTLIB__END_TIME=%END_TIME%"
set "TESTLIB__TIME=%TIME_INTS%.%TIME_FRACS%"

setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("Time spent: !TESTLIB__TIME! secs (!TESTLIB__TEST_SCRIPT_FILE_STACK!)") do endlocal & echo;%%i
echo;

(
  endlocal
  set "TESTLIB__BEGIN_TIME=%TESTLIB__BEGIN_TIME%"
  set "TESTLIB__END_TIME=%TESTLIB__END_TIME%"
  set "TESTLIB__TIME=%TESTLIB__TIME%"
)

if %TEST_LAST_ERROR% EQU 0 (
  rem negative return code to indicate no error in the tear down
  if %TESTLIB__CURRENT_PASSED_TESTS% LSS %TESTLIB__CURRENT_TESTS% set /A TEST_LAST_ERROR=TESTLIB__CURRENT_PASSED_TESTS-TESTLIB__CURRENT_TESTS
)

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat" "%%TEST_SCRIPT_SHARED_VARS_FILE_PATH%%" "" "%%TEST_SCRIPT_NEST_LVL_VARS_FILE_PATH%%"
copy /Y /B "%TEST_SCRIPT_SHARED_VARS_FILE_PATH%" "%TEST_SCRIPT_EXIT_VARS_FILE_PATH%" >nul

setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=* delims="eol^= %%i in ("!TEST_SCRIPT_FILE!") do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!TEST_SCRIPT_INIT_CMDLINE!"') do endlocal & ^
title [%TESTLIB__OVERALL_PASSED_TESTS% of %TESTLIB__OVERALL_TESTS%] %%i %%~j
endlocal

if %TESTLIB__INIT% EQU 0 (
  echo    %TESTLIB__OVERALL_PASSED_TESTS% of %TESTLIB__OVERALL_TESTS% tests is passed.
  echo;^
  if not defined IMPL_MODE if defined OEMCP ( call "%%CONTOOLS_ROOT%%/std/pause.bat" -chcp "%%OEMCP%%" ) else call "%%CONTOOLS_ROOT%%/std/pause.bat"
)

exit /b %TEST_LAST_ERROR%

:TEST_TEARDOWN
rem call user teardown script
if exist "%TEST_SCRIPT_HANDLERS_DIR%/%TEST_SCRIPT_FILE_NAME%.teardown%TEST_SCRIPT_FILE_EXT%" (
  if %TESTLIB__TEST_TEARDOWN% EQU 0 (
    echo;%~nx0: warning: a test teardown is going to call without a test setup.
    echo;
  ) >&2
  set TESTLIB__TEST_TEARDOWN_CALLED=1
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/%%TEST_SCRIPT_FILE_NAME%%.teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if exist "%TEST_SCRIPT_HANDLERS_DIR%/.%TEST_SCRIPT_FILE_NAME%/teardown%TEST_SCRIPT_FILE_EXT%" (
  if %TESTLIB__TEST_TEARDOWN% EQU 0 (
    echo;%~nx0: warning: a test teardown is going to call without a test setup.
    echo;
  ) >&2
  set TESTLIB__TEST_TEARDOWN_CALLED=1
  call "%%TEST_SCRIPT_HANDLERS_DIR%%/.%%TEST_SCRIPT_FILE_NAME%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
) else if not "%TEST_SCRIPT_HANDLERS_DIR%" == "%TEST_SCRIPT_FILE_DIR%" (
  if exist "%TEST_SCRIPT_HANDLERS_DIR%/teardown%TEST_SCRIPT_FILE_EXT%" (
    if %TESTLIB__TEST_TEARDOWN% EQU 0 (
      echo;%~nx0: warning: a test teardown is going to call without a test setup.
      echo;
    ) >&2
    set TESTLIB__TEST_TEARDOWN_CALLED=1
    call "%%TEST_SCRIPT_HANDLERS_DIR%%/teardown%%TEST_SCRIPT_FILE_EXT%%" || exit /b
  )
)

if %TESTLIB__TEST_TEARDOWN_CALLED% EQU 0 if %TESTLIB__TEST_TEARDOWN% NEQ 0 (
  echo;%~nx0: warning: a test setup has called without a test teardown.
  echo;
) >&2

exit /b 0
