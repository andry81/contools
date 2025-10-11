@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "IN="
set "OUT="
set "OUTREF="
set "RETREF=0"

set ZEROS=000,000,000,000,000,000,000,000,000,000,000,000


setlocal
set RETREF=-1
call :TEST
endlocal

setlocal
set RETREF=-1
call :TEST "" IN
endlocal

setlocal
set IN=1
set RETREF=-1
call :TEST "" IN
endlocal

setlocal
set OUT=x
set "OUTREF=x"
set RETREF=-1
call :TEST OUT
endlocal

setlocal
set OUT=x
set "OUTREF=x"
set RETREF=-1
call :TEST OUT IN
endlocal

rem signed zero case
for %%i in ("0" "+0" "-0" "00" "+00" "-00" "0,00,000" "+0,00,000" "-0,00,000") do (
  setlocal
  set "IN=%%~i"
  set "OUTREF=0"
  call :TEST OUT IN 0
  endlocal
)

for /L %%i in (1,1,47) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  set "OUTREF=0"
  call :TEST OUT IN
  endlocal
)

rem test on overflow
setlocal
set IN=1999,999,999,999,999,999
set OUTREF=1999,999,999,999,999,999
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999
set OUTREF=-1999,999,999,999,999,999
call :TEST OUT IN
endlocal

setlocal
set IN=1999,999,999,999,999,999,1000
set OUTREF=1999,999,999,999,999,999,1000
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999,1000
set OUTREF=-1999,999,999,999,999,999,1000
call :TEST OUT IN
endlocal

setlocal
set IN=1999,999,999,999,999,999,999,999,999,999,999,999,1000
set OUTREF=1999,999,999,999,999,999,999,999,999,999,999,999,1000
call :TEST OUT IN
endlocal

setlocal
set IN=-1999,999,999,999,999,999,999,999,999,999,999,999,1000
set OUTREF=-1999,999,999,999,999,999,999,999,999,999,999,999,1000
call :TEST OUT IN
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      set a=-000,123,000
rem      iltrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,123,0,0,0,0
setlocal
set IN=-000,123,000
set OUTREF=-0,123,0,0,0,0
call :TEST OUT IN
endlocal

rem   2. >
rem      set a=-123000
rem      iltrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-123000,0,0,0,0,0
setlocal
set IN=-123000
set OUTREF=-123000,0,0,0,0,0
call :TEST OUT IN
endlocal

rem   3. >
rem      set a=-0,0,0,0,00,000,0,0,0,0,0,1
rem      iltrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,0,0,0,1
setlocal
set IN=-0,0,0,0,00,000,0,0,0,0,0,1
set OUTREF=-0,0,0,0,0,1
call :TEST OUT IN
endlocal

rem   4. >
rem      set a=-0,0,0,0,00,000
rem      iltrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0
setlocal
set IN=-0,0,0,0,00,000
set OUTREF=0
call :TEST OUT IN
endlocal

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
