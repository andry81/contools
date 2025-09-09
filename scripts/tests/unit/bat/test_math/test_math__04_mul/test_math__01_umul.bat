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
set RETREF=0
call :TEST
endlocal

setlocal
set "OUTREF="
set RETREF=0
call :TEST "" L
endlocal

setlocal
set L=1
set "OUTREF="
set RETREF=0
call :TEST "" L
endlocal

setlocal
set L=1
set "OUTREF="
set RETREF=0
call :TEST "" L 1
endlocal

setlocal
set "OUTREF="
set RETREF=0
call :TEST "" L 1
endlocal

setlocal
set OUT=x
set RETREF=0
call :TEST OUT
endlocal

setlocal
set OUT=x
set RETREF=0
call :TEST OUT L
endlocal

setlocal
set L=1
set RETREF=0
call :TEST OUT L
endlocal

setlocal
set OUT=x
set RETREF=0
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


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      set a=1,2,3
rem      umul.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
setlocal
set L=1,2,3
set OUTREF=0,0,0,0,0,0
call :TEST OUT L
endlocal

rem      umul.bat b a 12345
rem      rem ERRORLEVEL=12
rem      rem b=369,727,35,0,0,0
setlocal
set L=1,2,3
set OUTREF=369,727,35,0,0,0
set RETREF=12
call :TEST OUT L 12345
endlocal

rem   2. >
rem      set a=0,0,0,1,2,3
rem      umul.bat b a 12345
rem      rem ERRORLEVEL=0
rem      rem b=0,0,12,369,727,35
setlocal
set L=0,0,0,1,2,3
set OUTREF=0,0,12,369,727,35
call :TEST OUT L 12345
endlocal

rem   3. >
rem      umul.bat b "" 12345
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
setlocal
set OUTREF=0,0,0,0,0,0
set RETREF=0
call :TEST OUT L 12345
endlocal


setlocal
set L=1
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=12
set OUTREF=332,0,0,0,0,0
set RETREF=13333
call :TEST OUT L 1111111
endlocal

setlocal
set L=123
set OUTREF=653,0,0,0,0,0
set RETREF=136666
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234
set OUTREF=110,974,0,0,0,0
set RETREF=1371
call :TEST OUT L 1111111
endlocal

setlocal
set L=12,345
set OUTREF=665,295,0,0,0,0
set RETREF=13716
call :TEST OUT L 1111111
endlocal

setlocal
set L=123,456
set OUTREF=319,616,0,0,0,0
set RETREF=137173
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234,567
set OUTREF=740,973,937,0,0,0
set RETREF=1371
call :TEST OUT L 1111111
endlocal

setlocal
set L=12,345,678
set OUTREF=418,628,258,0,0,0
set RETREF=13717
call :TEST OUT L 1111111
endlocal

setlocal
set L=123,456,789
set OUTREF=196,282,579,0,0,0
set RETREF=137174
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234,567,891
set OUTREF=741,963,936,901,0,0
set RETREF=1371
call :TEST OUT L 1111111
endlocal

setlocal
set L=12,345,678,912
set OUTREF=419,641,591,232,0,0
set RETREF=13717
call :TEST OUT L 1111111
endlocal

setlocal
set L=123,456,789,123
set OUTREF=196,419,245,653,0,0
set RETREF=137174
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234,567,891,234
set OUTREF=741,964,196,900,974,0
set RETREF=1371
call :TEST OUT L 1111111
endlocal

setlocal
set L=12,345,678,912,345
set OUTREF=419,641,974,565,295,0
set RETREF=13717
call :TEST OUT L 1111111
endlocal

setlocal
set L=123,456,789,123,456
set OUTREF=196,419,752,319,616,0
set RETREF=137174
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234,567,891,234,567
set OUTREF=741,964,197,530,973,937
set RETREF=1371
call :TEST OUT L 1111111
endlocal

setlocal
set L=12,345,678,912,345,678
set OUTREF=419,641,975,318,628,258
set RETREF=13717
call :TEST OUT L 1111111
endlocal

setlocal
set L=123,456,789,123,456,789
set OUTREF=196,419,753,196,282,579
set RETREF=137174
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,234,567,891,234,567,891
set OUTREF=741,964,197,531,963,936
set RETREF=1371
call :TEST OUT L 1111111
endlocal


