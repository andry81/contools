@echo off

rem CAUTION:
rem   When the 65000 codepage is used then some of characters DOES BECOME
rem   CONTROL CHARACTERS!
rem   For example, the plus character (`+`) becomes the unicode codepoint
rem   prefix character and expressions which contain this character like
rem   `set BLABLA=1+1` WILL FAIL!

setlocal

rem drop last error level
type nul>nul

set "CODE_PAGE=%~1"

if not defined CODE_PAGE exit /b -255
if not defined CURRENT_CP goto INIT

set "LAST_CP=%CURRENT_CP%"
if defined CP_HISTORY_LIST (
  set "CP_HISTORY_LIST=%CURRENT_CP%|%CP_HISTORY_LIST%"
) else (
  set "CP_HISTORY_LIST=%CURRENT_CP%|"
)
set "CURRENT_CP=%CODE_PAGE%"

goto UPDATECP

:INIT
set "LAST_CP="
set "CURRENT_CP=%CODE_PAGE%"
for /F "usebackq eol=	 tokens=1,* delims=:" %%i in (`chcp.com 2^>nul`) do set "LAST_CP=%%j"
if defined LAST_CP set "LAST_CP=%LAST_CP: =%"
if defined LAST_CP set "CP_HISTORY_LIST=%LAST_CP%|"

:UPDATECP
if not "%CURRENT_CP%" == "%LAST_CP%" chcp.com %CURRENT_CP% >nul

:EXIT
(
  endlocal
  set "LAST_CP=%LAST_CP%"
  set "CURRENT_CP=%CURRENT_CP%"
  set "CP_HISTORY_LIST=%CP_HISTORY_LIST%"
)

exit /b 0
