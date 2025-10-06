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
set L=-1
set "OUTREF="
call :TEST "" L -1
endlocal

setlocal
set "OUTREF="
call :TEST "" L -1
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
set L=1
call :TEST OUT L
endlocal

setlocal
set OUT=x
call :TEST OUT "" 0
endlocal

rem signed zero case
for %%i in ("+0" "-0" "+0,0,0,0,0,0" "-0,0,0,0,0,0") do (
  setlocal
  set "L=%%~i"
  call :TEST OUT L 0
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call :TEST OUT L 0
  endlocal
)

for /L %%i in (1,1,27) do (
  setlocal
  call set "L=%%ZEROS:~0,%%i%%"
  call :TEST OUT L 1111111
  endlocal
)

rem test on a maximum limit
setlocal
set L=998,998,998,998,998,999
set OUTREF=215,215,215,215,217,367
set RETREF=2147481
call :TEST OUT L 2149633
endlocal

setlocal
set L=-998,998,998,998,998,999
set OUTREF=-215,215,215,215,217,367
set RETREF=-2147481
call :TEST OUT L 2149633
endlocal

rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000
rem      set a=-1,2,3
rem      imul.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
setlocal
set L=-1,2,3
set OUTREF=0,0,0,0,0,0
call :TEST OUT L
endlocal

rem      imul.bat b a 12345
rem      rem ERRORLEVEL=-12
rem      rem b=-369,727,35,0,0,0
setlocal
set L=-1,2,3
set OUTREF=-369,727,35,0,0,0
set RETREF=-12
call :TEST OUT L 12345
endlocal

rem   2. >
rem      set a=-0,0,0,1,2,3
rem      imul.bat b a 12345
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,12,369,727,35
setlocal
set L=-0,0,0,1,2,3
set OUTREF=-0,0,12,369,727,35
call :TEST OUT L 12345
endlocal

