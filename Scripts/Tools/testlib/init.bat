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
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%* || exit /b

rem make builtin canonical user script path variables
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_FILE_PATH "%%?~f0%%"

set "TEST_SCRIPT_FILE_NAME=%?~n0%"
set "TEST_SCRIPT_FILE_EXT=%?~x0%"
set "TEST_SCRIPT_FILE=%?~nx0%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_FILE_DIR "%%?~dp0%%"

call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_SCRIPT_OUTPUT_DIR       "%%TEST_SCRIPT_FILE_DIR%%/_out"
call "%%CONTOOLS_ROOT%%/std/canonical_path_if_ndef.bat" TEST_SCRIPT_LOCAL_TEMP_DIR   "%%TEST_SCRIPT_OUTPUT_DIR%%/_temp"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_RETURN_VARS_DIR          "%%TEST_SCRIPT_LOCAL_TEMP_DIR%%/test_return_vars"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_RETURN_VARS_FILE_PATH    "%%TEST_SCRIPT_RETURN_VARS_DIR%%/vars.txt"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_RETURN_VALUES_FILE_PATH  "%%TEST_SCRIPT_RETURN_VARS_DIR%%/values.txt"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_RETURN_LOCK_FILE_PATH    "%%TEST_SCRIPT_RETURN_VARS_DIR%%/.lock"

set "TEST_SCRIPT_HANDLERS_DIR=%~2"

if not defined TEST_SCRIPT_HANDLERS_DIR (
  set "TEST_SCRIPT_HANDLERS_DIR=%TEST_SCRIPT_FILE_DIR%"
) else if not ":" == "%TEST_SCRIPT_HANDLERS_DIR:~1,1%" (
  rem relative to the script directory path
  call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_SCRIPT_HANDLERS_DIR "%%TEST_SCRIPT_FILE_DIR%%/%%TEST_SCRIPT_HANDLERS_DIR%%"
)

if not defined TESTLIB__NEST_LVL set TESTLIB__NEST_LVL=0
if not defined TESTLIB__TEST_DO_TEARDOWN set TESTLIB__TEST_DO_TEARDOWN=0

if %TESTLIB__NEST_LVL%0 EQU 0 (
  call "%%CONTOOLS_ROOT%%/std/rmdir_if_exist.bat" "%%TEST_SCRIPT_RETURN_VARS_DIR%%" /S /Q
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_SCRIPT_OUTPUT_DIR%%" || exit /b
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_SCRIPT_LOCAL_TEMP_DIR%%" || exit /b
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%TEST_SCRIPT_RETURN_VARS_DIR%%" || exit /b
  set TESTLIB__OVERALL_PASSED_TESTS=0
  set TESTLIB__OVERALL_TESTS=0
) else call "%%CONTOOLS_TESTLIB_ROOT%%/load_locals.bat"

set TESTLIB__CURRENT_PASSED_TESTS=0
set TESTLIB__CURRENT_TESTS=0

set /A TESTLIB__NEST_LVL%?5%=1

call "%%CONTOOLS_TESTLIB_ROOT%%/save_locals.bat"

rem return code from user test script
set LAST_ERROR=0

rem return code from user test script implementation
set INTERRORLEVEL=0

echo Running %?~nx0%...
echo.

call "%%CONTOOLS_ROOT%%/std/setshift.bat" -skip 1 1 TEST_TITLE %%?~nx0%% %%*

setlocal DISABLEDELAYEDEXPANSION & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!TEST_TITLE!") do endlocal & title %%i
exit /b 0
