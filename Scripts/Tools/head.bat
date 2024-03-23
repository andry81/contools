@echo off

rem Author:  Andrey Dibrov (andry at inbox dot ru)
rem
rem Description:
rem   Script prints N first lines from the input stream. If N is not set then all.
rem
rem Features:
rem   * Prints all characters including control characters like !%^&|> and so.
rem   * Does not consume empty lines.
rem
rem Issues:
rem   * findstr truncates lines longer than 8180 characters ("FINDSTR: Line NNN is too long" message)
rem   * Is not so fast, prints ~2000 lines about 8 seconds on 3.2GHz AMD processor

setlocal DISABLEDELAYEDEXPANSION

set "NUM=%~1"
if not defined NUM set NUM=0
set "STR_PREFIX=%~2"
set "STR_SUFFIX=%~3"

set LINE_INDEX=0

for /F "usebackq delims=" %%i in (`@"%%SystemRoot%%\System32\findstr.exe" /B /N /R /C:".*" 2^>nul`) do (
  set LINE_STR=%%i
  call :IF_OR_PRINT %%NUM%% NEQ 0 if %%LINE_INDEX%% GEQ %%NUM%% && exit /b 0
  set /A LINE_INDEX+=1
)

exit /b 0

:IF_OR_PRINT
if %* exit /b 0
setlocal ENABLEDELAYEDEXPANSION
set OFFSET=0
:OFFSET_LOOP
set CHAR=!LINE_STR:~%OFFSET%,1!
if not "!CHAR!" == ":" ( set /A OFFSET+=1 && goto OFFSET_LOOP )
set /A OFFSET+=1
echo.!STR_PREFIX!!LINE_STR:~%OFFSET%!!STR_SUFFIX!
exit /b 1
