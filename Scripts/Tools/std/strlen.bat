@echo off & goto DOC_END

rem USAGE:
rem   strlen.bat "" <string>
rem   strlen.bat /v <var>

rem Description:
rem   Script reads the length of a string in first argument.
rem   This is fast version of strlen and limited by the maximum length of a
rem   string - 65536 characters
rem  (a variable expansion string limited to 4096 characters).

rem Command arguments:
rem %1 - Type of function:
rem   <none>  - (Default) use %2 for input string
rem   /v      - use variable %2 as input string. If %2 is empty, then the
rem             variable name is __STRING__.
rem %2 - String in default search mode, otherwise it is the name of a variable
rem      which stores string if /v flag is used.

rem Examples:
rem 1. call strlen.bat "" "Hello world!"
rem    echo ERRORLEVEL=%ERRORLEVEL%
rem 2. set "__STRING__=Hello world!"
rem    call strlen.bat /v
rem    echo ERRORLEVEL=%ERRORLEVEL%
:DOC_END

setlocal DISABLEDELAYEDEXPANSION

set "__VAR__=__STRING__"
if not "%~1" == "/v" (
  rem Unsafe strings assign, values can has control characters!
  set "__STRING__=%~2"
) else if not "%~2" == "" set "__VAR__=%~2"

setlocal ENABLEDELAYEDEXPANSION

if "%~1" == "/v" set "__STRING__=!%__VAR__%!"

if not defined __STRING__ exit /b 0

set "__LEN__=1" & for %%i in (65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!__STRING__:~%%i,1!" == "" set /A "__LEN__+=%%i" & set "__STRING__=!__STRING__:~%%i!"
endlocal & exit /b %__LEN__%
