@echo off

rem Drop last error level
type nul>nul

rem Create local variable's stack
setlocal

if 0%__CTRL_SETLOCAL% EQU 1 (
  echo.%~nx0: error: cmd.exe is broken, please restart it!>&2
  exit /b 65535
)
set __CTRL_SETLOCAL=1

call "%%~dp0__init__.bat"

echo Running %~nx0...
title %~nx0 %*

set /A __NEST_LVL+=1

set __COUNTER1=1

set TEST_NUM_VARS=2
set TEST_1_VALUE_1=0
set TEST_1_VALUE_2=0
set "TEST_VALUE_1="
set "TEST_VALUE_2="
call :TEST "" test_1_empty.vars

set TEST_NUM_VARS=9
set TEST_VALUE_1=1
set TEST_VALUE_2=2
set TEST_VALUE_3=2
set "TEST_VALUE_4=1&2"
set "TEST_VALUE_5=1&2"
set TEST_VALUE_6=1^&2
set TEST_VALUE_7=1^&2
set TEST_VALUE_8=1 2 3
set TEST_VALUE_9="1 2" 3 "4 5"
call :TEST "" test_2_simple_set.vars

set TEST_NUM_VARS=5
set TEST_VALUE_1=3
set TEST_VALUE_2=5
set TEST_VALUE_3=7
set TEST_VALUE_4=16
set TEST_VALUE_5=16
call :TEST "" test_3_math.vars

set TEST_NUM_VARS=4
set TEST_VALUE_1=123456
set TEST_VALUE_2=654321
set TEST_VALUE_3=123456
set TEST_VALUE_4=123456
call :TEST "" test_4_from_file.vars

set TEST_NUM_VARS=4
set TEST_VALUE_1=1
set TEST_VALUE_2=1
set TEST_VALUE_3=1
set "TEST_VALUE_4=1&2"
call :TEST "" test_5_dbl_eval.vars

goto EXIT

:TEST
setlocal

set __COUNTER2=1

pushd "%TEST_DATA_BASE_DIR%/test_setvarsfromfile" && (
  call "%%CONTOOLS_ROOT%%/setvarsfromfile.bat" %%~1 "%%~2"
)
popd

set __LOCAL_PASSED_TESTS=0
set __LOCAL_OVERALL_TESTS=0

set VARINDEX=1

:VARSLOOP
if %VARINDEX% GTR %TEST_NUM_VARS% goto VARSLOOP_END

call set "VARVALUE_REFERENCE=%%TEST_VALUE_%VARINDEX%%%"

set /A VARINDEX+=1

set VARNAME=TEST_%__COUNTER1%_VALUE_%__COUNTER2%
call set "VARVALUE_ACTUAL=%%%VARNAME%%%"

"%CONTOOLS_ROOT%/printf.exe" "=${VARVALUE_ACTUAL}=${VARVALUE_REFERENCE}="

"%CONTOOLS_ROOT%/envvarcmp.exe" VARVALUE_ACTUAL VARVALUE_REFERENCE "" ^
  "PASSED: %__COUNTER1%.%__COUNTER2%: %VARNAME%=`{0}`" ^
  "FAILED: %__COUNTER1%.%__COUNTER2%: %VARNAME%=`{0}` REFERENCE=`{1}` (`{0hs}` != `{1hs}`)"

if %ERRORLEVEL% NEQ 0 goto TEST_END

set /A __LOCAL_PASSED_TESTS+=1

:TEST_END
set /A __LOCAL_OVERALL_TESTS+=1
set /A __COUNTER2+=1

goto VARSLOOP

:VARSLOOP_END

set TEST_NUM_VARS=0

rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set __LOCAL_PASSED_TESTS=%__LOCAL_PASSED_TESTS%
  set __LOCAL_OVERALL_TESTS=%__LOCAL_OVERALL_TESTS%
  set /A __PASSED_TESTS=%__PASSED_TESTS%+%__LOCAL_PASSED_TESTS%
  set /A __OVERALL_TESTS=%__OVERALL_TESTS%+%__LOCAL_OVERALL_TESTS%
  set __COUNTER2=%__COUNTER2%
)

set /A __COUNTER1+=1

if %__LOCAL_PASSED_TESTS% EQU %__LOCAL_OVERALL_TESTS% exit /b 0

exit /b 1

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set __NEST_LVL=%__NEST_LVL%

  if %__LOCAL_PASSED_TESTS% EQU %__LOCAL_OVERALL_TESTS% ( call :EXIT_IMPL & exit /b 0 )
)

call :EXIT_IMPL

exit /b 1

:EXIT_IMPL
set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
