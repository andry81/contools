@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "L="
set "R="
set "OUT="
set "RETREF=0"

set ZEROS=000,000,000,000,000,000,000

rem NOTE:
rem   Opposite to `fold.bat` script, the `OUT` must be always at least
rem   `N,N,N,N,N,N` formatted if defined.
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0

goto x
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
set "OUTREF="
call :TEST "" "" R
endlocal

setlocal
set R=1
set "OUTREF="
call :TEST "" "" R
endlocal

setlocal
set "OUTREF="
call :TEST "" L R
endlocal

setlocal
set L=1
set "OUTREF="
call :TEST "" L R
endlocal

setlocal
set R=1
set "OUTREF="
call :TEST "" L R
endlocal

setlocal
set L=1
set R=1
set "OUTREF="
call :TEST "" L R
endlocal

setlocal
set L=-1
set R=-1
set "OUTREF="
call :TEST "" L R
endlocal

setlocal
set "OUTREF="
call :TEST "" L R
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
call :TEST OUT "" R
endlocal

setlocal
set R=0
set OUT=x
call :TEST OUT "" R
endlocal

rem signed zero case
for %%i in ("+0" "-0" "+0,0,0,0,0,0" "-0,0,0,0,0,0") do (
  setlocal
  set "L=%%~i"
  set R=0
  call :TEST_SWAP OUT L R
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call set "R=%%L%%"
  call :TEST OUT L R
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set R=0,0,1,111,111,111
  call :TEST OUT L R
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set R=-0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)

rem test on a maximum limit
setlocal
set L=999,999,999,999,999,999
set R=999,999,999,999,999,999
set OUTREF=999,999,999,999,999,998,0,0,0,0,0,1
call :TEST OUT L R
endlocal

setlocal
set L=-999,999,999,999,999,999
set R=999,999,999,999,999,999
set OUTREF=-999,999,999,999,999,998,0,0,0,0,0,1
call :TEST OUT L R
endlocal

rem maximum in A1
setlocal
set L=46339,999,999,999,999,999
set R=46339,999,999,999,999,999
set OUTREF=395,599,999,999,999,907,320,0,0,0,0,1
set RETREF=2147
call :TEST OUT L R
endlocal

setlocal
set L=-46339,999,999,999,999,999
set R=46339,999,999,999,999,999
set OUTREF=-395,599,999,999,999,907,320,0,0,0,0,1
set RETREF=-2147
call :TEST OUT L R
endlocal

rem maximum in An
setlocal
set L=18910,18910,18910,18910,18910,18910
set R=18910,18910,18910,18910,18910,18910
set OUTREF=304,350,396,442,487,817,971,925,879,833,788,100
set RETREF=358
call :TEST OUT L R
endlocal

setlocal
set L=-18910,18910,18910,18910,18910,18910
set R=18910,18910,18910,18910,18910,18910
set OUTREF=-304,350,396,442,487,817,971,925,879,833,788,100
set RETREF=-358
call :TEST OUT L R
endlocal

rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000
rem      set a=-1,2,3
rem      imul2x_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0
setlocal
set L=-1,2,3
call :TEST OUT L R
endlocal

rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,12,369,727,35,0,0,0
setlocal
set L=-1,2,3
set R=0,0,0,0,0,12345
set OUTREF=-0,0,0,0,0,12,369,727,35,0,0,0
call :TEST_SWAP OUT L R
endlocal

rem   2. >
rem      set a=-0,0,0,1,2,3
rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,12,369,727,35
setlocal
set L=-0,0,0,1,2,3
set R=0,0,0,0,0,12345
set OUTREF=-0,0,0,0,0,0,0,0,12,369,727,35
call :TEST_SWAP OUT L R
endlocal

rem   3. >
rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0,0,0,0,0,0,0
setlocal
set R=0,0,0,0,0,12345
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0
call :TEST OUT L R
endlocal

:x
setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  setlocal
  set L=%%~a1
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12
  set OUTREF=%%~a0,0,0,0,13,333,332,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123
  set OUTREF=%%~a0,0,0,0,136,666,653,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234
  set OUTREF=%%~a0,0,0,0,1,371,110,974,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345
  set OUTREF=%%~a0,0,0,0,13,716,665,295,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456
  set OUTREF=%%~a0,0,0,0,137,173,319,616,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567
  set OUTREF=%%~a0,0,0,0,1,371,740,973,937,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678
  set OUTREF=%%~a0,0,0,0,13,717,418,628,258,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789
  set OUTREF=%%~a0,0,0,0,137,174,196,282,579,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set OUTREF=%%~a0,0,0,0,1,371,741,963,936,901,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set OUTREF=%%~a0,0,0,0,13,717,419,641,591,232,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set OUTREF=%%~a0,0,0,0,137,174,196,419,245,653,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set OUTREF=%%~a0,0,0,0,1,371,741,964,196,900,974,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set OUTREF=%%~a0,0,0,0,13,717,419,641,974,565,295,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set OUTREF=%%~a0,0,0,0,137,174,196,419,752,319,616,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set OUTREF=%%~a0,0,0,0,1,371,741,964,197,530,973,937
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set OUTREF=%%~a0,0,0,0,13,717,419,641,975,318,628,258
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set OUTREF=%%~a0,0,0,0,137,174,196,419,753,196,282,579
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set OUTREF=%%~a0,0,0,0,1,371,741,964,197,530,973,937
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal


setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,1,222,222,100,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000
  set OUTREF=%%~a0,0,0,0,1,111,111,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100
  set OUTREF=%%~a0,0,0,0,111,111,100,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10
  set OUTREF=%%~a0,0,0,0,11,111,110,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal


setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,111,111,100,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,11,111,110,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000
  set OUTREF=%%~a0,0,0,0,0,1,111,111,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,111,111,100,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,11,111,110,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000
  set OUTREF=%%~a0,0,0,0,0,0,1,111,111,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,111,111,100,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,11,111,110,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000
  set OUTREF=%%~a0,0,0,0,0,0,0,1,111,111,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,111,111,100,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,11,111,110,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000
  set OUTREF=%%~a0,0,0,0,0,0,0,0,1,111,111,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,111,111,100
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,11,111,110
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1
  set OUTREF=%%~a0,0,0,0,0,0,0,0,0,1,111,111
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal


setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set OUTREF=%%~a0,0,0,0,2,223,333,111,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,2,1
  set OUTREF=%%~a0,0,0,0,3,335,556,333,111,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set OUTREF=%%~a0,0,0,0,4,447,779,556,333,111,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set OUTREF=%%~a0,0,0,0,5,560,2,779,556,333,111,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set OUTREF=%%~a0,0,0,0,6,672,226,2,779,556,333,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,0,0,7,784,449,226,2,779,555,222
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,0,0,8,896,672,449,226,2,777,333
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set OUTREF=%%~a0,0,0,0,10,8,895,672,449,225,999,444
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal


setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,1,0,889,567,244,922,599,944,400
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,100,889,657,244,922,599,944,400
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,10,889,666,244,922,599,944,400
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a800,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,889,667,244,922,600,277,733,300
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a80,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,89,667,324,922,600,277,733,300
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,9,667,332,922,600,277,733,300
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a700,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,778,444,922,600,277,955,522,200
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a70,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,78,444,992,600,277,955,522,200
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,8,444,999,600,277,955,522,200
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a600,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,667,222,600,277,955,633,311,100
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a60,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,67,222,660,277,955,633,311,100
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,7,222,666,277,955,633,311,100
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a500,400,300,200,100
  set OUTREF=%%~a0,0,0,0,556,0,277,955,633,311,100,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a50,400,300,200,100
  set OUTREF=%%~a0,0,0,0,56,0,327,955,633,311,100,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,400,300,200,100
  set OUTREF=%%~a0,0,0,0,6,0,332,955,633,311,100,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a400,300,200,100
  set OUTREF=%%~a0,0,0,0,444,777,955,633,311,100,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a40,300,200,100
  set OUTREF=%%~a0,0,0,0,44,777,995,633,311,100,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,300,200,100
  set OUTREF=%%~a0,0,0,0,4,777,999,633,311,100,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a300,200,100
  set OUTREF=%%~a0,0,0,0,333,555,633,311,100,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a30,200,100
  set OUTREF=%%~a0,0,0,0,33,555,663,311,100,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,200,100
  set OUTREF=%%~a0,0,0,0,3,555,666,311,100,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a200,100
  set OUTREF=%%~a0,0,0,0,222,333,311,100,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a20,100
  set OUTREF=%%~a0,0,0,0,22,333,331,100,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a2,100
  set OUTREF=%%~a0,0,0,0,2,333,333,100,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal


setlocal
set R=0,0,0,1,111,111
for %%a in ("" "-") do (
  rem NOTE: near the overflow
  setlocal
  set L=%%~a1234
  set OUTREF=%%~a0,0,0,1,371,110,974,0,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234
  set OUTREF=%%~a0,0,0,1,372,482,84,974,0,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,456,84,974,0,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,456,84,974,0,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,457,456,84,974,0
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,457,457,456,84,974
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,457,457,457,196,85
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,457,457,457,196,85
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a0,0,0,1,372,483,457,457,457,457,196,85
  call :TEST_SWAP OUT L R
  endlocal
)
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST_SWAP
set "L_=%~2"
set "R_=%~3"
if "%L_:~-1%" == "," exit /b 0
if "%R_:~-1%" == "," exit /b 0
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %1 %3 %2
exit /b

:TEST
set "L_=%~2"
set "R_=%~3"
if "%L_:~-1%" == "," exit /b 0
if "%R_:~-1%" == "," exit /b 0
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
