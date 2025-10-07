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

set ZEROS=000,000,000,000,000,000,000,000,000,000,000,000,000

rem NOTE:
rem   Opposite to `fold.bat` script, the `OUT` must be always at least
rem   `N,N,N,N,N,N,N,N,N,N,N,N` formatted if defined.
set OUTREF=0,0,0,0,0,0,0,0,0,0,0,0


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

for /L %%i in (1,1,51) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set R=0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=0,0,0,0,0,0,0,0,1,111,111,111
  call :TEST OUT L R
  endlocal
)

for /L %%i in (1,1,51) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  set R=-0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=-0,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)

rem test on a maximum limit
setlocal
set L=999,999,999,999,999,999,999,999,999,999,999,999
set R=0,0,0,0,0,0,0,0,2,147,482,648
set OUTREF=0,0,0,0,0,0,0,0,2,147,482,647
set RETREF=1
call :TEST_SWAP OUT L R
endlocal

setlocal
set L=-999,999,999,999,999,999,999,999,999,999,999,999
set R=-0,0,0,0,0,0,0,0,2,147,482,649
set OUTREF=-0,0,0,0,0,0,0,0,2,147,482,648
set RETREF=-1
call :TEST_SWAP OUT L R
endlocal


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000,000,000,000,000,000,000
rem      set a=-1,2,3
rem      iadd2x_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0,0,0,0,0,0,0
setlocal
set L=-1,2,3
set OUTREF=-1,2,3,0,0,0,0,0,0,0,0,0
call :TEST OUT L
endlocal

rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0,0,0,0,0,12,345
setlocal
set L=-1,2,3
set R=-0,0,0,0,0,0,0,0,0,0,0,12345
set OUTREF=-1,2,3,0,0,0,0,0,0,0,12,345
call :TEST_SWAP OUT L R
endlocal

rem   2. >
rem      set a=-0,0,0,0,0,0,0,0,0,1,2,3
rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,0,1,14,348
setlocal
set L=-0,0,0,0,0,0,0,0,0,1,2,3
set R=-0,0,0,0,0,0,0,0,0,0,0,12345
set OUTREF=-0,0,0,0,0,0,0,0,0,1,14,348
call :TEST_SWAP OUT L R
endlocal

rem   3. >
rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,0,0,12,345
setlocal
set R=-0,0,0,0,0,0,0,0,0,0,0,12345
set OUTREF=-0,0,0,0,0,0,0,0,0,0,12,345
call :TEST OUT L R
endlocal


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,345,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,456,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,567,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,345,678,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,456,789,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,567,891,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,345,678,912,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,456,789,123,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,567,891,234,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,345,678,912,345,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,456,789,123,456,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,567,891,234,567,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a12,345,678,912,345,678,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a123,456,789,123,456,789,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,234,567,891,234,567,891,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,567,891,234,567,891
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a234,567,891,234,567,891,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a12345,678,912,345,678,912
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a345,678,912,345,678,912,0,0,1,111,111,111
  set RETREF=%%~a12
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,100,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a1,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a100,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a10
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a10,0,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,100,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,10,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,1,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,100,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,10,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,1,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,100,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,10,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,1,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,100,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,10,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,1,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,0,100,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,0,10,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a0,0,0,0,0,1,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a2,1,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a3,2,1,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a4,3,2,1,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a5,4,3,2,1,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a6,5,4,3,2,1,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a7,6,5,4,3,2,1,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a8,7,6,5,4,3,2,1,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a9,8,7,6,5,4,3,2,2,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a900,800,700,600,500,400,300,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a90,800,700,600,500,400,300,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a9,800,700,600,500,400,300,200,101,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a800,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a800,700,600,500,400,300,200,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a80,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a80,700,600,500,400,300,200,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a8,700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a8,700,600,500,400,300,200,100,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a700,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a700,600,500,400,300,200,100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a70,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a70,600,500,400,300,200,100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a7,600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a7,600,500,400,300,200,100,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a600,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a600,500,400,300,200,100,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a60,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a60,500,400,300,200,100,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a6,500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a6,500,400,300,200,100,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a500,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a500,400,300,200,100,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a50,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a50,400,300,200,100,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a5,400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a5,400,300,200,100,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a400,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a400,300,200,100,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a40,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a40,300,200,100,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a4,300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a4,300,200,100,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a300,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a300,200,100,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a30,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a30,200,100,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a3,200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a3,200,100,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a200,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a200,100,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a20,100
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a20,100,0,0,0,0,0,0,1,111,111,111
  call :TEST_SWAP OUT L R
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a234,0,0,0,0,0,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,234,0,0,0,0,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,234,0,0,0,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,234,0,0,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,235,234,0,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,235,235,234,0,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1111
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,235,235,235,111,0,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1998,1111
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,235,235,235,999,111,1,111,111,111
  set RETREF=%%~a1
  call :TEST_SWAP OUT L R
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1999,1111
  set R=%%~a0,0,0,0,0,0,0,0,1,111,111,111
  set OUTREF=%%~a235,235,235,235,235,236,0,111,1,111,111,111
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
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
