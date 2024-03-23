@echo off

set RETURN_VALUE=-1

call :MAIN %%* 2>nul
exit /b

:MAIN
setlocal

set "SESSION_NAME=%~1" 
set "USER_NAME=%~2"
set "STATE_NAME=%~3"

rem get and set code page
call "%%CONTOOLS_ROOT%%/std/chcp.bat" 65001

set LINE_INDEX=0
set SESSION_ID=0
set SESSION_FOUND=0

call :PROCESS_QUERY_FOR_LOOP %%*
set LAST_ERROR=%ERRORLEVEL%

rem echo RETURN_VALUE=%RETURN_VALUE%

rem restore code page
call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b %LAST_ERROR%

:PROCESS_QUERY_FOR_LOOP
for /F "usebackq eol= tokens=* delims=" %%i in (`query session 2^>nul`) do (
  set "QUERY_LINE=%%i"
  call :PROCESS_QUERY || exit /b 0
)
exit /b -1

:PROCESS_QUERY
if 0%LINE_INDEX% EQU 0 goto PROCESS_QUERY_END

for /F "eol= tokens=1,* delims= " %%j in ("%QUERY_LINE:~1%") do set "SESSION=%%j"

if "%SESSION_NAME%" == "*" goto SESSION_NAME_FOUND

rem session can be empty if a user is not logged in, but the terminal has user logged in processes
if not defined SESSION_NAME (
  if not defined SESSION goto SESSION_NAME_FOUND
  goto PROCESS_QUERY_END
) else if not defined SESSION goto PROCESS_QUERY_END

call set "SESSION_NAME_PARSED=%%SESSION:%SESSION_NAME%=%%"

if not "%SESSION_NAME_PARSED%" == "%SESSION%" goto SESSION_NAME_FOUND
goto PROCESS_QUERY_END

:SESSION_NAME_FOUND
for /F "eol= tokens=* delims= " %%j in ("%QUERY_LINE:~19,20%") do set "USER=%%j"
rem spaces filter
for /F "eol= tokens=1,* delims= " %%j in ("%USER%") do set "USER=%%j"
for /F "eol= tokens=* delims= " %%j in ("%USER%") do set "USER=%%j"

if not defined USER_NAME goto USER_NAME_FOUND
if /i "%USER%" == "%USER_NAME%" goto USER_NAME_FOUND
goto PROCESS_QUERY_END

:USER_NAME_FOUND
for /F "eol= tokens=* delims= " %%j in ("%QUERY_LINE:~41,5%") do set "SESSION_ID=%%j"
rem spaces filter
for /F "eol= tokens=1,* delims= " %%j in ("%SESSION_ID%") do set "SESSION_ID=%%j"
for /F "eol= tokens=* delims= " %%j in ("%SESSION_ID%") do set "SESSION_ID=%%j"

:SESSION_ID_FOUND
set "SESSION_STATE="

for /F "eol= tokens=* delims= " %%j in ("%QUERY_LINE:~48,6%") do set "SESSION_STATE=%%j"
rem spaces filter
for /F "eol= tokens=1,* delims= " %%j in ("%SESSION_STATE%") do set "SESSION_STATE=%%j"
for /F "eol= tokens=* delims= " %%j in ("%SESSION_STATE%") do set "SESSION_STATE=%%j"

if "%STATE_NAME%" == "*" goto SESSION_STATE_FOUND

if not defined STATE_NAME (
  if not defined SESSION_STATE goto SESSION_STATE_FOUND
  goto PROCESS_QUERY_END
) else if not defined SESSION_STATE goto PROCESS_QUERY_END

if /i "%STATE_NAME%" == "%SESSION_STATE%" goto SESSION_STATE_FOUND
goto PROCESS_QUERY_END

:SESSION_STATE_FOUND
set SESSION_FOUND=1
set "RETURN_VALUE=%SESSION_ID%"

:PROCESS_QUERY_END
set /A LINE_INDEX+=1

if %SESSION_FOUND% NEQ 0 exit /b 1
exit /b 0
