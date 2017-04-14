@echo off

setlocal

rem load environment variables
call "%%~dp0Tools\setvarsfromfile.bat" "%%~dp0local.vars"

if not "%~1" == "" set "SERVER_USER=%~1"

rem get logged in console session
call "%%~dp0Tools\query_session_id.bat" console "%%SERVER_USER%%" Active
if %RETURN_VALUE% NEQ -1 goto FOUND

rem get logged in RDP session
call "%%~dp0Tools\query_session_id.bat" rdp "%%SERVER_USER%%" Active
if %RETURN_VALUE% NEQ -1 goto FOUND

rem session can be empty if a user is not logged in, but the terminal has user logged in processes
call "%%~dp0Tools\query_session_id.bat" "" "%%SERVER_USER%%" Disc
if %RETURN_VALUE% NEQ -1 goto FOUND

rem get any console session
call "%%~dp0Tools\query_session_id.bat" console "" Conn
if %RETURN_VALUE% NEQ -1 goto FOUND

rem get any services session
call "%%~dp0Tools\query_session_id.bat" services "" Disc
if %RETURN_VALUE% NEQ -1 goto FOUND


exit /b -128

:FOUND
echo.%RETURN_VALUE%
exit /b 0