setlocal
set L=1,000,000,000,000,000,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,100,000,000,000,000,000
set OUTREF=222,100,0,0,0,0
set RETREF=1222
call :TEST OUT L 1111111
endlocal

setlocal
set L=100,000,000,000,000,000
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10,000,000,000,000,000
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,000,000,000,000,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=100,000,000,000,000
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10,000,000,000,000
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,000,000,000,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=100,000,000,000
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10,000,000,000
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,000,000,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=100,000,000
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10,000,000
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,000,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=100,000
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10,000
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal

setlocal
set L=1,000
set OUTREF=111,0,0,0,0,0
set RETREF=1111
call :TEST OUT L 1111111
endlocal

setlocal
set L=100
set OUTREF=100,0,0,0,0,0
set RETREF=111111
call :TEST OUT L 1111111
endlocal

setlocal
set L=10
set OUTREF=110,0,0,0,0,0
set RETREF=11111
call :TEST OUT L 1111111
endlocal


setlocal
set L=000,100,000,000,000,000
set OUTREF=111,100,0,0,0,0
set RETREF=111
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,10,000,000,000,000
set OUTREF=111,110,0,0,0,0
set RETREF=11
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,1,000,000,000,000
set OUTREF=111,111,0,0,0,0
set RETREF=1
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,100,000,000,000
set OUTREF=111,111,100,0,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,10,000,000,000
set OUTREF=11,111,110,0,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,1,000,000,000
set OUTREF=1,111,111,0,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,100,000,000
set OUTREF=0,111,111,100,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,10,000,000
set OUTREF=0,11,111,110,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,1,000,000
set OUTREF=0,1,111,111,0,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,100,000
set OUTREF=0,0,111,111,100,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,10,000
set OUTREF=0,0,11,111,110,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,1,000
set OUTREF=0,0,1,111,111,0
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,000,100
set OUTREF=0,0,0,111,111,100
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,000,10
set OUTREF=0,0,0,11,111,110
call :TEST OUT L 1111111
endlocal

setlocal
set L=000,000,000,000,000,1
set OUTREF=0,0,0,1,111,111
call :TEST OUT L 1111111
endlocal


setlocal
set L=2,1
set OUTREF=333,111,0,0,0,0
set RETREF=2223
call :TEST OUT L 1111111
endlocal

setlocal
set L=3,2,1
set OUTREF=556,333,111,0,0,0
set RETREF=3335
call :TEST OUT L 1111111
endlocal

setlocal
set L=4,3,2,1
set OUTREF=779,556,333,111,0,0
set RETREF=4447
call :TEST OUT L 1111111
endlocal

setlocal
set L=5,4,3,2,1
set OUTREF=2,779,556,333,111,0
set RETREF=5560
call :TEST OUT L 1111111
endlocal

setlocal
set L=6,5,4,3,2,1
set OUTREF=226,2,779,556,333,111
set RETREF=6672
call :TEST OUT L 1111111
endlocal

setlocal
set L=7,6,5,4,3,2,1
set OUTREF=449,226,2,779,556,333
set RETREF=7784
call :TEST OUT L 1111111
endlocal

setlocal
set L=8,7,6,5,4,3,2,1
set OUTREF=672,449,226,2,779,556
set RETREF=8896
call :TEST OUT L 1111111
endlocal

setlocal
set L=9,8,7,6,5,4,3,2,1
set OUTREF=895,672,449,226,2,779
set RETREF=10008
call :TEST OUT L 1111111
endlocal


setlocal
set L=900,800,700,600,500,400,300,200,100
set OUTREF=567,244,922,600,277,955
set RETREF=1000889
call :TEST OUT L 1111111
endlocal

setlocal
set L=90,800,700,600,500,400,300,200,100
set OUTREF=657,244,922,600,277,955
set RETREF=100889
call :TEST OUT L 1111111
endlocal

setlocal
set L=9,800,700,600,500,400,300,200,100
set OUTREF=666,244,922,600,277,955
set RETREF=10889
call :TEST OUT L 1111111
endlocal

