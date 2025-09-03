@echo off

set "LVAR=%~1"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 TEST_DATA_CMD_LINE %%*

exit /b 0
