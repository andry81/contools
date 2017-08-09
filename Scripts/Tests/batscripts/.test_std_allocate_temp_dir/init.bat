@echo off

set "TEST_DATA_REF_DIR=%~1"
set "TEST_DATA_REF_DIR=%TEST_DATA_REF_DIR:\=/%"

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%TESTLIB__CURRENT_TESTS%.%RANDOM%_%RANDOM%"

call "%%CONTOOLS_ROOT%%/abspath.bat" "%%TEST_TEMP_BASE_DIR%%\%%TEST_TEMP_DIR_NAME%%"
set "TEST_TEMP_DIR=%RETURN_VALUE%"

if not defined TEST_TEMP_DIR exit /b 127

mkdir "%TEST_TEMP_DIR%"

exit /b 0
