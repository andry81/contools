@echo off

rem in place file
(
  call "%%CONTOOLS_ROOT%%/std/xcopy_file_rename.bat" "%%TEST_DATA_REF_DIR%%" "%%TEST_TEMP_DIR_PATH%%" input.txt inout.txt >nul
) || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=10" & goto EXIT )

rem builtin commands
(
  call "%%TEST_CONV_SCRIPT%%" %%TEST_DATA_CONV_SCRIPT_CMD_LINE%% "%%TEST_TEMP_DATA_INOUT_FILE%%"
) || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=20" & goto EXIT )

if not exist "%TEST_TEMP_DATA_INOUT_FILE%" set "TEST_LAST_ERROR=21" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_LAST_ERROR=22" & goto EXIT

"%SystemRoot%\System32\fc.exe" "%TEST_TEMP_DATA_INOUT_FILE%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_LAST_ERROR=23"

:EXIT
exit /b %TEST_LAST_ERROR%
