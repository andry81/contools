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
rem   `N,N,N,N,N,N` formatted if defined and the divisor is not 0.
set OUTREF=0,0,0,0,0,0


setlocal
set "OUTREF="
set RETREF=-1
call :TEST
endlocal

setlocal
set "OUTREF="
set RETREF=-1
call :TEST "" L
endlocal

setlocal
set L=1
set "OUTREF="
set RETREF=-1
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
set L=1
set "OUTREF="
call :TEST "" L -1
endlocal

setlocal
set "OUTREF="
call :TEST "" L -1
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
call :TEST OUT L
endlocal

setlocal
set L=1
set OUT=x
set "OUTREF=x"
set RETREF=-1
call :TEST OUT L
endlocal

setlocal
set OUT=x
set "OUTREF=x"
set RETREF=-1
call :TEST OUT "" 0
endlocal

rem signed zero case
for %%i in ("+0" "-0" "+0,0,0,0,0,0" "-0,0,0,0,0,0") do (
  setlocal
  set "L=%%~i"
  call :TEST OUT L 1
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call :TEST OUT L 1
  endlocal
)

rem test on a maximum limit
setlocal
set L=999,999,999,999,999,999
set OUTREF=0,0,465,661,427,820
set RETREF=822939
call :TEST OUT L 2147483
endlocal

setlocal
set L=2,147,482,999,999,999
set OUTREF=0,0,0,999,999,999
set RETREF=2147482
call :TEST OUT L 2147483
endlocal

setlocal
set L=-999,999,999,999,999,999
set OUTREF=-0,0,465,661,427,820
set RETREF=-822939
call :TEST OUT L 2147483
endlocal

setlocal
set L=-2,147,482,999,999,999
set OUTREF=-0,0,0,999,999,999
set RETREF=-2147482
call :TEST OUT L 2147483
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -2,147,483,648,000,000
rem      set a=-2,147,483,648
rem      idiv.bat b a 123
rem      rem ERRORLEVEL=-62
rem      rem b=-0,17,459,216,650,406
setlocal
set L=-2,147,483,648
set OUTREF=-0,17,459,216,650,406
set RETREF=-62
call :TEST OUT L 123
endlocal

rem   2. >
rem      rem -1,023,045,067,890,000
rem      set a=-1,23,45,67,890
rem      idiv.bat b a 123456
rem      rem ERRORLEVEL=-111696
rem      rem b=-0,0,8,286,718,84
setlocal
set L=-1,23,45,67,890
set OUTREF=-0,0,8,286,718,84
set RETREF=-111696
call :TEST OUT L 123456
endlocal

