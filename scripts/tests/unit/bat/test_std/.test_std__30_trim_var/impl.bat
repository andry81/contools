@echo off

call "%%CONTOOLS_ROOT%%/std/trim_var.bat" STRING_TO_TRIM STRING_TRIMMED
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
