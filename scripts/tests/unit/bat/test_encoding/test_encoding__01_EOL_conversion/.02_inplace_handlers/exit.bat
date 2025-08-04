@echo off

if %TEST_LAST_ERROR% NEQ 0 (
  rem copy workingset on error
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_TEMP_DIR_PATH%%" "%%TEST_DATA_OUT_ROOT%%\%%TEST_TEMP_DIR_NAME%%" /Y /H /E >nul
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_REF_DIR%%"  "%%TEST_DATA_OUT_ROOT%%\%%TEST_TEMP_DIR_NAME%%\reference\%%TEST_DATA_FILE_IN_OUT_DIR%%" /Y /H /E >nul
)

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"
