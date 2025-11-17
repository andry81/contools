@echo off

call "%%CONTOOLS_ROOT%%/std/get_cmdline_var_len.bat" %%FLAGS%% CMDLINE
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
