@echo off

(
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/gen_config.bat" %%GEN_CONFIG_FLAGS%% -- . . "%%GEN_CONFIG_FILE_NAME%%"
) >nul

set "TEST_IMPL_ERROR=%ERRORLEVEL%"

if %TEST_IMPL_ERROR% NEQ 0 goto EXIT

if not exist "%TEST_TEMP_DATA_OUT_FILE%" set "TEST_IMPL_ERROR=10" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_IMPL_ERROR=20" & goto EXIT

"%SystemRoot%\System32\fc.exe" /B "%TEST_TEMP_DATA_OUT_FILE%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_IMPL_ERROR=30"

:EXIT
exit /b 0
