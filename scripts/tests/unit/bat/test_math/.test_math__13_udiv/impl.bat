@echo off

call "%%CONTOOLS_ROOT%%/math/udiv.bat" %%TEST_DATA_CMD_LINE%%
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
