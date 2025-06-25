@echo off

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "aaa" "a1" x "%%TEST_TEMP_DIR%%"
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "bbb" "b1" y "%%TEST_TEMP_DIR%%"
call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" "ccc" "c1" z "%%TEST_TEMP_DIR%%"
