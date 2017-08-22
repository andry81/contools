@echo off

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a1" x "%%TEST_TEMP_DIR%%"
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a2" "" "%%TEST_TEMP_DIR%%"
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a3" "" "%%TEST_TEMP_DIR%%"
