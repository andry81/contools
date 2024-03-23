@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls external command line under the lock (a file redirection
rem   trick) in a temporary directory. If lock was holden before the call
rem   then the call just ignores and the script returns negative error code.

setlocal

set LAST_ERROR=0

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%"
) else set "TEMP_DIR=%TEMP%"

rem cleanup if leaked by crash or ctrl-c, won't be removed if already acquired because of write redirection lock
rmdir /S /Q "%TEMP_DIR%\lock.%~1" >nul 2>nul

mkdir "%TEMP_DIR%\lock.%~1" && (
  rem IMPL to use "exit /b" in next command instead of "exit /b %ERRORLEVEL%" under "block" command - "( )"
  call :IMPL %%*
  exit /b
)
exit /b -1024

:IMPL
rem call IMPL2 to recover exit code from commands like "exit /b"
call :IMPL2 %%* 9> "%TEMP_DIR%\lock.%~1\lock0.%RANDOM%-%RANDOM%.txt"
set LAST_ERROR=%ERRORLEVEL%
rmdir /S /Q "%TEMP_DIR%\lock.%~1" >nul 2>nul
exit /b %LAST_ERROR%

:IMPL2
if "%~n2" == "bat" (
  call %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
  exit /b
) else if "%~n2" == "cmd" (
  call %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
  exit /b
)

(
  %2 %3 %4 %5 %6 %7 %8 %9
)

exit /b
