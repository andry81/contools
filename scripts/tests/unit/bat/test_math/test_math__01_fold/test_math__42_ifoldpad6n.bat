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

set ZEROS=00000000000000000000

rem NOTE:
rem   Opposite to `ufoldpad.bat` script, the `OUT` must be always at least
rem   `N,N,N,N,N,N` formatted if defined.
set OUTREF=0,0,0,0,0,0


setlocal
set "OUTREF="
call :TEST
endlocal

setlocal
set OUT=x
set RETREF=1
call :TEST OUT
endlocal

setlocal
set OUT=x
set RETREF=1
call :TEST OUT IN
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
set IN=-1
set "OUTREF="
call :TEST "" IN
endlocal

rem with signed zero case
for %%a in ("" "+" "-") do ^
for /L %%i in (1,1,20) do (
  setlocal
  call set "IN=%%~a%%ZEROS:~0,%%i%%"
  set RETREF=1
  call :TEST OUT IN
  endlocal
)


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      set a=-12345678901234567890
rem      ifoldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,0,0,0,12,345,678,901,234,567,890
setlocal
set IN=-12345678901234567890
set OUTREF=-0,0,0,0,0,12,345,678,901,234,567,890
call :TEST OUT IN
endlocal

rem   2. >
rem      set a=-0123456000001002003
rem      ifoldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-123,456,0,1,2,3
setlocal
set IN=-0123456000001002003
set OUTREF=-123,456,0,1,2,3
call :TEST OUT IN
endlocal

rem   3. >
rem      set a=-12345
rem      ifoldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,0,0,12,345
setlocal
set IN=-12345
set OUTREF=-0,0,0,0,12,345
call :TEST OUT IN
endlocal


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1
  set OUTREF=%%~a0,0,0,0,0,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12
  set OUTREF=%%~a0,0,0,0,0,12
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123
  set OUTREF=%%~a0,0,0,0,0,123
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234
  set OUTREF=%%~a0,0,0,0,1,234
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345
  set OUTREF=%%~a0,0,0,0,12,345
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456
  set OUTREF=%%~a0,0,0,0,123,456
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567
  set OUTREF=%%~a0,0,0,1,234,567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678
  set OUTREF=%%~a0,0,0,12,345,678
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789
  set OUTREF=%%~a0,0,0,123,456,789
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891
  set OUTREF=%%~a0,0,1,234,567,891
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912
  set OUTREF=%%~a0,0,12,345,678,912
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123
  set OUTREF=%%~a0,0,123,456,789,123
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234
  set OUTREF=%%~a0,1,234,567,891,234
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912345
  set OUTREF=%%~a0,12,345,678,912,345
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123456
  set OUTREF=%%~a0,123,456,789,123,456
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234567
  set OUTREF=%%~a1,234,567,891,234,567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912345678
  set OUTREF=%%~a12,345,678,912,345,678
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123456789
  set OUTREF=%%~a123,456,789,123,456,789
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234567891
  set OUTREF=%%~a0,0,0,0,0,1,234,567,891,234,567,891
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912345678912
  set OUTREF=%%~a0,0,0,0,0,12,345,678,912,345,678,912
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123456789123
  set OUTREF=%%~a0,0,0,0,0,123,456,789,123,456,789,123
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234567891234
  set OUTREF=%%~a0,0,0,0,1,234,567,891,234,567,891,234
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912345678912345
  set OUTREF=%%~a0,0,0,0,12,345,678,912,345,678,912,345
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123456789123456
  set OUTREF=%%~a0,0,0,0,123,456,789,123,456,789,123,456
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234567891234567
  set OUTREF=%%~a0,0,0,1,234,567,891,234,567,891,234,567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345678912345678912345678
  set OUTREF=%%~a0,0,0,12,345,678,912,345,678,912,345,678
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123456789123456789123456789
  set OUTREF=%%~a0,0,0,123,456,789,123,456,789,123,456,789
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234567891234567891234567891
  set OUTREF=%%~a0,0,1,234,567,891,234,567,891,234,567,891
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a01
  set OUTREF=%%~a0,0,0,0,0,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a001
  set OUTREF=%%~a0,0,0,0,0,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0001
  set OUTREF=%%~a0,0,0,0,0,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a2001
  set OUTREF=%%~a0,0,0,0,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a02001
  set OUTREF=%%~a0,0,0,0,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a002001
  set OUTREF=%%~a0,0,0,0,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0002001
  set OUTREF=%%~a0,0,0,0,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a3002001
  set OUTREF=%%~a0,0,0,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a03002001
  set OUTREF=%%~a0,0,0,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a003002001
  set OUTREF=%%~a0,0,0,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0003002001
  set OUTREF=%%~a0,0,0,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a4003002001
  set OUTREF=%%~a0,0,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a04003002001
  set OUTREF=%%~a0,0,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a004003002001
  set OUTREF=%%~a0,0,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0004003002001
  set OUTREF=%%~a0,0,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a5004003002001
  set OUTREF=%%~a0,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a05004003002001
  set OUTREF=%%~a0,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a005004003002001
  set OUTREF=%%~a0,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0005004003002001
  set OUTREF=%%~a0,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a6005004003002001
  set OUTREF=%%~a6,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a06005004003002001
  set OUTREF=%%~a6,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a006005004003002001
  set OUTREF=%%~a6,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0006005004003002001
  set OUTREF=%%~a6,5,4,3,2,1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a7006005004003002001
  set OUTREF=%%~a0,0,0,0,0,7,6,5,4,3,2,1
  call :TEST OUT IN
  endlocal
)

for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1000000000000000000
  set OUTREF=%%~a0,0,0,0,0,1,0,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1100000000000000000
  set OUTREF=%%~a0,0,0,0,0,1,100,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0100000000000000000
  set OUTREF=%%~a100,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100000000000000000
  set OUTREF=%%~a100,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10000000000000000
  set OUTREF=%%~a10,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1000000000000000
  set OUTREF=%%~a1,0,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100000000000000
  set OUTREF=%%~a0,100,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10000000000000
  set OUTREF=%%~a0,10,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1000000000000
  set OUTREF=%%~a0,1,0,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100000000000
  set OUTREF=%%~a0,0,100,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10000000000
  set OUTREF=%%~a0,0,10,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1000000000
  set OUTREF=%%~a0,0,1,0,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100000000
  set OUTREF=%%~a0,0,0,100,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10000000
  set OUTREF=%%~a0,0,0,10,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1000000
  set OUTREF=%%~a0,0,0,1,0,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100000
  set OUTREF=%%~a0,0,0,0,100,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10000
  set OUTREF=%%~a0,0,0,0,10,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1000
  set OUTREF=%%~a0,0,0,0,1,0
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100
  set OUTREF=%%~a0,0,0,0,0,100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10
  set OUTREF=%%~a0,0,0,0,0,10
  call :TEST OUT IN
  endlocal
)

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
