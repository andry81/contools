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
set RETREF=-1
call :TEST
endlocal

setlocal
set OUT=x
set OUTREF=0
set RETREF=-1
call :TEST OUT
endlocal

setlocal
set OUT=x
set OUTREF=0
set RETREF=-1
call :TEST OUT IN
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

for /L %%i in (1,1,27) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  set OUTREF=0
  call :TEST OUT IN
  endlocal
)


rem NOTE: tests from the script documentation in the description

rem Examples:
rem   1. >
rem      set a=0,1,2,3
rem      unfold.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=1002003
setlocal
set IN=0,1,2,3
set OUTREF=1002003
call :TEST OUT IN
endlocal

rem   2. >
rem      set a=4321,2,3,4,5,6,4567,1,2,3,4,5
rem      unfold.bat b a
rem      rem ERRORLEVEL=4
rem      rem b=321002003004005010
setlocal
set IN=4321,2,3,4,5,6,4567,1,2,3,4,5
set OUTREF=321002003004005010
set RETREF=4
call :TEST OUT IN
endlocal


setlocal
set IN=1
set OUTREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=12
set OUTREF=12
call :TEST OUT IN
endlocal

setlocal
set IN=123
set OUTREF=123
call :TEST OUT IN
endlocal

setlocal
set IN=1,234
set OUTREF=1234
call :TEST OUT IN
endlocal

setlocal
set IN=12,345
set OUTREF=12345
call :TEST OUT IN
endlocal

setlocal
set IN=123,456
set OUTREF=123456
call :TEST OUT IN
endlocal

setlocal
set IN=1,234,567
set OUTREF=1234567
call :TEST OUT IN
endlocal

setlocal
set IN=12,345,678
set OUTREF=12345678
call :TEST OUT IN
endlocal

setlocal
set IN=123,456,789
set OUTREF=123456789
call :TEST OUT IN
endlocal

setlocal
set IN=1,234,567,891
set OUTREF=1234567891
call :TEST OUT IN
endlocal

setlocal
set IN=12,345,678,912
set OUTREF=12345678912
call :TEST OUT IN
endlocal

setlocal
set IN=123,456,789,123
set OUTREF=123456789123
call :TEST OUT IN
endlocal

setlocal
set IN=1,234,567,891,234
set OUTREF=1234567891234
call :TEST OUT IN
endlocal

setlocal
set IN=12,345,678,912,345
set OUTREF=12345678912345
call :TEST OUT IN
endlocal

setlocal
set IN=123,456,789,123,456
set OUTREF=123456789123456
call :TEST OUT IN
endlocal

setlocal
set IN=1,234,567,891,234,567
set OUTREF=1234567891234567
call :TEST OUT IN
endlocal

setlocal
set IN=12,345,678,912,345,678
set OUTREF=12345678912345678
call :TEST OUT IN
endlocal

setlocal
set IN=123,456,789,123,456,789
set OUTREF=123456789123456789
call :TEST OUT IN
endlocal

setlocal
set IN=1,234,567,891,234,567,891
set OUTREF=1234567891234567
call :TEST OUT IN
endlocal

setlocal
set IN=1234,567,891,234,567,891
set OUTREF=234567891234567891
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=12345,678,912,345,678,912
set OUTREF=345678912345678912
set RETREF=12
call :TEST OUT IN
endlocal


setlocal
set IN=01
set OUTREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=001
set OUTREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=0,001
set OUTREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=2,001
set OUTREF=2001
call :TEST OUT IN
endlocal

setlocal
set IN=02,001
set OUTREF=2001
call :TEST OUT IN
endlocal

setlocal
set IN=002,001
set OUTREF=2001
call :TEST OUT IN
endlocal

setlocal
set IN=0,002,001
set OUTREF=2001
call :TEST OUT IN
endlocal

setlocal
set IN=3,002,001
set OUTREF=3002001
call :TEST OUT IN
endlocal

setlocal
set IN=03,002,001
set OUTREF=3002001
call :TEST OUT IN
endlocal

setlocal
set IN=003,002,001
set OUTREF=3002001
call :TEST OUT IN
endlocal

setlocal
set IN=0,003,002,001
set OUTREF=3002001
call :TEST OUT IN
endlocal

setlocal
set IN=4,003,002,001
set OUTREF=4003002001
call :TEST OUT IN
endlocal

setlocal
set IN=04,003,002,001
set OUTREF=4003002001
call :TEST OUT IN
endlocal

setlocal
set IN=004,003,002,001
set OUTREF=4003002001
call :TEST OUT IN
endlocal

setlocal
set IN=0,004,003,002,001
set OUTREF=4003002001
call :TEST OUT IN
endlocal

setlocal
set IN=5,004,003,002,001
set OUTREF=5004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=05,004,003,002,001
set OUTREF=5004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=005,004,003,002,001
set OUTREF=5004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=0,005,004,003,002,001
set OUTREF=5004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=6,005,004,003,002,001
set OUTREF=6005004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=06,005,004,003,002,001
set OUTREF=6005004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=006,005,004,003,002,001
set OUTREF=6005004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=0,006,005,004,003,002,001
set OUTREF=6005004003002
call :TEST OUT IN
endlocal

setlocal
set IN=7,006,005,004,003,002,001
set OUTREF=7006005004003002
call :TEST OUT IN
endlocal

setlocal
set IN=8,007,006,005,004,003,002,001
set OUTREF=8007006005004003
call :TEST OUT IN
endlocal

setlocal
set IN=9,008,007,006,005,004,003,002,001
set OUTREF=9008007006005004
call :TEST OUT IN
endlocal


