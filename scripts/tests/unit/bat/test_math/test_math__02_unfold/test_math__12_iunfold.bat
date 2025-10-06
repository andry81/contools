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

set ZEROS=000,000,000,000,000,000,000


setlocal
call :TEST
endlocal

setlocal
set OUT=x
set OUTREF=0
call :TEST OUT
endlocal

setlocal
set OUT=x
set OUTREF=0
call :TEST OUT IN
endlocal

setlocal
call :TEST "" IN
endlocal

setlocal
set IN=1
call :TEST "" IN
endlocal

setlocal
set IN=-1
call :TEST "" IN
endlocal

rem with signed zero case
for %%a in ("" "+" "-") do ^
for /L %%i in (1,1,27) do (
  setlocal
  call set "IN=%%~a%%ZEROS:~0,%%i%%"
  set OUTREF=0
  call :TEST OUT IN
  endlocal
)


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      set a=-0,1,2,3
rem      iunfold.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-1002003
setlocal
set IN=-0,1,2,3
set OUTREF=-1002003
call :TEST OUT IN
endlocal

rem   2. >
rem      set a=-4321,2,3,4,5,6,4567,1,2,3,4,5
rem      iunfold.bat b a
rem      rem ERRORLEVEL=-4
rem      rem b=-321002003004005010
setlocal
set IN=-4321,2,3,4,5,6,4567,1,2,3,4,5
set OUTREF=-321002003004005010
set RETREF=-4
call :TEST OUT IN
endlocal


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1
  set OUTREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12
  set OUTREF=%%~a12
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123
  set OUTREF=%%~a123
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234
  set OUTREF=%%~a1234
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12,345
  set OUTREF=%%~a12345
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123,456
  set OUTREF=%%~a123456
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234,567
  set OUTREF=%%~a1234567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12,345,678
  set OUTREF=%%~a12345678
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123,456,789
  set OUTREF=%%~a123456789
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234,567,891
  set OUTREF=%%~a1234567891
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12,345,678,912
  set OUTREF=%%~a12345678912
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123,456,789,123
  set OUTREF=%%~a123456789123
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234,567,891,234
  set OUTREF=%%~a1234567891234
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12,345,678,912,345
  set OUTREF=%%~a12345678912345
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123,456,789,123,456
  set OUTREF=%%~a123456789123456
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234,567,891,234,567
  set OUTREF=%%~a1234567891234567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12,345,678,912,345,678
  set OUTREF=%%~a12345678912345678
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a123,456,789,123,456,789
  set OUTREF=%%~a123456789123456789
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,234,567,891,234,567,891
  set OUTREF=%%~a1234567891234567
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,567,891,234,567,891
  set OUTREF=%%~a234567891234567891
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a12345,678,912,345,678,912
  set OUTREF=%%~a345678912345678912
  set RETREF=%%~a12
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a01
  set OUTREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a001
  set OUTREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,001
  set OUTREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a2,001
  set OUTREF=%%~a2001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a02,001
  set OUTREF=%%~a2001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a002,001
  set OUTREF=%%~a2001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,002,001
  set OUTREF=%%~a2001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a3,002,001
  set OUTREF=%%~a3002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a03,002,001
  set OUTREF=%%~a3002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a003,002,001
  set OUTREF=%%~a3002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,003,002,001
  set OUTREF=%%~a3002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a4,003,002,001
  set OUTREF=%%~a4003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a04,003,002,001
  set OUTREF=%%~a4003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a004,003,002,001
  set OUTREF=%%~a4003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,004,003,002,001
  set OUTREF=%%~a4003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a5,004,003,002,001
  set OUTREF=%%~a5004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a05,004,003,002,001
  set OUTREF=%%~a5004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a005,004,003,002,001
  set OUTREF=%%~a5004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,005,004,003,002,001
  set OUTREF=%%~a5004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a6,005,004,003,002,001
  set OUTREF=%%~a6005004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a06,005,004,003,002,001
  set OUTREF=%%~a6005004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a006,005,004,003,002,001
  set OUTREF=%%~a6005004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0,006,005,004,003,002,001
  set OUTREF=%%~a6005004003002
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a7,006,005,004,003,002,001
  set OUTREF=%%~a7006005004003002
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a8,007,006,005,004,003,002,001
  set OUTREF=%%~a8007006005004003
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a9,008,007,006,005,004,003,002,001
  set OUTREF=%%~a9008007006005004
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1,000,000,000,000,000,000
  set OUTREF=%%~a1000000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,100,000,000,000,000,000
  set OUTREF=%%~a1100000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a0100,000,000,000,000,000
  set OUTREF=%%~a100000000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100,000,000,000,000,000
  set OUTREF=%%~a100000000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10,000,000,000,000,000
  set OUTREF=%%~a10000000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,000,000,000,000,000
  set OUTREF=%%~a1000000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100,000,000,000,000
  set OUTREF=%%~a100000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10,000,000,000,000
  set OUTREF=%%~a10000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,000,000,000,000
  set OUTREF=%%~a1000000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100,000,000,000
  set OUTREF=%%~a100000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10,000,000,000
  set OUTREF=%%~a10000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,000,000,000
  set OUTREF=%%~a1000000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100,000,000
  set OUTREF=%%~a100000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10,000,000
  set OUTREF=%%~a10000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,000,000
  set OUTREF=%%~a1000000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100,000
  set OUTREF=%%~a100000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10,000
  set OUTREF=%%~a10000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1,000
  set OUTREF=%%~a1000
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a100
  set OUTREF=%%~a100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a10
  set OUTREF=%%~a10
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a2,1
  set OUTREF=%%~a2001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a3,2,1
  set OUTREF=%%~a3002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a4,3,2,1
  set OUTREF=%%~a4003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a5,4,3,2,1
  set OUTREF=%%~a5004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a6,5,4,3,2,1
  set OUTREF=%%~a6005004003002001
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a7,6,5,4,3,2,1
  set OUTREF=%%~a7006005004003002
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a8,7,6,5,4,3,2,1
  set OUTREF=%%~a8007006005004003
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a9,8,7,6,5,4,3,2,1
  set OUTREF=%%~a9008007006005004
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a900,800,700,600,500,400,300,200,100
  set OUTREF=%%~a900800700600500400
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a90,800,700,600,500,400,300,200,100
  set OUTREF=%%~a90800700600500400
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a9,800,700,600,500,400,300,200,100
  set OUTREF=%%~a9800700600500400
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a800,700,600,500,400,300,200,100
  set OUTREF=%%~a800700600500400300
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a80,700,600,500,400,300,200,100
  set OUTREF=%%~a80700600500400300
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a8,700,600,500,400,300,200,100
  set OUTREF=%%~a8700600500400300
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a700,600,500,400,300,200,100
  set OUTREF=%%~a700600500400300200
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a70,600,500,400,300,200,100
  set OUTREF=%%~a70600500400300200
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a7,600,500,400,300,200,100
  set OUTREF=%%~a7600500400300200
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a600,500,400,300,200,100
  set OUTREF=%%~a600500400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a60,500,400,300,200,100
  set OUTREF=%%~a60500400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a6,500,400,300,200,100
  set OUTREF=%%~a6500400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a500,400,300,200,100
  set OUTREF=%%~a500400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a50,400,300,200,100
  set OUTREF=%%~a50400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a5,400,300,200,100
  set OUTREF=%%~a5400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a400,300,200,100
  set OUTREF=%%~a400300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a40,300,200,100
  set OUTREF=%%~a40300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a4,300,200,100
  set OUTREF=%%~a4300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a300,200,100
  set OUTREF=%%~a300200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a30,200,100
  set OUTREF=%%~a30200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a3,200,100
  set OUTREF=%%~a3200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a200,100
  set OUTREF=%%~a200100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a20,100
  set OUTREF=%%~a20100
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a2,100
  set OUTREF=%%~a2100
  call :TEST OUT IN
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set IN=%%~a1234
  set OUTREF=%%~a234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234
  set OUTREF=%%~a235234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234
  set OUTREF=%%~a235235234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234
  set OUTREF=%%~a235235235234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a235235235235234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a235235235235235234
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1111
  set OUTREF=%%~a235235235235235235
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1998,1111
  set OUTREF=%%~a235235235235235235
  set RETREF=%%~a1
  call :TEST OUT IN
  endlocal

  setlocal
  set IN=%%~a1234,1234,1234,1234,1234,1234,1999,1111
  set OUTREF=%%~a235235235235235236
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
