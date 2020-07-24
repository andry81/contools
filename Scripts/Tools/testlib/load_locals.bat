@echo off

call "%%CONTOOLS_ROOT%%/std/set_vars_from_locked_file_pair.bat" "%%TEST_SCRIPT_RETURN_LOCK_FILE_PATH%%" "%%TEST_SCRIPT_RETURN_VARS_FILE_PATH%%" "%%TEST_SCRIPT_RETURN_VALUES_FILE_PATH%%"
