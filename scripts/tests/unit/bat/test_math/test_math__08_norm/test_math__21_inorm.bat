@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "IN="
set "OUT="
set "RETREF=0"

set ZEROS=000,000,000,000,000,000,000

rem NOTE:
rem   Opposite to `fold.bat` script, the `OUT` must be always at least
rem   `N,N,N,N,N,N` formatted if defined.
set OUTREF=0,0,0,0,0,0


setlocal
set "OUTREF="
call :TEST
endlocal

setlocal
set "OUTREF="
call :TEST "" IN
endlocal

setlocal
set IN=1
set "OUTREF="
call :TEST "" IN
endlocal

setlocal
set OUT=x
call :TEST OUT
endlocal

setlocal
set OUT=x
call :TEST OUT IN
endlocal

setlocal
set IN=0
set OUT=x
call :TEST OUT IN
endlocal

rem signed zero case
for %%i in ("+0" "-0" "+0,0,0,0,0,0" "-0,0,0,0,0,0") do (
  setlocal
  set "IN=%%~i"
  call :TEST OUT IN 0
  endlocal
)

for /L %%i in (1,1,23) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  call :TEST OUT IN
  endlocal
)

for /L %%i in (25,1,27) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  call :TEST OUT IN
  endlocal
)

rem test on overflow
setlocal
set IN=1999,999,999,999,999,999
set OUTREF=999,999,999,999,999,999
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999
set OUTREF=-999,999,999,999,999,999
set RETREF=-1
call :TEST OUT IN
endlocal

setlocal
set IN=1999,999,999,999,999,999,1000
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
set RETREF=2
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999,1000
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
set RETREF=-2
call :TEST OUT IN
endlocal

setlocal
set IN=1999,999,999,999,999,999,999,999,999,999,999,999,1000
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
set RETREF=2
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999,999,999,999,999,999,999,1000
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
set RETREF=-2
call :TEST OUT IN
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -1,1002,1003,000,000,000
rem      set a=-1,1002,1004
rem      inorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-2,3,4,0,0,0
setlocal
set IN=-1,1002,1004
set OUTREF=-2,3,4,0,0,0
call :TEST OUT IN
endlocal

rem   2. >
rem      set a=-0,0,0,1,2,3,1005
rem      inorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,0,1,2,4,5,0,0,0,0,0
setlocal
set IN=-0,0,0,1,2,3,1005
set OUTREF=-0,0,0,1,2,4,5,0,0,0,0,0
call :TEST OUT IN
endlocal


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1234
  set OUTREF=%%~a234,0,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234
  set OUTREF=%%~a235,234,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234
  set OUTREF=%%~a235,235,234,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234
  set OUTREF=%%~a235,235,235,234,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a235,235,235,235,234,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a235,235,235,235,235,234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1111
  set OUTREF=%%~a235,235,235,235,235,235,111,0,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1998,1111
  set OUTREF=%%~a235,235,235,235,235,235,999,111,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1999,1111
  set OUTREF=%%~a235,235,235,235,235,236,0,111,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal
)

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
set "IN_=%~2"
if "%IN_:~-1%" == "," exit /b 0
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