setlocal
set L=800,700,600,500,400,300,200,100
set OUTREF=244,922,600,277,955,633
set RETREF=889667
call :TEST OUT L 1111111
endlocal

setlocal
set L=80,700,600,500,400,300,200,100
set OUTREF=324,922,600,277,955,633
set RETREF=89667
call :TEST OUT L 1111111
endlocal

setlocal
set L=8,700,600,500,400,300,200,100
set OUTREF=332,922,600,277,955,633
set RETREF=9667
call :TEST OUT L 1111111
endlocal

setlocal
set L=700,600,500,400,300,200,100
set OUTREF=922,600,277,955,633,311
set RETREF=778444
call :TEST OUT L 1111111
endlocal

setlocal
set L=70,600,500,400,300,200,100
set OUTREF=992,600,277,955,633,311
set RETREF=78444
call :TEST OUT L 1111111
endlocal

setlocal
set L=7,600,500,400,300,200,100
set OUTREF=999,600,277,955,633,311
set RETREF=8444
call :TEST OUT L 1111111
endlocal

setlocal
set L=600,500,400,300,200,100
set OUTREF=600,277,955,633,311,100
set RETREF=667222
call :TEST OUT L 1111111
endlocal

setlocal
set L=60,500,400,300,200,100
set OUTREF=660,277,955,633,311,100
set RETREF=67222
call :TEST OUT L 1111111
endlocal

setlocal
set L=6,500,400,300,200,100
set OUTREF=666,277,955,633,311,100
set RETREF=7222
call :TEST OUT L 1111111
endlocal

setlocal
set L=500,400,300,200,100
set OUTREF=277,955,633,311,100,0
set RETREF=556000
call :TEST OUT L 1111111
endlocal

setlocal
set L=50,400,300,200,100
set OUTREF=327,955,633,311,100,0
set RETREF=56000
call :TEST OUT L 1111111
endlocal

setlocal
set L=5,400,300,200,100
set OUTREF=332,955,633,311,100,0
set RETREF=6000
call :TEST OUT L 1111111
endlocal

setlocal
set L=400,300,200,100
set OUTREF=955,633,311,100,0,0
set RETREF=444777
call :TEST OUT L 1111111
endlocal

setlocal
set L=40,300,200,100
set OUTREF=995,633,311,100,0,0
set RETREF=44777
call :TEST OUT L 1111111
endlocal

setlocal
set L=4,300,200,100
set OUTREF=999,633,311,100,0,0
set RETREF=4777
call :TEST OUT L 1111111
endlocal

setlocal
set L=300,200,100
set OUTREF=633,311,100,0,0,0
set RETREF=333555
call :TEST OUT L 1111111
endlocal

setlocal
set L=30,200,100
set OUTREF=663,311,100,0,0,0
set RETREF=33555
call :TEST OUT L 1111111
endlocal

setlocal
set L=3,200,100
set OUTREF=666,311,100,0,0,0
set RETREF=3555
call :TEST OUT L 1111111
endlocal

setlocal
set L=200,100
set OUTREF=311,100,0,0,0,0
set RETREF=222333
call :TEST OUT L 1111111
endlocal

setlocal
set L=20,100
set OUTREF=331,100,0,0,0,0
set RETREF=22333
call :TEST OUT L 1111111
endlocal

setlocal
set L=2,100
set OUTREF=333,100,0,0,0,0
set RETREF=2333
call :TEST OUT L 1111111
endlocal

rem NOTE: near the overflow
setlocal
set L=1234
set OUTREF=974,0,0,0,0,0
set RETREF=1371110
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234
set OUTREF=84,974,0,0,0,0
set RETREF=1372482
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234
set OUTREF=456,84,974,0,0,0
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234
set OUTREF=457,456,84,974,0,0
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234
set OUTREF=457,457,456,84,974,0
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234
set OUTREF=457,457,457,456,84,974
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1234
set OUTREF=457,457,457,457,456,84
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1234,1234
set OUTREF=457,457,457,457,457,456
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

setlocal
set L=1234,1234,1234,1234,1234,1234,1234,1234,1234
set OUTREF=457,457,457,457,457,457
set RETREF=1372483
call :TEST OUT L 1111111
endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
