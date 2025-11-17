@echo off

rem in place file
(
  call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" "%%TEST_DATA_REF_DIR%%" "%%TEST_TEMP_DIR_PATH%%" input.txt inout.txt >nul
) >nul
set "TEST_IMPL_ERROR=%ERRORLEVEL%"

if %TEST_IMPL_ERROR% NEQ 0 goto EXIT

call "%%TEST_CONV_SCRIPT%%" %%TEST_DATA_CONV_SCRIPT_CMD_LINE%% "%%TEST_TEMP_DATA_INOUT_FILE%%"
set "TEST_IMPL_ERROR=%ERRORLEVEL%"

:EXIT
exit /b 0
