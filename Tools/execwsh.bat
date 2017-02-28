@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls to Windows Scripting Host (WSH) script.
rem   Variable "__ARGS__" uses to pass arguments to the WSH interpreter.

rem Command arguments:
rem %1 - WSH script file path name.
rem %2 - WSH script running mode:
rem    -console - (default) Invoke "cscript.exe" for script.
rem    -gui     - Invoke "wscript.exe" for script.

rem Examples:
rem 1. set __ARGS__="arg1" "arg2"
rem    call execwsh.bat myscript.js

if "%~1" == "" exit /b 65

if /i "%~2" == "-console" (
  :ARG2_DEFAULT
  "cscript.exe" "%~1" //Nologo %__ARGS__%
  goto BEGIN10
) else if /i "%~2" == "-gui" (
  "wscript.exe" "%~1" //Nologo %__ARGS__%
) else (
  goto ARG2_DEFAULT
)

:BEGIN10
