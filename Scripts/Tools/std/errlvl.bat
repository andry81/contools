@if "%~1" == "" exit /b %ERRORLEVEL%
@exit /b %~1

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script returns error level passed as first argument. If first argument is
rem   empty, then returns previous error level.

rem Examples:
rem 1. call errlvl.bat 10
rem    echo ERRORLEVEL=%ERRORLEVEL%

rem CAUTION:
rem   The `exit /b %ERRORLEVEL%` is required as is to workaround the issue with
rem   not zero error code return:
rem
rem   ```1.bat
rem   @echo off
rem   
rem   setlocal
rem   
rem   call :TEST || exit /b
rem   exit /b 0
rem   
rem   :TEST
rem   exit /b 123
rem   ```
rem
rem   where:
rem
rem     >
rem     cmd.exe /c 1.bat
rem
rem     will always return 0
rem
rem   To workaround this:
rem
rem     >
rem     cmd.exe /c call 1.bat
rem
rem     Or
rem
rem     >
rem     cmd.exe /c "1.bat & call exit /b %%ERRORLEVEL%%"
rem
rem     Or
rem
rem     >
rem     cmd.exe /c "1.bat & "%%CONTOOLS_ROOT%%/std/errlvl.bat""
rem
rem     Or
rem
rem     >
rem     "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe /c 1.bat & \"${CONTOOLS_ROOT}/std/errlvl.bat\""
rem
rem     Or
rem
rem     >
rem     "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe /c \"1.bat ^& \"${CONTOOLS_ROOT}/std/errlvl.bat\"\""
rem
rem     Or
rem
rem     >
rem     "%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" /ret-child-exit "" "cmd.exe \"/c \"1.bat ^& \"${CONTOOLS_ROOT}/std/errlvl.bat\"\"\""

rem CAUTION:
rem   The `call` operator will expand environment variables twice:
rem
rem   >
rem   callf /v B x /v A %B% /ret-child-exit "" "cmd.exe /c call echo %A%"
rem 
rem   Prints `x` instead of `%B%`.
rem
rem   So to bypass this you must use variants without the `call` prefix before
rem   the `1.bat`.
