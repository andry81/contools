@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script reads standard output to variable STDOUT_VALUE.
rem   Command "for" ignores empty strings until not empty string appear.
rem   Additionally all spaces before non empty value does trim.
rem   If STDOUT_VALUE is empty, when error level sets to 1, otherwise - 0.
rem   If you try to call a script (*.bat), you can doesn't prefix name of
rem   script with "call" operator because script anyway runs under child
rem   cmd.exe process and it's return code ignores by "for" command.
rem
rem   Beware of triple expansion of all the script arguments -
rem   first expansion before any evaluation in batch scripts, second expansion
rem   because of "call" prefix to the script name and third expansion because
rem   of nature of command "for". So you should escape all potentially
rem   expandable characters BEFORE pass them into the script arguments!
rem   Exception is string quoting character - ", because of nature of the
rem   variable %* (it preserves % character as is).

rem Examples:
rem 1. call setvarfromstd.bat echo 10
rem    echo STDOUT_VALUE=%STDOUT_VALUE%

if "%~1" == "" exit /b 65

rem Drop last error level
call;

rem Drop last STDOUT_VALUE
set "STDOUT_VALUE="

set "?3=("
set "?4=)"

rem call echo."%%?3%%%*%%?4%%"
rem Executed `%*` doesn't set ERRORLEVEL to returned result.
for /F "usebackq tokens=*" %%i in (`%%?3%%%*%%?4%%`) do (
  if not "%%i" == "" (
    rem echo "STDOUT_VALUE=%%i"
    set "STDOUT_VALUE=%%i"
    goto EXIT
  )
)

:EXIT
rem Drop internal variables
set "?3="
set "?4="
