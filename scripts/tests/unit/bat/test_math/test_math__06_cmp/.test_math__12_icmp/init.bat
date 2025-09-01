@echo off

set "L=%~1"
set "OP=%~2"
set "R=%~3"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 TEST_DATA_CMD_LINE %%*

exit /b 0
