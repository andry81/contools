@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Converts unicode 16-byte string written in hex form to ANSI string by
rem   simply removing code page character and copies it to %1 variable.

rem Command arguments:
rem %1 - Variable name.
rem %2 - Converting string.

rem Examples:
rem 1. call wctoansi.bat TEST 3200330034003500
rem    echo TEST=%TEST%

if "%~1" == "" exit /b 1

rem Drop %~1 variable
set "%~1="

if "%~2" == "" exit /b 2

rem Create local variable's stack
setlocal

call "%%~dp0__init__.bat" || exit /b

rem Standard ANSI character table
set __ANSI_TBL= !"#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~

rem Converting string
set "__WCSTRING=%~2"

rem Initialize counter
set __COUNTER=0

:FOR100
rem Read next wide character code
call set "__WCHARCODE=%%__WCSTRING:~%__COUNTER%,4%%"

if not defined __WCHARCODE goto EXIT

rem Convert from hex code to decimal
if not "%__WCHARCODE:~0,2%" == "" (
  call "%%CONTOOLS_ROOT%%/expandvarn.bat" __ACHAROFFSET "0x%%__WCHARCODE:~0,2%%"
) else (
  set __ACHAROFFSET=0
)

if %__ACHAROFFSET% LSS 32 goto :FOR100_CONTINUE
if %__ACHAROFFSET% GEQ 127 goto :FOR100_CONTINUE

set /A __ACHAROFFSET-=32

rem Append char from ANSI table
call set "%~1=%%%~1%%%%__ANSI_TBL:~%__ACHAROFFSET%,1%%"

:FOR100_CONTINUE
set /A __COUNTER+=4
goto FOR100

:EXIT
exit /b 0
