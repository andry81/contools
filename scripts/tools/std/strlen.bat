@echo off & setlocal DISABLEDELAYEDEXPANSION

set "S=" & set "V=__STRING__"
if "%~1" == "" set "S=%~2"
if "%~1" == "/v" if not "%~2" == "" set "V=%~2"

setlocal ENABLEDELAYEDEXPANSION

if "%~1" == "/v" set S=!%V%!

if not defined S exit /b 0

set "LEN=1" & for %%i in (65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!S:~%%i,1!" == "" set /A "LEN+=%%i" & set S=!S:~%%i!
exit /b %LEN%

rem USAGE:
rem   strlen.bat "" <string>
rem   strlen.bat /v <var>

rem Description:
rem   Script reads the length of a string in first argument.
rem   This is fast version of strlen and limited by the maximum length of a
rem   string - 65535 characters.
rem   A variable expansion string limited to 8191 characters starting
rem   immediately after a command name: `set A=B`, where ` A=B` must be less
rem   than 8192 characters. See the `strlen.bat` limit tests for the details.

rem Command arguments:
rem %1 - Type of function:
rem   <none>  - (Default) use %2 for input string
rem   /v      - use variable %2 as input string. If %2 is empty, then the
rem             variable name is __STRING__.
rem %2 - String in default search mode, otherwise it is the name of a variable
rem      which stores string if /v flag is used.

rem Examples:
rem
rem   1. >call strlen.bat "" "Hello world!"
rem      >echo ERRORLEVEL=%ERRORLEVEL%
rem      ERRORLEVEL=12
rem
rem
rem   2. set "__STRING__=Hello world!"
rem      call strlen.bat /v
rem      echo ERRORLEVEL=12
