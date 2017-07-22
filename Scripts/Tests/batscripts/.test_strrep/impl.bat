@echo off

call "%%CONTOOLS_ROOT%%/strrep.bat" /v "" "" ESCAPED_STRING
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

exit /b 0
