@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "L="
set "OP="
set "R="
set "RETREF="


setlocal
set RETREF=-1
call :TEST
endlocal

setlocal
set RETREF=-1
set "L="
call :TEST L
endlocal

setlocal
set RETREF=-1
set "L="
set "R="
call :TEST L "" R
endlocal

setlocal
set RETREF=-1
set "R="
call :TEST "" "" R
endlocal

setlocal
set RETREF=-1
set L=0
call :TEST L
endlocal

setlocal
set RETREF=-1
set L=0
set "R="
call :TEST L "" R
endlocal

setlocal
set RETREF=-1
set "L="
set R=0
call :TEST L "" R
endlocal

setlocal
set RETREF=-1
set R=0
call :TEST "" "" R
endlocal

setlocal
set RETREF=-1
set L=0
set R=0
call :TEST L "" R
endlocal

for %%i in (EQU NEQ GTR GEQ LSS LEQ) do (
  setlocal
  set RETREF=-1
  set L=0
  call :TEST L %%i
  endlocal

  setlocal
  set RETREF=-1
  set R=0
  call :TEST "" %%i R
  endlocal
)

for %%i in (EQU GEQ LEQ) do (
  setlocal
  set RETREF=-1
  set L=0
  set "R="
  call :TEST L %%i R
  endlocal

  setlocal
  set RETREF=-1
  set "L="
  set R=0
  call :TEST L %%i R
  endlocal
)

for %%i in (NEQ GTR LSS) do (
  setlocal
  set RETREF=-1
  set L=0
  set "R="
  call :TEST L %%i R
  endlocal

  setlocal
  set RETREF=-1
  set "L="
  set R=0
  call :TEST L %%i R
  endlocal
)


rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. Folded number comparison
rem      >
rem      set a=-10,0
rem      set b=-9,0
rem      call icmp_fnvar.bat a LSS b && echo TRUE || echo FALSE
rem      rem TRUE
setlocal
set RETREF=0
call :TEST_SELECT "-10,0" LSS "-9,0"
endlocal

rem   2. Number comparison
rem      >
rem      set a=-0,0,0,0,0,0,0
rem      set b=+0,0,0,0,0,0,0
rem      call icmp_fnvar.bat a EQU b && echo TRUE || echo FALSE
rem      rem TRUE
setlocal
set RETREF=0
call :TEST_SELECT "-0,0,0,0,0,0,0" EQU "+0,0,0,0,0,0,0"
endlocal

rem   3. Folded number comparison
rem      >
rem      set a=-0,0,0,0,0,0,0,10,0
rem      set b=-0,0,0,0,0,0,0,9,0
rem      call icmp_fnvar.bat a LSS b && echo TRUE || echo FALSE
rem      rem TRUE
setlocal
set RETREF=0
call :TEST_SELECT "-0,0,0,0,0,0,0,10,0" LSS "-0,0,0,0,0,0,0,9,0"
endlocal

rem   4. Folded number comparison
rem      >
rem      set a=-0,0,0,0,0,0,0,1,0
rem      set b=-0,0,0,0,0,0,0,01,0
rem      call icmp_fnvar.bat a EQU b && echo TRUE || echo FALSE
rem      rem TRUE
setlocal
set RETREF=0
call :TEST_SELECT "0,0,0,0,0,0,0,1,0" EQU "0,0,0,0,0,0,0,01,0"
endlocal


set ZEROSx1=0,0,0,0,0,0,0
set ZEROSx3=000,000,000,000,000,000,000
set ONES=111,111,111,111,111,111,111
set ONE_ZEROS=1,0,0,0,0,0,0,0
set TEN_ZEROS=10,0,0,0,0,0,0,0-
set NINE_ZEROS=9,0,0,0,0,0,0,0-
set DIGITS_F21=123,456,789,123,456,789,123-
set DIGITS_F20=12,345,678,912,345,678,912-
set DIGITS_B20_1=21,987,654,321,987,654,320
set DIGITS_B20_2=21,987,654,321,987,654,321


for %%a in ("" "+" "-") do ^
for /L %%i in (1,1,27) do (
  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" EQU "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" NEQ "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" GTR "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" GEQ "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" LSS "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ZEROSx3:~0,%%i%%" LEQ "%%~a%%ZEROSx3:~0,%%i%%"
  endlocal
)

