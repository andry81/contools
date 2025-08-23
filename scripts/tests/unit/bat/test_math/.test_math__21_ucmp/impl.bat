@echo off

call "%%CONTOOLS_ROOT%%/math/ucmp.bat" %%TEST_DATA_CMD_LINE%%
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
