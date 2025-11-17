@echo off

if %TEST_IMPL_ERROR% NEQ 0 goto EXIT

if not exist "%TEST_TEMP_DATA_INOUT_FILE%" set "TEST_IMPL_ERROR=10" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_IMPL_ERROR=20" & goto EXIT

"%SystemRoot%\System32\fc.exe" /B "%TEST_TEMP_DATA_INOUT_FILE%" "%TEST_DATA_REF_FILE%" >nul || ( set "TEST_IMPL_ERROR=30" & goto EXIT )

:EXIT
if %TEST_IMPL_ERROR% NEQ 0 (
  rem copy workingset on error
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_TEMP_DIR_PATH%%" "%%TEST_DATA_OUT_ROOT%%\%%TEST_TEMP_DIR_NAME%%" /Y /H /E >nul
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_dir.bat" "%%TEST_DATA_REF_DIR%%"  "%%TEST_DATA_OUT_ROOT%%\%%TEST_TEMP_DIR_NAME%%\reference\%%TEST_DATA_FILE_IN_OUT_DIR%%" /Y /H /E >nul
)

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %TEST_IMPL_ERROR%
