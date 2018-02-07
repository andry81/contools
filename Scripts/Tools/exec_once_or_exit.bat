@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls external command line under the lock (a file redirection
rem   trick) in a temporary directory. If lock was holden before the call
rem   then the call just ignores and the script returns negative error code.

setlocal

call "%%~dp0get_datetime.bat"

set "LOCK_DIR_NAME_SUFFIX=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%.%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"
set LASTERROR=0

rem cleanup if leaked by crash or ctrl-c, won't be removed if already acquired because of write redirection lock
rmdir /S /Q "%TEMP%\lock.%~1" >nul 2>&1

mkdir "%TEMP%\lock.%~1" && (
  rem IMPL to use "goto :EOF" in next command instead of "exit /b %ERRORLEVEL%" under "block" command - "( )"
  call :IMPL %%*
  goto :EOF
)
exit /b -1024

:IMPL
rem call IMPL2 to recover exit code from commands like "exit /b"
call :IMPL2 %%* 9> "%TEMP%\lock.%~1\lock0.%LOCK_DIR_NAME_SUFFIX%.txt"
set LASTERROR=%ERRORLEVEL%
rmdir /S /Q "%TEMP%\lock.%~1" >nul 2>&1
exit /b %LASTERROR%

:IMPL2
if "%~n2" == "bat" (
  call %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
  goto :EOF
) else if "%~n2" == "cmd" (
  call %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
  goto :EOF
)

(
  %2 %3 %4 %5 %6 %7 %8 %9
)

goto :EOF
