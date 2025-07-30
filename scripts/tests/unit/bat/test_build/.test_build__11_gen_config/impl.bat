@echo off

rem builtin commands
(
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/gen_config.bat" %%GEN_CONFIG_FLAGS_CMD_LINE%% -- . . "%%GEN_CONFIG_FILE_NAME%%"
) >nul || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=20" & goto EXIT )

if not exist "%TEST_TEMP_DATA_OUT_FILE%" set "TEST_LAST_ERROR=21" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_LAST_ERROR=22" & goto EXIT

"%SystemRoot%\System32\fc.exe" "%TEST_TEMP_DATA_OUT_FILE%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_LAST_ERROR=23"

:EXIT
if %TEST_LAST_ERROR% EQU 0 (
  echo PASSED: %TESTLIB__TEST_ORDER_NUMBER%
) else echo FAILED: %TESTLIB__TEST_ORDER_NUMBER%

echo;

exit /b %TEST_LAST_ERROR%
