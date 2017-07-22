@echo off

call "%%CONTOOLS_ROOT%%/strlen.bat" /v
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

exit /b 0
