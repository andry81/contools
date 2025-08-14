@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "OUT="
set "OUTREF="
set "RETREF=0"

set ZEROS=00000000000000000000


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
set "IN="
set OUT=x
set OUTREF=0
set RETREF=-1
call :TEST OUT IN
endlocal

for /L %%i in (1,1,20) do (
  setlocal
  call set "IN=%%ZEROS:~0,%%i%%"
  set OUTREF=0
  call :TEST OUT IN
  endlocal
)


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
set IN=1234
set OUTREF=1,234
call :TEST OUT IN
endlocal

setlocal
set IN=12345
set OUTREF=12,345
call :TEST OUT IN
endlocal

setlocal
set IN=123456
set OUTREF=123,456
call :TEST OUT IN
endlocal

setlocal
set IN=1234567
set OUTREF=1,234,567
call :TEST OUT IN
endlocal

setlocal
set IN=12345678
set OUTREF=12,345,678
call :TEST OUT IN
endlocal

setlocal
set IN=123456789
set OUTREF=123,456,789
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891
set OUTREF=1,234,567,891
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912
set OUTREF=12,345,678,912
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123
set OUTREF=123,456,789,123
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234
set OUTREF=1,234,567,891,234
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912345
set OUTREF=12,345,678,912,345
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123456
set OUTREF=123,456,789,123,456
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234567
set OUTREF=1,234,567,891,234,567
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912345678
set OUTREF=12,345,678,912,345,678
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123456789
set OUTREF=123,456,789,123,456,789
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234567891
set OUTREF=234,567,891,234,567,891
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912345678912
set OUTREF=345,678,912,345,678,912
set RETREF=12
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123456789123
set OUTREF=456,789,123,456,789,123
set RETREF=123
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234567891234
set OUTREF=567,891,234,567,891,234
set RETREF=1234
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912345678912345
set OUTREF=678,912,345,678,912,345
set RETREF=12345
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123456789123456
set OUTREF=789,123,456,789,123,456
set RETREF=123456
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234567891234567
set OUTREF=891,234,567,891,234,567
set RETREF=1234567
call :TEST OUT IN
endlocal

setlocal
set IN=12345678912345678912345678
set OUTREF=912,345,678,912,345,678
set RETREF=12345678
call :TEST OUT IN
endlocal

setlocal
set IN=123456789123456789123456789
set OUTREF=123,456,789,123,456,789
set RETREF=123456789
call :TEST OUT IN
endlocal

setlocal
set IN=1234567891234567891234567891
set OUTREF=234,567,891,234,567,891
set RETREF=1234567891
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
set IN=0001
set OUTREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=2001
set OUTREF=2,1
call :TEST OUT IN
endlocal

setlocal
set IN=02001
set OUTREF=2,1
call :TEST OUT IN
endlocal

setlocal
set IN=002001
set OUTREF=2,1
call :TEST OUT IN
endlocal

setlocal
set IN=0002001
set OUTREF=2,1
call :TEST OUT IN
endlocal

setlocal
set IN=3002001
set OUTREF=3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=03002001
set OUTREF=3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=003002001
set OUTREF=3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=0003002001
set OUTREF=3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=4003002001
set OUTREF=4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=04003002001
set OUTREF=4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=004003002001
set OUTREF=4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=0004003002001
set OUTREF=4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=5004003002001
set OUTREF=5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=05004003002001
set OUTREF=5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=005004003002001
set OUTREF=5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=0005004003002001
set OUTREF=5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=6005004003002001
set OUTREF=6,5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=06005004003002001
set OUTREF=6,5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=006005004003002001
set OUTREF=6,5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=0006005004003002001
set OUTREF=6,5,4,3,2,1
call :TEST OUT IN
endlocal

setlocal
set IN=7006005004003002001
set OUTREF=6,5,4,3,2,1
set RETREF=7
call :TEST OUT IN
endlocal


setlocal
set IN=1000000000000000000
set OUTREF=0
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=1100000000000000000
set OUTREF=100,0,0,0,0,0
set RETREF=1
call :TEST OUT IN
endlocal

setlocal
set IN=0100000000000000000
set OUTREF=100,0,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100000000000000000
set OUTREF=100,0,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10000000000000000
set OUTREF=10,0,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=1000000000000000
set OUTREF=1,0,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100000000000000
set OUTREF=100,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10000000000000
set OUTREF=10,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=1000000000000
set OUTREF=1,0,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100000000000
set OUTREF=100,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10000000000
set OUTREF=10,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=1000000000
set OUTREF=1,0,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100000000
set OUTREF=100,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10000000
set OUTREF=10,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=1000000
set OUTREF=1,0,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100000
set OUTREF=100,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10000
set OUTREF=10,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=1000
set OUTREF=1,0
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=100
set OUTREF=100
set RETREF=0
call :TEST OUT IN
endlocal

setlocal
set IN=10
set OUTREF=10
set RETREF=0
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
