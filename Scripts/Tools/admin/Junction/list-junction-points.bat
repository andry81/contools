@echo off

setlocal

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir %* /A:L /B 2^>nul

for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do echo.%%i