for %%a in ("" "+" "-") do ^
for /L %%i in (1,1,27) do (
  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" EQU "%%~a%%ONES:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" NEQ "%%~a%%ONES:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" GTR "%%~a%%ONES:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" GEQ "%%~a%%ONES:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" LSS "%%~a%%ONES:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%~a%%ONES:~0,%%i%%" LEQ "%%~a%%ONES:~0,%%i%%"
  endlocal
)

for /L %%i in (1,1,15) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" EQU "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" NEQ "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" GTR "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" GEQ "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" LSS "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ONE_ZEROS:~0,%%i%%" LEQ "%%ZEROSx1:~0,%%i%%"
  endlocal
)

for /L %%i in (1,1,15) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" EQU "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" NEQ "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" GTR "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" GEQ "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" LSS "%%ZEROSx1:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%ONE_ZEROS:~0,%%i%%" LEQ "%%ZEROSx1:~0,%%i%%"
  endlocal
)

for /L %%i in (1,1,15) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" EQU "%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" NEQ "%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" GTR "%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" GEQ "%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" LSS "%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" LEQ "%%ONE_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (1,1,15) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" EQU "-%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" NEQ "-%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" GTR "-%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" GEQ "-%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" LSS "-%%ONE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%ZEROSx1:~0,%%i%%" LEQ "-%%ONE_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (-15,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" EQU "%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" NEQ "%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" GTR "%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" GEQ "%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" LSS "%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%TEN_ZEROS:~0,%%i%%" LEQ "%%NINE_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (-15,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" EQU "-%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" NEQ "-%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" GTR "-%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" GEQ "-%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" LSS "-%%NINE_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%TEN_ZEROS:~0,%%i%%" LEQ "-%%NINE_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (-15,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" EQU "%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" NEQ "%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" GTR "%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" GEQ "%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" LSS "%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%NINE_ZEROS:~0,%%i%%" LEQ "%%TEN_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (-15,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" EQU "-%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" NEQ "-%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" GTR "-%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" GEQ "-%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" LSS "-%%TEN_ZEROS:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%NINE_ZEROS:~0,%%i%%" LEQ "-%%TEN_ZEROS:~0,%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" EQU "%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" NEQ "%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" GTR "%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" GEQ "%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" LSS "%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F21:~0,%%i%%" LEQ "%%DIGITS_F20:~0,%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" EQU "-%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" NEQ "-%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" GTR "-%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" GEQ "-%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" LSS "-%%DIGITS_F20:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F21:~0,%%i%%" LEQ "-%%DIGITS_F20:~0,%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" EQU "%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" NEQ "%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" GTR "%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" GEQ "%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" LSS "%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_F20:~0,%%i%%" LEQ "%%DIGITS_F21:~0,%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" EQU "-%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" NEQ "-%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" GTR "-%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" GEQ "-%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" LSS "-%%DIGITS_F21:~0,%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_F20:~0,%%i%%" LEQ "-%%DIGITS_F21:~0,%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" EQU "%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" NEQ "%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" GTR "%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" GEQ "%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" LSS "%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_2:~%%i%%" LEQ "%%DIGITS_B20_1:~%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" EQU "-%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" NEQ "-%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" GTR "-%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" GEQ "-%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" LSS "-%%DIGITS_B20_1:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_2:~%%i%%" LEQ "-%%DIGITS_B20_1:~%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" EQU "%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" NEQ "%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" GTR "%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" GEQ "%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" LSS "%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "%%DIGITS_B20_1:~%%i%%" LEQ "%%DIGITS_B20_2:~%%i%%"
  endlocal
)

for /L %%i in (-26,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" EQU "-%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" NEQ "-%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" GTR "-%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" GEQ "-%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" LSS "-%%DIGITS_B20_2:~%%i%%"
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT "-%%DIGITS_B20_1:~%%i%%" LEQ "-%%DIGITS_B20_2:~%%i%%"
  endlocal
)

echo;

:EXIT
rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST_SELECT
set "L_=%~1"
set "R_=%~3"

if "%L_:~0,1%" == "," exit /b 0
if "%L_:~0,2%" == "+," exit /b 0
if "%L_:~0,2%" == "-," exit /b 0
if "%L_:~-1%" == "," exit /b 0
if "%R_:~0,1%" == "," exit /b 0
if "%R_:~0,2%" == "+," exit /b 0
if "%R_:~0,2%" == "-," exit /b 0
if "%R_:~-1%" == "," exit /b 0

call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" L_ %%2 R_
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
