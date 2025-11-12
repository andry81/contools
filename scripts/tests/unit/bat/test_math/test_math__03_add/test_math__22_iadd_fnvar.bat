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
  set OUTREF=0,0,1,111,111,111
  call :TEST OUT L R
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set R=-0,0,1,111,111,111
  set OUTREF=-0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)

rem test on a maximum limit
setlocal
set L=0,0,0,0,0,2147483647
set R=0
set OUTREF=0,0,2,147,483,647
call :TEST_SWAP OUT L R
endlocal

rem CAUTION: L12 is still a signed integer number!
setlocal
set L=-0,0,0,0,0,2147483647
set R=0
set OUTREF=-0,0,2,147,483,647
call :TEST_SWAP OUT L R
endlocal

setlocal
set L=999,999,999,999,999,999
set R=0,0,2,147,482,647
set OUTREF=0,0,2,147,482,646
set RETREF=1
call :TEST_SWAP OUT L R
endlocal

setlocal
set L=-999,999,999,999,999,999
set R=-0,0,2,147,482,648
set OUTREF=-0,0,2,147,482,647
set RETREF=-1
call :TEST_SWAP OUT L R
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000
rem      set a=-1,2,3
rem      iadd_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0
setlocal
set L=-1,2,3
set OUTREF=-1,2,3,0,0,0
call :TEST OUT L
endlocal

rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,12,345
setlocal
set L=-1,2,3
set R=-0,0,0,0,0,12345
set OUTREF=-1,2,3,0,12,345
call :TEST_SWAP OUT L R
endlocal

rem   2. >
rem      set a=-0,0,0,1,2,3
rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,1,14,348
setlocal
set L=-0,0,0,1,2,3
set R=-0,0,0,0,0,12345
set OUTREF=-0,0,0,1,14,348
call :TEST_SWAP OUT L R
endlocal

rem   3. >
rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,12,345
setlocal
set R=-0,0,0,0,0,12345
set OUTREF=-0,0,0,0,12,345
call :TEST OUT L R
endlocal


rem sign change cases
for %%i in (" |-" "-| " "+|-" "-|+") do for /F "tokens=1,2 delims=|" %%a in ("%%~i") do (
  setlocal
  set L=%%~a1,0,0,0,0,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~a0,999,999,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,1,0,0,0,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~a0,0,999,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,1,0,0,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~a0,0,0,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,1,0,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~a0,0,0,0,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,0,1,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~a0,0,0,0,0,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,1
  set R=%%~b0,0,0,0,0,1
  set OUTREF=0,0,0,0,0,0
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a1,0,0,0,0,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~a0,999,999,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,1,0,0,0,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~a0,0,999,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,1,0,0,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~a0,0,0,999,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,1,0,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~a0,0,0,0,999,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,0,1,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~a0,0,0,0,0,999
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,1
  set R=%%~b0,0,0,0,0,2
  set OUTREF=%%~b0,0,0,0,0,1
  call :TEST OUT L R
  endlocal

  setlocal
  set L=%%~a0,0,0,0,0,0
  set R=%%~b0,0,0,0,0,1
  set OUTREF=%%~b0,0,0,0,0,1
  call :TEST OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,345,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,456,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,568,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,345,679,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,456,790,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,569,2,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,345,680,23,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,456,790,234,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,569,2,345,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,345,680,23,456,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,456,790,234,567,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,569,2,345,678
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a12,345,680,23,456,789
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a123,456,790,234,567,900
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,234,569,2,345,678
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,567,891,234,567,891
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a234,567,892,345,679,2
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12345,678,912,345,678,912
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a345,678,913,456,790,23
  set RETREF=%%~a12
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a10,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,10,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,1,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,11,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,2,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,211,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,121,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,112,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,211,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,121,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,112,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,111,211
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,111,121
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,111,111,112
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a2,1,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a3,2,2,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a4,3,3,112,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a5,4,4,113,112,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a6,5,5,114,113,112
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a7,6,6,115,114,113
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a8,7,7,116,115,114
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a9,8,8,117,116,115
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a900,800,701,711,611,511
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a90,800,701,711,611,511
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a9,800,701,711,611,511
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a800,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a800,700,601,611,511,411
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a80,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a80,700,601,611,511,411
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a8,700,601,611,511,411
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a700,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a700,600,501,511,411,311
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a70,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a70,600,501,511,411,311
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a7,600,501,511,411,311
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a600,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a600,500,401,411,311,211
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a60,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a60,500,401,411,311,211
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a6,500,401,411,311,211
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a500,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a500,400,301,311,211,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a50,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a50,400,301,311,211,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a5,400,301,311,211,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a400,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a400,300,201,211,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a40,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a40,300,201,211,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a4,300,201,211,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a300,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a300,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a30,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a30,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a3,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a200,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a200,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a20,100
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a20,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a234,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,234,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,345,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,346,345,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,346,346,345
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1111
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,346,346,346
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1998,1111
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,346,346,346
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1999,1111
  set R=%%~a0,0,1,111,111,111
  set OUTREF=%%~a235,235,236,346,346,347
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal
)

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

if not defined OUTREF goto SKIP_OUTREF
if "%OUTREF:~0,1%" == " " set "OUTREF=%OUTREF:~1%"
if "%OUTREF:~0,1%" == "+" set "OUTREF=%OUTREF:~1%"
:SKIP_OUTREF

call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
