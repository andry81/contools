@echo off

set "OUTVAR=%~1"
set "INVAR=%~2"
set "VALUE=%~3"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 TEST_DATA_CMD_LINE %%*

exit /b 0
