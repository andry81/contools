@echo off

set "STRING_OFFSET=%~1"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 1 TEST_DATA_CMD_LINE %%*

exit /b 0
