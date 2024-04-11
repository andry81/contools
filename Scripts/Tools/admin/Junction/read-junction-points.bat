@echo off

setlocal DISABLEDELAYEDEXPANSION

rem CAUTION:
rem   If a variable is empty, then it would not be expanded in the `cmd.exe` command line or in case of `for /F ...`!
rem   We must expand the command line into a variable.
rem
set ?.=@dir "%~1\.." /A:L 2^>nul ^| "%SystemRoot%\System32\findstr.exe" /R /C:"\[.*\]"

for /F "usebackq eol= tokens=* delims=" %%i in ("%~1") do for /F "usebackq eol= tokens=4,* delims= " %%j in (`%%?.%%`) do if "%%~ni" == "%%j" ( set "J=%%k" & call echo.%%i*%%J:~1,-1%%)
