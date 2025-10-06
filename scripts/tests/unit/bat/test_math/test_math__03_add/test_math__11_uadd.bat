@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "L="
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
call :TEST "" L
endlocal

setlocal
set L=1
set "OUTREF="
call :TEST "" L
endlocal

setlocal
set L=1
set "OUTREF="
call :TEST "" L 1
endlocal

setlocal
set "OUTREF="
call :TEST "" L 1
endlocal

setlocal
set OUT=x
call :TEST OUT
endlocal

setlocal
set OUT=x
call :TEST OUT L
endlocal

setlocal
set L=0
set OUT=x
call :TEST OUT L
endlocal

setlocal
set OUT=x
call :TEST OUT "" 0
endlocal

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call :TEST OUT L 0
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set OUTREF=0,0,1,111,111,111
  call :TEST OUT L 1111111111
  endlocal
)

rem test on a maximum limit
setlocal
set L=999,999,999,999,999,999
set OUTREF=0,0,2,147,482,647
set RETREF=1
call :TEST OUT L 2147482648
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem 1,002,003,000,000,000
rem      set a=1,2,3
rem      uadd.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=1,2,3,0,0,0
setlocal
set L=1,2,3
set OUTREF=1,2,3,0,0,0
call :TEST OUT L
endlocal

rem      uadd.bat b a 12345
rem      rem ERRORLEVEL=0
rem      rem b=1,2,3,0,12,345
setlocal
set L=1,2,3
set OUTREF=1,2,3,0,12,345
call :TEST OUT L 12345
endlocal

rem   2. >
rem      set a=0,0,0,1,2,3
rem      uadd.bat b a 12345
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,1,14,348
setlocal
set L=0,0,0,1,2,3
set OUTREF=0,0,0,1,14,348
call :TEST OUT L 12345
endlocal

rem   3. >
rem      uadd.bat b "" 12345
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,12,345
setlocal
set OUTREF=0,0,0,0,12,345
call :TEST OUT L 12345
endlocal


setlocal
set L=1
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12
set OUTREF=12,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123
set OUTREF=123,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234
set OUTREF=1,234,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12,345
set OUTREF=12,345,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123,456
set OUTREF=123,456,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234,567
set OUTREF=1,234,568,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12,345,678
set OUTREF=12,345,679,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123,456,789
set OUTREF=123,456,790,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234,567,891
set OUTREF=1,234,569,2,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12,345,678,912
set OUTREF=12,345,680,23,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123,456,789,123
set OUTREF=123,456,790,234,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234,567,891,234
set OUTREF=1,234,569,2,345,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12,345,678,912,345
set OUTREF=12,345,680,23,456,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123,456,789,123,456
set OUTREF=123,456,790,234,567,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234,567,891,234,567
set OUTREF=1,234,569,2,345,678
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12,345,678,912,345,678
set OUTREF=12,345,680,23,456,789
call :TEST OUT L 1111111111
endlocal

setlocal
set L=123,456,789,123,456,789
set OUTREF=123,456,790,234,567,900
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,234,567,891,234,567,891
set OUTREF=1,234,569,2,345,678
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,567,891,234,567,891
set OUTREF=234,567,892,345,679,2
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=12345,678,912,345,678,912
set OUTREF=345,678,913,456,790,23
set RETREF=12
call :TEST OUT L 1111111111
endlocal


setlocal
set L=1,000,000,000,000,000,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,100,000,000,000,000,000
set OUTREF=1,100,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100,000,000,000,000,000
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10,000,000,000,000,000
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,000,000,000,000,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100,000,000,000,000
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10,000,000,000,000
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,000,000,000,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100,000,000,000
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10,000,000,000
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,000,000,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100,000,000
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10,000,000
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,000,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100,000
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10,000
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1,000
set OUTREF=1,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=100
set OUTREF=100,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=10
set OUTREF=10,0,1,111,111,111
call :TEST OUT L 1111111111
endlocal


setlocal
set L=000,100,000,000,000,000
set OUTREF=0,100,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,10,000,000,000,000
set OUTREF=0,10,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,1,000,000,000,000
set OUTREF=0,1,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,100,000,000,000
set OUTREF=0,0,101,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,10,000,000,000
set OUTREF=0,0,11,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,1,000,000,000
set OUTREF=0,0,2,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,100,000,000
set OUTREF=0,0,1,211,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,10,000,000
set OUTREF=0,0,1,121,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,1,000,000
set OUTREF=0,0,1,112,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,100,000
set OUTREF=0,0,1,111,211,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,10,000
set OUTREF=0,0,1,111,121,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,1,000
set OUTREF=0,0,1,111,112,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,000,100
set OUTREF=0,0,1,111,111,211
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,000,10
set OUTREF=0,0,1,111,111,121
call :TEST OUT L 1111111111
endlocal

