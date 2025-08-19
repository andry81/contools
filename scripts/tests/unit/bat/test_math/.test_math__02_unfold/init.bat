@echo off

set OUTDEF=0
set INDEF=0

if not "%~1" == "" set OUTDEF=1
if not "%~2" == "" set INDEF=1

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 0 TEST_DATA_CMD_LINE %%*

exit /b 0
