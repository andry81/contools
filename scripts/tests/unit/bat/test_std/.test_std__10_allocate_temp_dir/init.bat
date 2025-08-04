@echo off

set "TEST_DATA_REF_DIR=%~1"

if not defined TEST_DATA_REF_DIR exit /b 255

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%TESTLIB__OVERALL_TESTS%.%TESTLIB__CURRENT_TESTS%.%RANDOM%-%RANDOM%"

call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_TEMP_DIR           "%%TEST_DATA_TEMP_ROOT%%\%%TEST_TEMP_DIR_NAME%%"
call "%%CONTOOLS_ROOT%%/std/canonical_path.bat" TEST_DATA_REF_DIR_PATH  "%%TEST_DATA_IN_ROOT%%\%%TEST_SCRIPT_FILE_NAME%%\%%TEST_DATA_REF_DIR%%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEST_TEMP_DIR%%" >nul || exit /b 127

exit /b 0
