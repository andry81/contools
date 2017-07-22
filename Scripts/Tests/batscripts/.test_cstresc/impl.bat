@echo off

call "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__STRING__%%" STRING_ESCAPED "%%__CHARS__%%"
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

exit /b 0
