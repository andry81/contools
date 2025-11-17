@echo off

call "%%CONTOOLS_ROOT%%/extract_version.bat" "%%VERSION_IN%%" %%TEST_VA_ARGS%%
set "TEST_IMPL_ERROR=%ERRORLEVEL%"
set "VERSION_RETURNED=%RETURN_VALUE%"

exit /b 0
