@echo off

rem Description:
rem   The tests initialization script. Must be called one time in user test
rem   script before the first call to the test.bat script.
rem
rem   The first argument must be the full path to the user test script file from
rem   which this script calls.

rem initialize testlib "module"
call "%%~dp0__init__.bat" || goto :EOF

if "%TESTLIB__NEST_LVL%" == "" set TESTLIB__NEST_LVL=0

if %TESTLIB__NEST_LVL%0 EQU 0 (
  set TESTLIB__PASSED_TESTS=0
  set TESTLIB__OVERALL_TESTS=0
)

rem shortcuts to the user test script file name
set "?~n0=%~n1"
set "?~x0=%~x1"
set "?~nx0=%~nx1"
set "?~dpf0=%~dpf1"
set "?~dp0=%~dp1"
set "?~d0=%~d1"

rem make builtin canonical user script path variables
set "TEST_SCRIPT_FILE_PATH=%?~dpf0%"
set "TEST_SCRIPT_FILE_PATH=%TEST_SCRIPT_FILE_PATH:\=/%"

set "TEST_SCRIPT_FILE_NAME=%?~n0%"
set "TEST_SCRIPT_FILE_EXT=%?~x0%"

set "TEST_SCRIPT_FILE=%?~nx0%"

set "TEST_SCRIPT_FILE_DIR=%?~dp0%"
set "TEST_SCRIPT_FILE_DIR=%TEST_SCRIPT_FILE_DIR:~0,-1%"
set "TEST_SCRIPT_FILE_DIR=%TEST_SCRIPT_FILE_DIR:\=/%"

set "TEST_SCRIPT_OUTPUT_DIR=%TEST_SCRIPT_FILE_DIR%/_output"

rem tests counter
set TESTLIB__TEST_COUNT=0

echo Running %?~nx0%...
title %?~nx0% %2 %3 %4 %5 %6 %7 %8 %9

set /A TESTLIB__NEST_LVL+=1

rem return code from user test script
set LASTERROR=0

rem return code from user test script implementation
set INTERRORLEVEL=0
