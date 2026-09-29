@echo off

call :SETERR %%TEST_PREV_ERROR%%

call "%%CONTOOLS_ROOT%%/std/set_var.bat" "%%LVAR%%" "%%RVAR%%"
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0

:SETERR
exit /b %*
