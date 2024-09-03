@echo off

rem USAGE:
rem   read-junction-points.bat <from-path> > <junction-list-file>

setlocal DISABLEDELAYEDEXPANSION

set "FROM_PATH=%~1"

if not defined FROM_PATH set "FROM_PATH=."

for /F "eol= tokens=* delims=" %%i in ("%FROM_PATH%\.") do set "FROM_PATH=%%~fi" & set "FROM_DRIVE=%%~di"

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
set ?.=@dir "%FROM_PATH%" /A:L /O:N /S 2^>nul ^| "%SystemRoot%\System32\findstr.exe" /R /C:"[^ ][^ ]*  *[^ ][^ ]*  *\<JUNCTION\>" /C:"[^ ][^ ]*  *[^ ][^ ]*  *\<SYMLINKD\>" /C:"^ Directory of "

for /F "usebackq eol= tokens=* delims=" %%i in (`%%?.%%`) do set "LINE=%%i" & call :PROCESS_LINE
exit /b 0

:PROCESS_LINE
if not "%LINE:~0,14%" == " Directory of " goto PROCESS_DIR
set "FROM_DIR=%LINE:~14%"
if "%FROM_DIR:~-1%" == "\" set "FROM_DIR=%FROM_DIR:~0,-1%"
exit /b 0
:PROCESS_DIR
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=3,* delims= " %%i in ("!LINE!") do endlocal & set "LINE=%%j" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=1,* delims=:" %%i in ("!LINE!") do endlocal & set "LINK=%%i" & set "DIR=%%j" & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "eol= tokens=1,* delims=|" %%i in ("!FROM_DIR!\!LINK:~0,-3!|!LINK:~-1!!DIR:~0,-1!") do endlocal & echo.%%i*%%j