setlocal
set L=000,000,000,000,000,1
set OUTREF=0,0,1,111,111,112
call :TEST OUT L 1111111111
endlocal


setlocal
set L=2,1
set OUTREF=2,1,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=3,2,1
set OUTREF=3,2,2,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=4,3,2,1
set OUTREF=4,3,3,112,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=5,4,3,2,1
set OUTREF=5,4,4,113,112,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=6,5,4,3,2,1
set OUTREF=6,5,5,114,113,112
call :TEST OUT L 1111111111
endlocal

setlocal
set L=7,6,5,4,3,2,1
set OUTREF=7,6,6,115,114,113
call :TEST OUT L 1111111111
endlocal

setlocal
set L=8,7,6,5,4,3,2,1
set OUTREF=8,7,7,116,115,114
call :TEST OUT L 1111111111
endlocal

setlocal
set L=9,8,7,6,5,4,3,2,1
set OUTREF=9,8,8,117,116,115
call :TEST OUT L 1111111111
endlocal


setlocal
set L=900,800,700,600,500,400,300,200,100
set OUTREF=900,800,701,711,611,511
call :TEST OUT L 1111111111
endlocal

setlocal
set L=90,800,700,600,500,400,300,200,100
set OUTREF=90,800,701,711,611,511
call :TEST OUT L 1111111111
endlocal

setlocal
set L=9,800,700,600,500,400,300,200,100
set OUTREF=9,800,701,711,611,511
call :TEST OUT L 1111111111
endlocal

setlocal
set L=800,700,600,500,400,300,200,100
set OUTREF=800,700,601,611,511,411
call :TEST OUT L 1111111111
endlocal

setlocal
set L=80,700,600,500,400,300,200,100
set OUTREF=80,700,601,611,511,411
call :TEST OUT L 1111111111
endlocal

setlocal
set L=8,700,600,500,400,300,200,100
set OUTREF=8,700,601,611,511,411
call :TEST OUT L 1111111111
endlocal

setlocal
set L=700,600,500,400,300,200,100
set OUTREF=700,600,501,511,411,311
call :TEST OUT L 1111111111
endlocal

setlocal
set L=70,600,500,400,300,200,100
set OUTREF=70,600,501,511,411,311
call :TEST OUT L 1111111111
endlocal

setlocal
set L=7,600,500,400,300,200,100
set OUTREF=7,600,501,511,411,311
call :TEST OUT L 1111111111
endlocal

setlocal
set L=600,500,400,300,200,100
set OUTREF=600,500,401,411,311,211
call :TEST OUT L 1111111111
endlocal

setlocal
set L=60,500,400,300,200,100
set OUTREF=60,500,401,411,311,211
call :TEST OUT L 1111111111
endlocal

setlocal
set L=6,500,400,300,200,100
set OUTREF=6,500,401,411,311,211
call :TEST OUT L 1111111111
endlocal

setlocal
set L=500,400,300,200,100
set OUTREF=500,400,301,311,211,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=50,400,300,200,100
set OUTREF=50,400,301,311,211,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=5,400,300,200,100
set OUTREF=5,400,301,311,211,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=400,300,200,100
set OUTREF=400,300,201,211,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=40,300,200,100
set OUTREF=40,300,201,211,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=4,300,200,100
set OUTREF=4,300,201,211,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=300,200,100
set OUTREF=300,200,101,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=30,200,100
set OUTREF=30,200,101,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=3,200,100
set OUTREF=3,200,101,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=200,100
set OUTREF=200,100,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=20,100
set OUTREF=20,100,1,111,111,111
call :TEST OUT L 1111111111
endlocal

setlocal
set L=2,100
set OUTREF=2,100,1,111,111,111
call :TEST OUT L 1111111111
endlocal


setlocal
set L=1234
set OUTREF=234,0,1,111,111,111
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234
set OUTREF=235,234,1,111,111,111
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234
set OUTREF=235,235,235,111,111,111
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234
set OUTREF=235,235,236,345,111,111
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234
set OUTREF=235,235,236,346,345,111
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234
set OUTREF=235,235,236,346,346,345
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1111
set OUTREF=235,235,236,346,346,346
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1998,1111
set OUTREF=235,235,236,346,346,346
set RETREF=1
call :TEST OUT L 1111111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1999,1111
set OUTREF=235,235,236,346,346,347
set RETREF=1
call :TEST OUT L 1111111111
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
set "L_=%~2"
if "%L_:~-1%" == "," exit /b 0
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
