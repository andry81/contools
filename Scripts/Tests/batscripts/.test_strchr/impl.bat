@echo off

call "%%CONTOOLS_ROOT%%/strchr.bat" /v "" "" %%STRING_OFFSET%%
set ERRORLEVEL_RETURNED=%ERRORLEVEL%

exit /b 0
