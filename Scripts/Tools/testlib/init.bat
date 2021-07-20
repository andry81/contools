@echo off

rem Description:
rem   The tests initialization script. Must be called one time in a user test
rem   script before the first call to the `test.bat` script.
rem
rem   The first argument must be the full path to the user test script file
rem   from which this script calls.
rem
rem   The second argument (optional) can point to a directory with user handler
rem   scripts. Can be absolute or relative. If is a relative then relative to
rem   the directory path from the first argument.
rem

rem initialize testlib "module"
call "%%~dp0__init__.bat" || exit /b

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

set "TEST_SCRIPT_FILE_PATH=%~1"
if defined TEST_SCRIPT_FILE_PATH ^
if "%TEST_SCRIPT_FILE_PATH:~1,1%" == ":" goto TEST_SCRIPT_FILE_PATH_OK

(
  echo.%~nx0: error: test script file path is empty or not absolute: "%TEST_SCRIPT_FILE_PATH%".
  exit /b -255
) >&2

:TEST_SCRIPT_FILE_PATH_OK

rem shortcuts to the user test script file name
set "?~n0=%~n1"
set "?~x0=%~x1"
set "?~nx0=%~nx1"
set "?~dpf0=%~dpf1"
set "?~dp0=%~dp1"
set "?~d0=%~d1"

rem make builtin canonical user script path variables
call :CANONICAL_PATH TEST_SCRIPT_FILE_PATH "%%?~dpf0%%"

set "TEST_SCRIPT_FILE_NAME=%?~n0%"
set "TEST_SCRIPT_FILE_EXT=%?~x0%"

set "TEST_SCRIPT_FILE=%?~nx0%"

call :CANONICAL_PATH TEST_SCRIPT_FILE_DIR "%%?~dp0%%"

if not defined TEST_SCRIPT_OUTPUT_DIR     call :CANONICAL_PATH TEST_SCRIPT_OUTPUT_DIR       "%%TEST_SCRIPT_FILE_DIR%%/_out"
if not defined TEST_SCRIPT_LOCAL_TEMP_DIR call :CANONICAL_PATH TEST_SCRIPT_LOCAL_TEMP_DIR   "%%TEST_SCRIPT_OUTPUT_DIR%%/_temp"

call :CANONICAL_PATH TEST_SCRIPT_RETURN_VARS_DIR          "%%TEST_SCRIPT_LOCAL_TEMP_DIR%%/test_return_vars"
call :CANONICAL_PATH TEST_SCRIPT_RETURN_VARS_FILE_PATH    "%%TEST_SCRIPT_RETURN_VARS_DIR%%/vars.txt"
call :CANONICAL_PATH TEST_SCRIPT_RETURN_VALUES_FILE_PATH  "%%TEST_SCRIPT_RETURN_VARS_DIR%%/names.txt"
call :CANONICAL_PATH TEST_SCRIPT_RETURN_LOCK_FILE_PATH    "%%TEST_SCRIPT_RETURN_VARS_DIR%%/.lock"

set "TEST_SCRIPT_HANDLERS_DIR=%~2"

if not defined TEST_SCRIPT_HANDLERS_DIR (
  set "TEST_SCRIPT_HANDLERS_DIR=%TEST_SCRIPT_FILE_DIR%"
) else if not ":" == "%TEST_SCRIPT_HANDLERS_DIR:~1,1%" (
  rem relative to the script directory path
  call :CANONICAL_PATH TEST_SCRIPT_HANDLERS_DIR "%%TEST_SCRIPT_FILE_DIR%%/%%TEST_SCRIPT_HANDLERS_DIR%%"
)

if not defined TESTLIB__NEST_LVL set TESTLIB__NEST_LVL=0
if not defined TESTLIB__TEST_DO_TEARDOWN set TESTLIB__TEST_DO_TEARDOWN=0

if %TESTLIB__NEST_LVL%0 EQU 0 (
  if exist "%TEST_SCRIPT_RETURN_VARS_DIR%\" rmdir /S /Q "%TEST_SCRIPT_RETURN_VARS_DIR%"
  if not exist "%TEST_SCRIPT_OUTPUT_DIR%\" mkdir "%TEST_SCRIPT_OUTPUT_DIR%"
  if not exist "%TEST_SCRIPT_LOCAL_TEMP_DIR%\" mkdir "%TEST_SCRIPT_LOCAL_TEMP_DIR%"
  if not exist "%TEST_SCRIPT_RETURN_VARS_DIR%\" mkdir "%TEST_SCRIPT_RETURN_VARS_DIR%"
  set TESTLIB__OVERALL_PASSED_TESTS=0
  set TESTLIB__OVERALL_TESTS=0
) else call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat"

set TESTLIB__CURRENT_PASSED_TESTS=0
set TESTLIB__CURRENT_TESTS=0

set /A TESTLIB__NEST_LVL%?5%=1

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat"

rem return code from user test script
set LASTERROR=0

rem return code from user test script implementation
set INTERRORLEVEL=0

echo Running %?~nx0%...

rem safe title call
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%?~nx0% %2 %3 %4 %5 %6 %7 %8 %9") do (
  endlocal
  title %%i
)

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