setlocal
set IN=1,000,000,000,000,000,000
set OUTREF=1000000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=1,100,000,000,000,000,000
set OUTREF=1100000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=0100,000,000,000,000,000
set OUTREF=100000000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=100,000,000,000,000,000
set OUTREF=100000000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=10,000,000,000,000,000
set OUTREF=10000000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=1,000,000,000,000,000
set OUTREF=1000000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=100,000,000,000,000
set OUTREF=100000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=10,000,000,000,000
set OUTREF=10000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=1,000,000,000,000
set OUTREF=1000000000000
call :TEST OUT IN
endlocal

setlocal
set IN=100,000,000,000
set OUTREF=100000000000
call :TEST OUT IN
endlocal

setlocal
set IN=10,000,000,000
set OUTREF=10000000000
call :TEST OUT IN
endlocal

setlocal
set IN=1,000,000,000
set OUTREF=1000000000
call :TEST OUT IN
endlocal

setlocal
set IN=100,000,000
set OUTREF=100000000
call :TEST OUT IN
endlocal

setlocal
set IN=10,000,000
set OUTREF=10000000
call :TEST OUT IN
endlocal

setlocal
set IN=1,000,000
set OUTREF=1000000
call :TEST OUT IN
endlocal

setlocal
set IN=100,000
set OUTREF=100000
call :TEST OUT IN
endlocal

setlocal
set IN=10,000
set OUTREF=10000
call :TEST OUT IN
endlocal

setlocal
set IN=1,000
set OUTREF=1000
call :TEST OUT IN
endlocal

setlocal
set IN=100
set OUTREF=100
call :TEST OUT IN
endlocal

setlocal
set IN=10
set OUTREF=10
call :TEST OUT IN
endlocal

setlocal
set IN=2,1
set OUTREF=2001
call :TEST OUT IN
endlocal

setlocal
set IN=3,2,1
set OUTREF=3002001
call :TEST OUT IN
endlocal

setlocal
set IN=4,3,2,1
set OUTREF=4003002001
call :TEST OUT IN
endlocal

setlocal
set IN=5,4,3,2,1
set OUTREF=5004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=6,5,4,3,2,1
set OUTREF=6005004003002001
call :TEST OUT IN
endlocal

setlocal
set IN=7,6,5,4,3,2,1
set OUTREF=7006005004003002
call :TEST OUT IN
endlocal

setlocal
set IN=8,7,6,5,4,3,2,1
set OUTREF=8007006005004003
call :TEST OUT IN
endlocal

setlocal
set IN=9,8,7,6,5,4,3,2,1
set OUTREF=9008007006005004
call :TEST OUT IN
endlocal


setlocal
set IN=900,800,700,600,500,400,300,200,100
set OUTREF=900800700600500400
call :TEST OUT IN
endlocal

setlocal
set IN=90,800,700,600,500,400,300,200,100
set OUTREF=90800700600500400
call :TEST OUT IN
endlocal

setlocal
set IN=9,800,700,600,500,400,300,200,100
set OUTREF=9800700600500400
call :TEST OUT IN
endlocal

setlocal
set IN=800,700,600,500,400,300,200,100
set OUTREF=800700600500400300
call :TEST OUT IN
endlocal

setlocal
set IN=80,700,600,500,400,300,200,100
set OUTREF=80700600500400300
call :TEST OUT IN
endlocal

setlocal
set IN=8,700,600,500,400,300,200,100
set OUTREF=8700600500400300
call :TEST OUT IN
endlocal

setlocal
set IN=700,600,500,400,300,200,100
set OUTREF=700600500400300200
call :TEST OUT IN
endlocal

setlocal
set IN=70,600,500,400,300,200,100
set OUTREF=70600500400300200
call :TEST OUT IN
endlocal

setlocal
set IN=7,600,500,400,300,200,100
set OUTREF=7600500400300200
call :TEST OUT IN
endlocal

setlocal
set IN=600,500,400,300,200,100
set OUTREF=600500400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=60,500,400,300,200,100
set OUTREF=60500400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=6,500,400,300,200,100
set OUTREF=6500400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=500,400,300,200,100
set OUTREF=500400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=50,400,300,200,100
set OUTREF=50400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=5,400,300,200,100
set OUTREF=5400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=400,300,200,100
set OUTREF=400300200100
call :TEST OUT IN
endlocal

setlocal
set IN=40,300,200,100
set OUTREF=40300200100
call :TEST OUT IN
endlocal

setlocal
set IN=4,300,200,100
set OUTREF=4300200100
call :TEST OUT IN
endlocal

setlocal
set IN=300,200,100
set OUTREF=300200100
call :TEST OUT IN
endlocal

setlocal
set IN=30,200,100
set OUTREF=30200100
call :TEST OUT IN
endlocal

setlocal
set IN=3,200,100
set OUTREF=3200100
call :TEST OUT IN
endlocal

setlocal
set IN=200,100
set OUTREF=200100
call :TEST OUT IN
endlocal

setlocal
set IN=20,100
set OUTREF=20100
call :TEST OUT IN
endlocal

setlocal
set IN=2,100
set OUTREF=2100
call :TEST OUT IN
endlocal


setlocal
set IN=1234
set OUTREF=234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234
set OUTREF=235234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234
set OUTREF=235235234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234
set OUTREF=235235235234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234,1234
set OUTREF=235235235235234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234,1234,1234
set OUTREF=235235235235235234
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234,1234,1234,1111
set OUTREF=235235235235235235
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234,1234,1234,1998,1111
set OUTREF=235235235235235235
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1234,1234,1234,1234,1234,1234,1999,1111
set OUTREF=235235235235235236
set RETREF=1
call :TEST OUT IN
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
