@echo off

rem USAGE:
rem   list-junction-points.bat <from-path> > <links-list-file>

setlocal

set "FROM_PATH=%~1"

if not defined FROM_PATH set "FROM_PATH=."

for /F "eol= tokens=* delims=" %%i in ("%FROM_PATH%\.") do set "FROM_PATH=%%~fi" & set "FROM_DRIVE=%%~di"

dir "%FROM_PATH%" /A:L /B /O:N /S 2>nul
