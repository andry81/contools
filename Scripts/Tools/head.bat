@echo off

setlocal DISABLEDELAYEDEXPANSION

set "NUM=%~1"
if "%NUM%" == "" set NUM=0

set LINE_INDEX=0

for /F "usebackq delims=" %%i in (`findstr /B /N /R /C:".*"`) do (
  set LINE_STR=%%i
  call :IF_OR_PRINT %%NUM%% NEQ 0 if %%LINE_INDEX%% GEQ %%NUM%% && exit /b 0
  set /A LINE_INDEX+=1
)

exit /b

:IF_OR_PRINT
if %* exit /b 0
setlocal ENABLEDELAYEDEXPANSION
set OFFSET=0
:OFFSET_LOOP
set CHAR=!LINE_STR:~%OFFSET%,1!
if not "!CHAR!" == ":" ( set /A OFFSET+=1 && goto OFFSET_LOOP )
set /A OFFSET+=1
echo.!LINE_STR:~%OFFSET%!
exit /b 1