rem   3. >
rem      imul.bat b "" 12345
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
setlocal
set OUTREF=0,0,0,0,0,0
call :TEST OUT L 12345
endlocal


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12
  set OUTREF=%%~a332,0,0,0,0,0
  set RETREF=%%~a13333
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123
  set OUTREF=%%~a653,0,0,0,0,0
  set RETREF=%%~a136666
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234
  set OUTREF=%%~a110,974,0,0,0,0
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345
  set OUTREF=%%~a665,295,0,0,0,0
  set RETREF=%%~a13716
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456
  set OUTREF=%%~a319,616,0,0,0,0
  set RETREF=%%~a137173
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567
  set OUTREF=%%~a740,973,937,0,0,0
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678
  set OUTREF=%%~a418,628,258,0,0,0
  set RETREF=%%~a13717
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789
  set OUTREF=%%~a196,282,579,0,0,0
  set RETREF=%%~a137174
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891
  set OUTREF=%%~a741,963,936,901,0,0
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912
  set OUTREF=%%~a419,641,591,232,0,0
  set RETREF=%%~a13717
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123
  set OUTREF=%%~a196,419,245,653,0,0
  set RETREF=%%~a137174
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234
  set OUTREF=%%~a741,964,196,900,974,0
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345
  set OUTREF=%%~a419,641,974,565,295,0
  set RETREF=%%~a13717
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456
  set OUTREF=%%~a196,419,752,319,616,0
  set RETREF=%%~a137174
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567
  set OUTREF=%%~a741,964,197,530,973,937
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a12,345,678,912,345,678
  set OUTREF=%%~a419,641,975,318,628,258
  set RETREF=%%~a13717
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a123,456,789,123,456,789
  set OUTREF=%%~a196,419,753,196,282,579
  set RETREF=%%~a137174
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,234,567,891,234,567,891
  set OUTREF=%%~a741,964,197,531,963,936
  set RETREF=%%~a1371
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a1,000,000,000,000,000,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,100,000,000,000,000,000
  set OUTREF=%%~a222,100,0,0,0,0
  set RETREF=%%~a1222
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000,000
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000,000
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000,000
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000,000
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000,000
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000,000
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000,000
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000,000
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100,000
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10,000
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1,000
  set OUTREF=%%~a111,0,0,0,0,0
  set RETREF=%%~a1111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a100
  set OUTREF=%%~a100,0,0,0,0,0
  set RETREF=%%~a111111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a10
  set OUTREF=%%~a110,0,0,0,0,0
  set RETREF=%%~a11111
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a000,100,000,000,000,000
  set OUTREF=%%~a111,100,0,0,0,0
  set RETREF=%%~a111
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,10,000,000,000,000
  set OUTREF=%%~a111,110,0,0,0,0
  set RETREF=%%~a11
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,1,000,000,000,000
  set OUTREF=%%~a111,111,0,0,0,0
  set RETREF=%%~a1
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,100,000,000,000
  set OUTREF=%%~a111,111,100,0,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,10,000,000,000
  set OUTREF=%%~a11,111,110,0,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,1,000,000,000
  set OUTREF=%%~a1,111,111,0,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,100,000,000
  set OUTREF=%%~a0,111,111,100,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,10,000,000
  set OUTREF=%%~a0,11,111,110,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,1,000,000
  set OUTREF=%%~a0,1,111,111,0,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,100,000
  set OUTREF=%%~a0,0,111,111,100,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,10,000
  set OUTREF=%%~a0,0,11,111,110,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,1,000
  set OUTREF=%%~a0,0,1,111,111,0
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,100
  set OUTREF=%%~a0,0,0,111,111,100
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,10
  set OUTREF=%%~a0,0,0,11,111,110
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a000,000,000,000,000,1
  set OUTREF=%%~a0,0,0,1,111,111
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a2,1
  set OUTREF=%%~a333,111,0,0,0,0
  set RETREF=%%~a2223
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a3,2,1
  set OUTREF=%%~a556,333,111,0,0,0
  set RETREF=%%~a3335
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a4,3,2,1
  set OUTREF=%%~a779,556,333,111,0,0
  set RETREF=%%~a4447
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a5,4,3,2,1
  set OUTREF=%%~a2,779,556,333,111,0
  set RETREF=%%~a5560
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a6,5,4,3,2,1
  set OUTREF=%%~a226,2,779,556,333,111
  set RETREF=%%~a6672
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a7,6,5,4,3,2,1
  set OUTREF=%%~a449,226,2,779,556,333
  set RETREF=%%~a7784
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a8,7,6,5,4,3,2,1
  set OUTREF=%%~a672,449,226,2,779,556
  set RETREF=%%~a8896
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,8,7,6,5,4,3,2,1
  set OUTREF=%%~a895,672,449,226,2,779
  set RETREF=%%~a10008
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  setlocal
  set L=%%~a900,800,700,600,500,400,300,200,100
  set OUTREF=%%~a567,244,922,600,277,955
  set RETREF=%%~a1000889
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a90,800,700,600,500,400,300,200,100
  set OUTREF=%%~a657,244,922,600,277,955
  set RETREF=%%~a100889
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a9,800,700,600,500,400,300,200,100
  set OUTREF=%%~a666,244,922,600,277,955
  set RETREF=%%~a10889
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a800,700,600,500,400,300,200,100
  set OUTREF=%%~a244,922,600,277,955,633
  set RETREF=%%~a889667
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a80,700,600,500,400,300,200,100
  set OUTREF=%%~a324,922,600,277,955,633
  set RETREF=%%~a89667
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a8,700,600,500,400,300,200,100
  set OUTREF=%%~a332,922,600,277,955,633
  set RETREF=%%~a9667
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a700,600,500,400,300,200,100
  set OUTREF=%%~a922,600,277,955,633,311
  set RETREF=%%~a778444
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a70,600,500,400,300,200,100
  set OUTREF=%%~a992,600,277,955,633,311
  set RETREF=%%~a78444
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a7,600,500,400,300,200,100
  set OUTREF=%%~a999,600,277,955,633,311
  set RETREF=%%~a8444
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a600,500,400,300,200,100
  set OUTREF=%%~a600,277,955,633,311,100
  set RETREF=%%~a667222
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a60,500,400,300,200,100
  set OUTREF=%%~a660,277,955,633,311,100
  set RETREF=%%~a67222
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a6,500,400,300,200,100
  set OUTREF=%%~a666,277,955,633,311,100
  set RETREF=%%~a7222
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a500,400,300,200,100
  set OUTREF=%%~a277,955,633,311,100,0
  set RETREF=%%~a556000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a50,400,300,200,100
  set OUTREF=%%~a327,955,633,311,100,0
  set RETREF=%%~a56000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a5,400,300,200,100
  set OUTREF=%%~a332,955,633,311,100,0
  set RETREF=%%~a6000
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a400,300,200,100
  set OUTREF=%%~a955,633,311,100,0,0
  set RETREF=%%~a444777
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a40,300,200,100
  set OUTREF=%%~a995,633,311,100,0,0
  set RETREF=%%~a44777
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a4,300,200,100
  set OUTREF=%%~a999,633,311,100,0,0
  set RETREF=%%~a4777
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a300,200,100
  set OUTREF=%%~a633,311,100,0,0,0
  set RETREF=%%~a333555
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a30,200,100
  set OUTREF=%%~a663,311,100,0,0,0
  set RETREF=%%~a33555
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a3,200,100
  set OUTREF=%%~a666,311,100,0,0,0
  set RETREF=%%~a3555
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a200,100
  set OUTREF=%%~a311,100,0,0,0,0
  set RETREF=%%~a222333
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a20,100
  set OUTREF=%%~a331,100,0,0,0,0
  set RETREF=%%~a22333
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a2,100
  set OUTREF=%%~a333,100,0,0,0,0
  set RETREF=%%~a2333
  call :TEST OUT L 1111111
  endlocal
)


for %%a in ("" "-") do (
  rem NOTE: near the overflow
  setlocal
  set L=%%~a1234
  set OUTREF=%%~a974,0,0,0,0,0
  set RETREF=%%~a1371110
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234
  set OUTREF=%%~a84,974,0,0,0,0
  set RETREF=%%~a1372482
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234
  set OUTREF=%%~a456,84,974,0,0,0
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234
  set OUTREF=%%~a457,456,84,974,0,0
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234
  set OUTREF=%%~a457,457,456,84,974,0
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a457,457,457,456,84,974
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a457,457,457,457,456,84
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a457,457,457,457,457,456
  set RETREF=%%~a1372483
  call :TEST OUT L 1111111
  endlocal

  setlocal
  set L=%%~a1234,1234,1234,1234,1234,1234,1234,1234,1234
  set OUTREF=%%~a457,457,457,457,457,457
  set RETREF=%%~a1372483
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
