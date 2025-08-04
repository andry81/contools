@echo off

rem builtin commands
(
  call "%%TEST_CONV_SCRIPT%%" %%TEST_DATA_CONV_SCRIPT_CMD_LINE%% "%%TEST_DATA_IN_FILE%%"
) > "%TEST_TEMP_DATA_OUT_FILE%" || ( call set "TEST_IMPL_ERROR=%%ERRORLEVEL%%" & set "TEST_LAST_ERROR=20" & goto EXIT )

if not exist "%TEST_TEMP_DATA_OUT_FILE%" set "TEST_LAST_ERROR=21" & goto EXIT
if not exist "%TEST_DATA_REF_FILE%" set "TEST_LAST_ERROR=22" & goto EXIT

"%SystemRoot%\System32\fc.exe" "%TEST_TEMP_DATA_OUT_FILE%" "%TEST_DATA_REF_FILE%" >nul || set "TEST_LAST_ERROR=23"

:EXIT
exit /b %TEST_LAST_ERROR%
