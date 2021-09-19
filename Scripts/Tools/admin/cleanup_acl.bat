@echo off

rem Description:
rem   Script reads input FILE_IN ACL file list and filters out records with
rem   not existen directories in the SRC_DIR directory.

setlocal

set "FILE_IN=%~f1"
set "SRC_DIR=%~f2"

if not defined FILE_IN exit /b 1
if not exist "%FILE_IN%" exit /b 2
if not defined SRC_DIR exit /b 3
if not exist "%SRC_DIR%\" exit /b 4

set LINE_INDEX=0
set IGNORE_LINE=0

for /F "usebackq tokens=* delims=" %%i in ("%FILE_IN%") do (
  set "LINESTR=%%i"
  call :PARSE_LINE
)

exit /b 0

:PARSE_LINE
if %IGNORE_LINE% NEQ 0 (
  set IGNORE_LINE=0
  goto PARSE_LINE_EXIT
)
set /A LINE_OFFSET=LINE_INDEX %% 2
if %LINE_OFFSET% NEQ 0 goto PARSE_LINE_PRINT

if not exist "%SRC_DIR%\%LINESTR%" (
  set IGNORE_LINE=1
  goto PARSE_LINE_EXIT
)

:PARSE_LINE_PRINT
set "LINESTR=%LINESTR:)=^)%"
echo.%LINESTR%

:PARSE_LINE_EXIT
set /A LINE_INDEX+=1

exit /b