rem   3. >
rem      rem -1,000,000,000,000,000
rem      set a=-1
rem      set b=x
rem      idiv.bat b a
rem      Divide by zero error.
rem      rem ERRORLEVEL=-1
rem      rem b=x
setlocal
set L=-1
set OUT=x
set "OUTREF=x"
set RETREF=-1
call :TEST OUT L
endlocal


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12
  set OUTREF=%%~a0,0,10,800,1,80
  set RETREF=%%~a120
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123
  set OUTREF=%%~a0,0,110,700,11,70
  set RETREF=%%~a1230
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234
  set OUTREF=%%~a0,0,1,110,600,111
  set RETREF=%%~a66679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345
  set OUTREF=%%~a0,0,11,110,501,111
  set RETREF=%%~a55679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456
  set OUTREF=%%~a0,0,111,110,411,111
  set RETREF=%%~a45679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567
  set OUTREF=%%~a0,0,1,111,110,411
  set RETREF=%%~a123379
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678
  set OUTREF=%%~a0,0,11,111,111,311
  set RETREF=%%~a123479
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789
  set OUTREF=%%~a0,0,111,111,121,211
  set RETREF=%%~a124579
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set OUTREF=%%~a0,0,1,111,111,213
  set RETREF=%%~a12357
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set OUTREF=%%~a0,0,11,111,112,131
  set RETREF=%%~a1012459
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set OUTREF=%%~a0,0,111,111,121,321
  set RETREF=%%~a902369
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set OUTREF=%%~a0,0,1,111,111,213
  set RETREF=%%~a246357
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set OUTREF=%%~a0,0,11,111,112,132
  set RETREF=%%~a246348
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set OUTREF=%%~a0,0,111,111,121,322
  set RETREF=%%~a247258
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set OUTREF=%%~a0,0,1,111,111,213
  set RETREF=%%~a246924
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set OUTREF=%%~a0,0,11,111,112,132
  set RETREF=%%~a247026
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set OUTREF=%%~a0,0,111,111,121,322
  set RETREF=%%~a248047
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set OUTREF=%%~a0,0,1,111,111,213
  set RETREF=%%~a246924
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000
  set OUTREF=%%~a0,0,0,990,0,99
  set RETREF=%%~a11
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000
  set OUTREF=%%~a0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100
  set OUTREF=%%~a0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10
  set OUTREF=%%~a0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000
  set OUTREF=%%~a0,0,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000
  set OUTREF=%%~a0,0,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000
  set OUTREF=%%~a0,0,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000
  set OUTREF=%%~a0,0,0,0,90,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000
  set OUTREF=%%~a0,0,0,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000
  set OUTREF=%%~a0,0,0,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000
  set OUTREF=%%~a0,0,0,0,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000
  set OUTREF=%%~a0,0,0,0,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1
  set OUTREF=0,0,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set OUTREF=%%~a0,0,1,800,900,180
  set RETREF=%%~a100020
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a3,2,1
  set OUTREF=%%~a0,0,2,701,801,170
  set RETREF=%%~a200130
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set OUTREF=%%~a0,0,3,602,702,161
  set RETREF=%%~a189129
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set OUTREF=%%~a0,0,4,503,603,152
  set RETREF=%%~a179128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set OUTREF=%%~a0,0,5,404,504,143
  set RETREF=%%~a169128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,6,305,405,134
  set RETREF=%%~a159128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,7,206,306,125
  set RETREF=%%~a149128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,8,107,207,116
  set RETREF=%%~a139128
  call :TEST OUT L 1111111
  endlocal


  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,810,720,711,612
  set RETREF=%%~a579468
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,81,720,638,712
  set RETREF=%%~a571368
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,8,820,631,422
  set RETREF=%%~a570558
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,720,630,612,513
  set RETREF=%%~a468357
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a80,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,72,630,547,713
  set RETREF=%%~a461157
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a8,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,7,830,541,233
  set RETREF=%%~a460437
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,630,540,513,414
  set RETREF=%%~a357246
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a70,600,500,400,300,200,100
  set OUTREF=%%~a0,0,63,540,456,714
  set RETREF=%%~a350946
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a7,600,500,400,300,200,100
  set OUTREF=%%~a0,0,6,840,451,44
  set RETREF=%%~a350316
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a600,500,400,300,200,100
  set OUTREF=%%~a0,0,540,450,414,315
  set RETREF=%%~a246135
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a60,500,400,300,200,100
  set OUTREF=%%~a0,0,54,450,365,715
  set RETREF=%%~a240735
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a6,500,400,300,200,100
  set OUTREF=%%~a0,0,5,850,360,855
  set RETREF=%%~a240195
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a500,400,300,200,100
  set OUTREF=%%~a0,0,450,360,315,216
  set RETREF=%%~a135024
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a50,400,300,200,100
  set OUTREF=%%~a0,0,45,360,274,716
  set RETREF=%%~a130524
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a5,400,300,200,100
  set OUTREF=%%~a0,0,4,860,270,666
  set RETREF=%%~a130074
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a400,300,200,100
  set OUTREF=%%~a0,0,360,270,216,117
  set RETREF=%%~a24013
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a40,300,200,100
  set OUTREF=%%~a0,0,36,270,183,717
  set RETREF=%%~a20413
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a4,300,200,100
  set OUTREF=%%~a0,0,3,870,180,477
  set RETREF=%%~a20053
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a300,200,100
  set OUTREF=%%~a0,0,270,180,117,18
  set RETREF=%%~a13002
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a30,200,100
  set OUTREF=%%~a0,0,27,180,92,718
  set RETREF=%%~a10302
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a3,200,100
  set OUTREF=%%~a0,0,2,880,90,288
  set RETREF=%%~a10032
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a200,100
  set OUTREF=%%~a0,0,180,90,18,9
  set RETREF=%%~a2001
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a20,100
  set OUTREF=%%~a0,0,18,90,1,809
  set RETREF=%%~a201
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a2,100
  set OUTREF=%%~a0,0,1,890,0,189
  set RETREF=%%~a21
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  rem NOTE: near the overflow
  setlocal
  set L=%%~a1234
  set OUTREF=%%~a0,1,110,600,111,60
  set RETREF=%%~a12340
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234
  set OUTREF=%%~a0,1,111,710,711,171
  set RETREF=%%~a79019
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set OUTREF=%%~a0,1,111,711,821,771
  set RETREF=%%~a202419
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,881
  set RETREF=%%~a869209
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882
  set RETREF=%%~a992098
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882
  set RETREF=%%~a993332
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882
  set RETREF=%%~a993333
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882
  set RETREF=%%~a993333
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882
  set RETREF=%%~a993333
  call :TEST OUT L 1111111
  endlocal
)

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
