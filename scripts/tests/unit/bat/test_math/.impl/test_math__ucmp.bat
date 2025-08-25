@echo off

rem common implementation for `ucmp.bat` and `ucmp_nvar.bat`

setlocal DISABLEDELAYEDEXPANSION

if not defined TEST_IMPL_SCRIPT_NAME goto EXIT

rem reset all test variables at first
set "L="
set "OP="
set "R="
set "RETREF="

setlocal
set RETREF=-1
call :TEST
endlocal

if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp_nvar.bat" (
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
)

if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp.bat" (
  setlocal
  set RETREF=-1
  call :TEST 0
  endlocal

  setlocal
  set RETREF=-1
  call :TEST "" "" 0
  endlocal
) else (
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
)

if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp.bat" (
  setlocal
  set RETREF=-1
  call :TEST 0 "" 0
  endlocal
) else (
  setlocal
  set RETREF=-1
  set L=0
  set R=0
  call :TEST L "" R
  endlocal
)

if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp.bat" (
  for %%i in (EQU NEQ GTR GEQ LSS LEQ "==") do (
    setlocal
    set RETREF=-1
    call :TEST 0 %%i
    endlocal

    setlocal
    set RETREF=-1
    call :TEST "" %%i 0
    endlocal
  )
) else (
  for %%i in (EQU NEQ GTR GEQ LSS LEQ "==") do (
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

  for %%i in (EQU GEQ LEQ "==") do (
    setlocal
    set RETREF=0
    set L=0
    set "R="
    call :TEST L %%i R
    endlocal

    setlocal
    set RETREF=0
    set "L="
    set R=0
    call :TEST L %%i R
    endlocal
  )

  for %%i in (NEQ GTR LSS) do (
    setlocal
    set RETREF=1
    set L=0
    set "R="
    call :TEST L %%i R
    endlocal

    setlocal
    set RETREF=1
    set "L="
    set R=0
    call :TEST L %%i R
    endlocal
  )
)

rem NOTE: tests from the script documentation in the description

rem Examples:
rem
rem   1. >
rem      rem number comparison
rem      call ucmp.bat 10 GTR 9 && echo TRUE || echo FALSE
rem      rem TRUE
setlocal
set RETREF=0
call :TEST_SELECT 10 GTR 9
endlocal

rem   2. >
rem      rem still number comparison
rem      call ucmp.bat "10" GTR "9" && echo TRUE || echo FALSE
rem      rem TRUE
if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp.bat" (
  setlocal
  set RETREF=0
  call :TEST "10" GTR "9"
  endlocal
)


set ZEROS=00000000000000000000
set ONES=11111111111111111111
set ONE_ZEROS=10000000000000000000
set TEN_ZEROS=100000000000000000000-
set NINE_ZEROS=90000000000000000000-
set DIGITS_F21=123456789123456789123-
set DIGITS_F20=12345678912345678912-
set DIGITS_B20_1=21987654321987654320
set DIGITS_B20_2=21987654321987654321


for /L %%i in (1,1,20) do (
  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% EQU %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% NEQ %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% GTR %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% GEQ %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% LSS %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% LEQ %%ZEROS:~0,%%i%%
  endlocal
)

for /L %%i in (1,1,20) do (
  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONES:~0,%%i%% EQU %%ONES:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONES:~0,%%i%% NEQ %%ONES:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONES:~0,%%i%% GTR %%ONES:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONES:~0,%%i%% GEQ %%ONES:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONES:~0,%%i%% LSS %%ONES:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONES:~0,%%i%% LEQ %%ONES:~0,%%i%%
  endlocal
)

for /L %%i in (1,1,20) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% EQU %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% NEQ %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% GTR %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% GEQ %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% LSS %%ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ONE_ZEROS:~0,%%i%% LEQ %%ZEROS:~0,%%i%%
  endlocal
)

for /L %%i in (1,1,20) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% EQU %%ONE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% NEQ %%ONE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% GTR %%ONE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%ZEROS:~0,%%i%% GEQ %%ONE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% LSS %%ONE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%ZEROS:~0,%%i%% LEQ %%ONE_ZEROS:~0,%%i%%
  endlocal
)

for /L %%i in (-20,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% EQU %%NINE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% NEQ %%NINE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% GTR %%NINE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% GEQ %%NINE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% LSS %%NINE_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%TEN_ZEROS:~0,%%i%% LEQ %%NINE_ZEROS:~0,%%i%%
  endlocal
)

for /L %%i in (-20,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% EQU %%TEN_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% NEQ %%TEN_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% GTR %%TEN_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% GEQ %%TEN_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% LSS %%TEN_ZEROS:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%NINE_ZEROS:~0,%%i%% LEQ %%TEN_ZEROS:~0,%%i%%
  endlocal
)

for /L %%i in (-20,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% EQU %%DIGITS_F20:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% NEQ %%DIGITS_F20:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% GTR %%DIGITS_F20:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% GEQ %%DIGITS_F20:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% LSS %%DIGITS_F20:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F21:~0,%%i%% LEQ %%DIGITS_F20:~0,%%i%%
  endlocal
)

for /L %%i in (-20,1,-1) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% EQU %%DIGITS_F21:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% NEQ %%DIGITS_F21:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% GTR %%DIGITS_F21:~0,%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% GEQ %%DIGITS_F21:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% LSS %%DIGITS_F21:~0,%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_F20:~0,%%i%% LEQ %%DIGITS_F21:~0,%%i%%
  endlocal
)

for /L %%i in (-20,1,-2) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% EQU %%DIGITS_B20_1:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% NEQ %%DIGITS_B20_1:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% GTR %%DIGITS_B20_1:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% GEQ %%DIGITS_B20_1:~%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% LSS %%DIGITS_B20_1:~%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_2:~%%i%% LEQ %%DIGITS_B20_1:~%%i%%
  endlocal
)

for /L %%i in (-20,1,-2) do (
  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% EQU %%DIGITS_B20_2:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% NEQ %%DIGITS_B20_2:~%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% GTR %%DIGITS_B20_2:~%%i%%
  endlocal

  setlocal
  set RETREF=1
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% GEQ %%DIGITS_B20_2:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% LSS %%DIGITS_B20_2:~%%i%%
  endlocal

  setlocal
  set RETREF=0
  call :TEST_SELECT %%DIGITS_B20_1:~%%i%% LEQ %%DIGITS_B20_2:~%%i%%
  endlocal
)

echo;

:EXIT
rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST_SELECT
if "%TEST_IMPL_SCRIPT_NAME%" == "ucmp.bat" goto TEST

set "L_=%~1"
set "R_=%~3"

call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" L_ %%2 R_
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
