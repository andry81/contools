@echo off

call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v
set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
