@echo off

set "TEST_DATA_FILE_IN_OUT_DIR=%~1"

if not defined TEST_DATA_FILE_IN_OUT_DIR exit /b 255

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 1 TEST_DATA_SED_CMD_LINE %%*

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_DATA_TEMP_ROOT%%" || exit /b

set "TEST_TEMP_DIR_NAME=%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%.%TESTLIB__OVERALL_TESTS%.%TESTLIB__CURRENT_TESTS%.%TEST_SCRIPT_FILE_NAME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DATA_OUT_FILE "%%TEST_TEMP_DIR_PATH%%\output.txt"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR       "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_FILE_IN_OUT_DIR%%"

set "TEST_DATA_IN_FILE=%TEST_DATA_REF_DIR%\input.txt"
set "TEST_DATA_REF_FILE=%TEST_DATA_REF_DIR%\output.txt"

exit /b 0
