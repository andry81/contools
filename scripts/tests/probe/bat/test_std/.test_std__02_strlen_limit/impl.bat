@echo off

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v "%%STRING_VAR%%"
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
