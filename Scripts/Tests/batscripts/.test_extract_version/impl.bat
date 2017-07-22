@echo off

call "%%CONTOOLS_ROOT%%/extract_version.bat" "%%VERSION_IN%%" %%TEST_DATA_CMD_LINE%%
set "ERRORLEVEL_RETURNED=%ERRORLEVEL%"
set "VERSION_RETURNED=%RETURN_VALUE%"

exit /b 0
