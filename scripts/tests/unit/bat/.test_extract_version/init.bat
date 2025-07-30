@echo off

set "VERSION_REF=%~1"
set "VERSION_IN=%~2"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 2 TEST_DATA_CMD_LINE %%*

exit /b 0
