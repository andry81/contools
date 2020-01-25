@echo off

setlocal

set "RUNNING_TASKS_COUNTER_LOCK_FILE0=%~1"
set "RUNNING_TASKS_COUNTER_FILE0=%~2"

if not defined LASTERROR set LASTERROR=0

set /P "FILE_PATH_0="
set /P "FILE_PATH_1="

if %FLAG_ARAXIS% NEQ 0 goto ARAXIS_CONSOLE_COMPARE_TOOL
if %FLAG_WINMERGE% NEQ 0 goto WINMERGE_COMPARE_TOOL

:ARAXIS_CONSOLE_COMPARE_TOOL
call :CMD start /B /WAIT "" "%%ARAXIS_CONSOLE_COMPARE_TOOL%%"%%BARE_FLAGS%% /wait "%%FILE_PATH_0%%" "%%FILE_PATH_1%%"
rem call :CMD start /B "" "%%ARAXIS_CONSOLE_COMPARE_TOOL%%"%%BARE_FLAGS%% /nowait "%%FILE_PATH_0%%" "%%FILE_PATH_1%%"

if %ERRORLEVEL% NEQ 0 if %LASTERROR% EQU 0 set LASTERROR=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/locks/decr_var_file.bat" 0 "%%RUNNING_TASKS_COUNTER_LOCK_FILE0%%" "%%RUNNING_TASKS_COUNTER_FILE0%%"

exit /b

:WINMERGE_COMPARE_TOOL
if %FLAG_WAIT_SINGLE_COMPARE% NEQ 0 (
call :CMD start /B /WAIT "" "%%WINMERGE_COMPARE_TOOL%%"%%BARE_FLAGS%% "%%FILE_PATH_0%%" "%%FILE_PATH_1%%"

if %ERRORLEVEL% NEQ 0 if %LASTERROR% EQU 0 set LASTERROR=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/locks/decr_var_file.bat" 0 "%%RUNNING_TASKS_COUNTER_LOCK_FILE0%%" "%%RUNNING_TASKS_COUNTER_FILE0%%"

exit /b

:CMD
echo.^>%*
(%*)