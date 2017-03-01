@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script calls %* variable with restore error level which was just before a
rem   call.

rem Examples:
rem 1. rem Below routine should be inside a script!
rem    call errlvl.bat 10
rem    set "AAA=BBB"
rem    set "BBB=C:\blabla\blabla"
rem    rem If we remove "callargs.bat" from below line, error level would be
rem    rem dropped in to 0 after command, because of "call" prefix before "set"
rem    rem command. So "callargs.bat" executes with call "prefix" before "set"
rem    rem command, but internally restores previous error level to avoid bad
rem    rem behaviour with "call" prefix before "set" command.
rem    rem This is valid ONLY inside a script, not manually entered in a console
rem    rem window!
rem    call callargs.bat set "CCC=%%%AAA%%%"
rem    echo "ERRORLEVEL=%ERRORLEVEL%"

if not "%~1" == "" (
  call %%*
  rem Exit with previous error level.
  exit /b %ERRORLEVEL%
)

rem Exit with current error level.
