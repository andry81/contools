@echo off

setlocal DISABLEDELAYEDEXPANSION

rem CAUTION:
rem   1. If a variable is empty, then it would not be expanded in the `cmd.exe`
rem      command line or in the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement.
rem   2. The `cmd.exe` command line or the inner expression of the
rem      `for /F "usebackq ..." %%i in (`<inner-expression>`) do ...`
rem      statement does expand twice.
rem
rem   We must expand the command line into a variable to avoid these above.
rem
set ?.=@dir "%~1\.." /A:L 2^>nul ^| "%SystemRoot%\System32\findstr.exe" /R /C:"\[.*\]"

for /F "usebackq eol= tokens=* delims=" %%i in ("%~1") do for /F "usebackq eol= tokens=4,* delims= " %%j in (`%%?.%%`) do if "%%~ni" == "%%j" ( set "J=%%k" & call echo.%%i*%%J:~1,-1%%)
