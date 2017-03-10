@echo off

call :OUT_OF_MEMORY ^^
exit /b

:OUT_OF_MEMORY
call set __DUMMY=%%1
