@echo off

call :CANONICAL_PATH TESTS_ROOT "%%~dp0"

rem initialize Tools "module"
call "%%TESTS_ROOT%%/../../Tools/__init__.bat" || exit /b

rem initialize testlib "module"
call "%%CONTOOLS_ROOT%%/testlib/__init__.bat" || exit /b

call :CANONICAL_PATH TEST_SRC_BASE_DIR  "%%TESTS_ROOT%%"
call :CANONICAL_PATH TEST_DATA_BASE_DIR "%%TEST_SRC_BASE_DIR%%/_testdata"
call :CANONICAL_PATH TEST_TEMP_BASE_DIR "%%TEST_SRC_BASE_DIR%%/../../../Temp"

exit /b 0

:CANONICAL_PATH
set "%~1=%~dpf2"
call set "%%~1=%%%~1:\=/%%"
exit /b 0
