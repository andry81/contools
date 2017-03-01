@echo off

set RETURN_VALUE=-1

call :MAIN %%* 2>nul
goto :EOF

:MAIN
setlocal

set "SESSION_NAME=%~1" 
set "USER_NAME=%~2"

set LINE_INDEX=0

call :PROCESS_QUERY_FOR_LOOP %%*
set LASTERROR=%ERRORLEVEL%

rem echo RETURN_VALUE=%RETURN_VALUE%

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b %LASTERROR%

:PROCESS_QUERY_FOR_LOOP
for /F "usebackq delims=" %%i in (`query session 2^>nul`) do ( call :PROCESS_QUERY "%%%%i" || goto :EOF )
exit /b -1

:PROCESS_QUERY
set LASTERROR=0

if 0%LINE_INDEX% EQU 0 goto PROCESS_QUERY_END

set "LINE_STR=%~1"

for /F "tokens=1,* delims= " %%j in ("%LINE_STR:~1%") do set "SESSION=%%j"

if "%SESSION_NAME%" == "" goto SESSION_NAME_FOUND

call set "SESSION_NAME_PARSED=%%SESSION:%SESSION_NAME%=%%"

if not "%SESSION_NAME_PARSED%" == "%SESSION%" goto SESSION_NAME_FOUND
goto PROCESS_QUERY_END

:SESSION_NAME_FOUND
for /F "delims=" %%j in ("%LINE_STR:~19,20%") do set "USER=%%j"
rem spaces filter
for /F "tokens=1,* delims= " %%j in ("%USER%") do set "USER=%%j"
for /F "tokens=* delims= " %%j in ("%USER%") do set "USER=%%j"

if "%USER_NAME%" == "" goto USER_NAME_FOUND
if /i "%USER%" == "%USER_NAME%" goto USER_NAME_FOUND
goto PROCESS_QUERY_END

:USER_NAME_FOUND
set LASTERROR=1

for /F "tokens=1,* delims= " %%j in ("%LINE_STR:~40%") do set "RETURN_VALUE=%%j"

:PROCESS_QUERY_END
set /A LINE_INDEX+=1

exit /b %LASTERROR%
