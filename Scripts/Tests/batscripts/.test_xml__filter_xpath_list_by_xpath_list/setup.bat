@echo off

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%TEST_SCRIPT_FILE_NAME%%" "" "%%TEST_TEMP_BASE_DIR%%"

set "TEST_TEMP_DIR_NAME=%TEST_SCRIPT_FILE_NAME%.%SCRIPT_TEMP_ROOT_DATE%.%SCRIPT_TEMP_ROOT_TIME%"
set "TEST_TEMP_DIR_PATH=%SCRIPT_TEMP_CURRENT_DIR%"

rem initialize setup parameters
call "%%CONTOOLS_ROOT%%/abspath.bat" "%%TEST_TEMP_DIR_PATH%%\output.txt"
set "TEST_DATA_OUT_FILE=%RETURN_VALUE%"
