@echo off

set "TESTS_ROOT=%~dp0"
set "TESTS_ROOT=%TESTS_ROOT:~0,-1%"
set "TESTS_ROOT=%TESTS_ROOT:\=/%"

rem initialize Tools "module"
call "%%TESTS_ROOT%%/../../Tools/__init__.bat" || exit /b

rem initialize testlib "module"
call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

set "TEST_SRC_BASE_DIR=%TESTS_ROOT%"

set "TEST_DATA_BASE_DIR=%TEST_SRC_BASE_DIR%/_testdata"
set "TEST_TEMP_BASE_DIR=%TEST_SRC_BASE_DIR%/../../../Temp"

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%"
set "TEST_DATA_BASE_DIR=%RETURN_VALUE%"

exit /b 0

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0
