@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "L="
set "OUT="
set "RETREF=0"

set ZEROS=000,000,000,000,000,000,000,000,000,000,000,000,000

rem NOTE:
rem   Opposite to `fold.bat` script, the `OUT` must be always at least
rem   `N,N,N,N,N,N,N,N,N,N,N,N` formatted if defined and the divisor is not 0.
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0


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
for %%i in ("+0" "-0" "+0,0,0,0,0,0" "-0,0,0,0,0,0" "+0,0,0,0,0,0,0,0,0,0,0,0" "-0,0,0,0,0,0,0,0,0,0,0,0") do (
  setlocal
  set "L=%%~i"
  call :TEST OUT L 1
  endlocal
)

for /L %%i in (1,1,51) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call :TEST OUT L 1
  endlocal
)

rem test on a maximum limit
setlocal
set L=999,999,999,999,999,999,999,999,999,999,999,999
set OUTREF=0,0,465,661,427,820,383,211,415,410,506,160
set RETREF=4719
call :TEST OUT L 2147483
endlocal

setlocal
set L=2,147,482,999,999,999,999,999,999,999,999,999
set OUTREF=0,0,0,999,999,999,999,999,999,999,999,999
set RETREF=2147482
call :TEST OUT L 2147483
endlocal

setlocal
set L=-999,999,999,999,999,999,999,999,999,999,999,999
set OUTREF=-0,0,465,661,427,820,383,211,415,410,506,160
set RETREF=-4719
call :TEST OUT L 2147483
endlocal

setlocal
set L=-2,147,482,999,999,999,999,999,999,999,999,999
set OUTREF=-0,0,0,999,999,999,999,999,999,999,999,999
set RETREF=-2147482
call :TEST OUT L 2147483
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -2,147,483,648,000,000,000,000,000,000,000,000
rem      set a=-2,147,483,648
rem      idiv2x.bat b a 123
rem      rem ERRORLEVEL=-8
rem      rem b=-0,17,459,216,650,406,504,65,40,650,406,504
setlocal
set L=-2,147,483,648
set OUTREF=-0,17,459,216,650,406,504,65,40,650,406,504
set RETREF=-8
call :TEST OUT L 123
endlocal

rem   2. >
rem      rem -1,023,045,067,890,000,000,000,000,000,000,000
rem      set a=-1,23,45,67,890
rem      idiv2x.bat b a 123456
rem      rem ERRORLEVEL=-33216
rem      rem b=-0,0,8,286,718,84,904,743,390,357,698,289
setlocal
set L=-1,23,45,67,890
set OUTREF=-0,0,8,286,718,84,904,743,390,357,698,289
set RETREF=-33216
call :TEST OUT L 123456
endlocal

