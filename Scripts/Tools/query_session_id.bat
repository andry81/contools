@echo off

set RETURN_VALUE=-1

call :MAIN %%* 2>nul
goto :EOF

:MAIN
setlocal

set "SESSION_NAME=%~1" 
set "USER_NAME=%~2"
set "STATE_NAME=%~3"

for /F "usebackq eol=	 tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

if not "%LAST_CODE_PAGE%" == "65001" chcp %CODE_PAGE% >nul

set LINE_INDEX=0

call :PROCESS_QUERY_FOR_LOOP %%*
set LASTERROR=%ERRORLEVEL%

rem echo RETURN_VALUE=%RETURN_VALUE%

if not "%LAST_CODE_PAGE%" == "65001" chcp %LAST_CODE_PAGE% >nul

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
)

exit /b %LASTERROR%

:PROCESS_QUERY_FOR_LOOP
for /F "usebackq eol=	 tokens=* delims=" %%i in (`query session 2^>nul`) do (
  set "QUERY_LINE=%%i"
  call :PROCESS_QUERY || goto :EOF
)
exit /b -1

:PROCESS_QUERY
set LASTERROR=0
set SESSION_FOUND=0

if 0%LINE_INDEX% EQU 0 goto PROCESS_QUERY_END

for /F "eol=	 tokens=1,* tokens=* delims= " %%j in ("%QUERY_LINE:~1%") do set "SESSION=%%j"

if "%SESSION_NAME%" == "*" goto SESSION_NAME_FOUND

rem session can be empty if a user is not logged in, but the terminal has user logged in processes
if "%SESSION_NAME%" == "" (
  if "%SESSION%" == "" goto SESSION_NAME_FOUND
  goto PROCESS_QUERY_END
) else if "%SESSION%" == "" goto PROCESS_QUERY_END

call set "SESSION_NAME_PARSED=%%SESSION:%SESSION_NAME%=%%"

if not "%SESSION_NAME_PARSED%" == "%SESSION%" goto SESSION_NAME_FOUND
goto PROCESS_QUERY_END

:SESSION_NAME_FOUND
for /F "eol=	 tokens=* delims= " %%j in ("%QUERY_LINE:~19,20%") do set "USER=%%j"
rem spaces filter
for /F "eol=	 tokens=1,* delims= " %%j in ("%USER%") do set "USER=%%j"
for /F "eol=	 tokens=* delims= " %%j in ("%USER%") do set "USER=%%j"

if "%USER_NAME%" == "" goto USER_NAME_FOUND
if /i "%USER%" == "%USER_NAME%" goto USER_NAME_FOUND
goto PROCESS_QUERY_END

:USER_NAME_FOUND
set SESSION_ID=1

for /F "eol=	 tokens=* delims= " %%j in ("%QUERY_LINE:~41,5%") do set "SESSION_ID=%%j"
rem spaces filter
for /F "eol=	 tokens=1,* delims= " %%j in ("%SESSION_ID%") do set "SESSION_ID=%%j"
for /F "eol=	 tokens=* delims= " %%j in ("%SESSION_ID%") do set "SESSION_ID=%%j"

:SESSION_ID_FOUND
set "SESSION_STATE="

for /F "eol=	 tokens=* delims= " %%j in ("%QUERY_LINE:~48,6%") do set "SESSION_STATE=%%j"
rem spaces filter
for /F "eol=	 tokens=1,* delims= " %%j in ("%SESSION_STATE%") do set "SESSION_STATE=%%j"
for /F "eol=	 tokens=* delims= " %%j in ("%SESSION_STATE%") do set "SESSION_STATE=%%j"

if "%STATE_NAME%" == "*" goto SESSION_STATE_FOUND

if "%STATE_NAME%" == "" (
  if "%SESSION_STATE%" == "" goto SESSION_STATE_FOUND
  goto PROCESS_QUERY_END
) else if "%SESSION_STATE%" == "" goto PROCESS_QUERY_END

if /i "%STATE_NAME%" == "%SESSION_STATE%" goto SESSION_STATE_FOUND
goto PROCESS_QUERY_END

:SESSION_STATE_FOUND
set SESSION_FOUND=1

:PROCESS_QUERY_END
set /A LINE_INDEX+=1

if %SESSION_FOUND% NEQ 0 exit /b %SESSION_ID%
exit /b 0
