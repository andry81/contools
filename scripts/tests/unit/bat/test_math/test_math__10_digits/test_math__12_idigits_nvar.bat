@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "IN="
set "INREF="
set "RETREF=0"

set ZEROS=000000000000000000


setlocal
set RETREF=1
call :TEST
endlocal

setlocal
set RETREF=1
call :TEST IN
endlocal

setlocal
set IN=-xxx
set INREF=-xxx
set RETREF=1
call :TEST IN
endlocal

rem signed zero case
for %%i in ("+0" "-0" "+00" "-00") do (
  setlocal
  set "IN=%%~i"
  set "INREF=%%~i"
  set RETREF=1
  call :TEST IN
  endlocal
)

for /L %%i in (1,1,18) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  call set "INREF=%%IN%%"
  set RETREF=1
  call :TEST IN
  endlocal
)

rem test on overflow
setlocal
set IN=1999999999999999999
set "INREF=%IN%"
set RETREF=19
call :TEST IN
endlocal

setlocal
set IN=-1999999999999999999
set "INREF=%IN%"
set RETREF=19
call :TEST IN
endlocal

setlocal
set IN=19999999999999999991000
set "INREF=%IN%"
set RETREF=23
call :TEST IN
endlocal

setlocal
set IN=-19999999999999999991000
set "INREF=%IN%"
set RETREF=23
call :TEST IN
endlocal

setlocal
set IN=19999999999999999999999999999999999991000
set "INREF=%IN%"
set RETREF=41
call :TEST IN
endlocal

setlocal
set IN=-19999999999999999999999999999999999991000
set "INREF=%IN%"
set RETREF=41
call :TEST IN
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      set a=-000123000
rem      idigits_nvar.bat a
rem      rem ERRORLEVEL=6
setlocal
set IN=-000123000
set "INREF=%IN%"
set RETREF=6
call :TEST IN
endlocal

rem   2. >
rem      set a=+000000000
rem      idigits_nvar.bat a
rem      rem ERRORLEVEL=1
setlocal
set IN=+000000000
set "INREF=%IN%"
set RETREF=1
call :TEST IN
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