rem   3. >
rem      rem -1,000,000,000,000,000,000,000,000,000,000,000
rem      set a=-1
rem      set b=x
rem      idiv2x.bat b a
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
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12
  set OUTREF=%%~a0,0,10,800,1,80,0,108,0,10,800,1
  set RETREF=%%~a88889
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123
  set OUTREF=%%~a0,0,110,700,11,70,1,107,0,110,700,11
  set RETREF=%%~a77779
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234
  set OUTREF=%%~a0,0,1,110,600,111,60,11,106,1,110,600
  set RETREF=%%~a123400
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345
  set OUTREF=%%~a0,0,11,110,501,111,50,111,105,11,110,501
  set RETREF=%%~a123389
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456
  set OUTREF=%%~a0,0,111,110,411,111,41,111,104,111,110,411
  set RETREF=%%~a123379
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567
  set OUTREF=%%~a0,0,1,111,110,411,111,41,111,104,111,110
  set RETREF=%%~a456790
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678
  set OUTREF=%%~a0,0,11,111,111,311,111,131,111,113,111,111
  set RETREF=%%~a345679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789
  set OUTREF=%%~a0,0,111,111,121,211,112,121,111,212,111,121
  set RETREF=%%~a234569
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set OUTREF=%%~a0,0,1,111,111,213,11,121,301,112,130,111
  set RETREF=%%~a236679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set OUTREF=%%~a0,0,11,111,112,131,911,213,191,121,319,112
  set RETREF=%%~a146568
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set OUTREF=%%~a0,0,111,111,121,321,812,132,181,213,218,121
  set RETREF=%%~a357569
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set OUTREF=%%~a0,0,1,111,111,213,221,721,322,172,132,217
  set RETREF=%%~a236913
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set OUTREF=%%~a0,0,11,111,112,132,221,713,222,171,322,217
  set RETREF=%%~a146913
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set OUTREF=%%~a0,0,111,111,121,322,222,532,222,253,222,225
  set RETREF=%%~a358025
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set OUTREF=%%~a0,0,1,111,111,213,222,231,622,223,162,222
  set RETREF=%%~a351358
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set OUTREF=%%~a0,0,11,111,112,132,222,323,422,232,342,223
  set RETREF=%%~a260247
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set OUTREF=%%~a0,0,111,111,121,322,223,242,322,324,232,232
  set RETREF=%%~a470248
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set OUTREF=%%~a0,0,1,111,111,213,222,232,424,123,242,412
  set RETREF=%%~a360268
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,990,0,99,0,9,900,0,990,0
  set RETREF=%%~a110000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100
  set OUTREF=%%~a0,0,90,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10
  set OUTREF=%%~a0,0,9,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1
  set OUTREF=%%~a0,0,0,900,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,90,0,9,0,0,900,0,90,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,9,0,0,900,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,900,0,90,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,90,0,9,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,9,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,900,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,90,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,9,0,0,900,0,90,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,900,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,90,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,9,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,900,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,90,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,9,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,900,0,90,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,100,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,90,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,10,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,9,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,1,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,900,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,100,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,90,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,10,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,9,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,1,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,900,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,100,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,90,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,10,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,9,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,1,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,0,900
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,00,000,000,000,100,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,0,90
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,10,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,0,0,9
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,1,000,000
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a1000000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,100,000
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a100000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,10,000
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a10000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,1,000
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a1000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,000,100
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,000,10
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a10
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,000,000,000,000,000,000,1
  set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set OUTREF=%%~a0,0,1,800,900,180,90,18,9,1,800,900
  set RETREF=%%~a200100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a3,2,1
  set OUTREF=%%~a0,0,2,701,801,170,180,117,18,11,701,801
  set RETREF=%%~a189089
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set OUTREF=%%~a0,0,3,602,702,161,170,216,117,21,611,702
  set RETREF=%%~a179078
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set OUTREF=%%~a0,0,4,503,603,152,161,215,216,121,521,612
  set RETREF=%%~a169068
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set OUTREF=%%~a0,0,5,404,504,143,152,215,215,221,521,522
  set RETREF=%%~a169058
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,6,305,405,134,143,215,215,221,521,522
  set RETREF=%%~a169058
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,7,206,306,125,134,215,215,222,421,522
  set RETREF=%%~a269058
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,8,107,207,116,125,215,215,223,322,422
  set RETREF=%%~a369158
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,810,720,711,612,521,521,522,332,242,233
  set RETREF=%%~a249137
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,81,720,638,712,514,231,521,603,242,160
  set RETREF=%%~a360240
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,8,820,631,422,513,502,521,530,342,153
  set RETREF=%%~a38017
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,720,630,612,513,421,521,522,242,152
  set RETREF=%%~a249128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,80,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,72,630,547,713,415,41,521,594,152
  set RETREF=%%~a177128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,8,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,7,830,541,233,414,393,521,529,352
  set RETREF=%%~a169928
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,630,540,513,414,321,521,522,152
  set RETREF=%%~a169128
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,70,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,63,540,456,714,315,851,521,585
  set RETREF=%%~a169065
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,7,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,6,840,451,44,315,284,521,528
  set RETREF=%%~a502392
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,540,450,414,315,221,521,522
  set RETREF=%%~a169058
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,60,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,54,450,365,715,216,661,521
  set RETREF=%%~a740169
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,6,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,5,850,360,855,216,175,521
  set RETREF=%%~a686169
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,450,360,315,216,121,521
  set RETREF=%%~a680169
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,50,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,45,360,274,716,117,471
  set RETREF=%%~a679719
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,5,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,4,860,270,666,117,66
  set RETREF=%%~a679674
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,400,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,360,270,216,117,21
  set RETREF=%%~a679669
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,40,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,36,270,183,717,18
  set RETREF=%%~a413002
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,4,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,3,870,180,477,18
  set RETREF=%%~a53002
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,300,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,270,180,117,18
  set RETREF=%%~a13002
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,30,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,27,180,92,718
  set RETREF=%%~a10302
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,3,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,2,880,90,288
  set RETREF=%%~a10032
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,0,200,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,180,90,18
  set RETREF=%%~a10002
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,0,20,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,18,90,1
  set RETREF=%%~a898889
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0,0,2,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,1,890,0
  set RETREF=%%~a210000
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1234
  set OUTREF=%%~a0,1,110,600,111,60,11,106,1,110,600,111
  set RETREF=%%~a66679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234
  set OUTREF=%%~a0,1,111,710,711,171,71,117,107,111,710,711
  set RETREF=%%~a190079
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set OUTREF=%%~a0,1,111,711,821,771,182,177,118,217,711,821
  set RETREF=%%~a856869
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,881,782,288,178,228,817,822
  set RETREF=%%~a979758
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882,892,888,289,288,828,928
  set RETREF=%%~a980992
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882,893,998,889,399,888,939
  set RETREF=%%~a1098771
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882,894,0,0,0,0,0
  set RETREF=%%~a0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882,894,0,1,110,600,111
  set RETREF=%%~a66679
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,1,111,711,822,882,894,0,1,111,710,711
  set RETREF=%%~a190079
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
