@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to iterate predicates from 0 to SIZE.

rem Command arguments:
rem %1 - Size of iteration.
rem %2 - Iteration index variable name, begins from 0.
rem %3-%N - Predicates list format: <Pred1 Arg1> <Pred1 Arg2> ... <Pred1 ArgK1> [: <Pred2 Arg1> <Pred2 Arg2> ... <Pred2 ArgK2> [... : <PredN Arg1> <PredN Arg2> ... <PredN ArgKN>]]
rem    , where: "${{" and "}}$" - special prefix and suffix for a variable expansion inside a predicate.

rem Examples:
rem 1. set BASE_PATH=C:\aaa\bbb
rem    set PATH_LIST[0]=111
rem    set PATH_LIST[1]=..\222
rem    set PATH_LIST[2]=..\..\333
rem    call iterate_index.bat 3 INDEX0 set "RETURN_VALUE=${{BASE_PATH}}$\${{PATH_LIST[${{INDEX0}}$]}}$" : set "_PATH_LIST_ABS[${{INDEX0}}$]=${{RETURN_VALUE:\=/}}$"
rem    rem PATH_LIST_ABS[0]=C:/aaa/bbb/111 PATH_LIST_ABS[1]=C:/aaa/bbb/../222 PATH_LIST_ABS[2]=C:/aaa/bbb/../../333

set "__SIZE=%~1"
set "__INDEX_VAR_NAME=%~2"

set "?~nx0=%~nx0"

if not defined __SIZE (
  echo.%?~nx0%: error: size is not set.
  exit /b 1
) >&2

if "%~3" == "" (
  echo.%?~nx0%: error: predicate is not set.
  exit /b 2
) >&2

rem read until empty
shift
shift

set __PRED_INDEX0=0
set __PRED_INDEX1=0

:PRED_LIST_LOOP
if %__PRED_INDEX1% GTR 0 call set __PRED_LIST[%%__PRED_INDEX0%%]=%%__PRED_LIST[%__PRED_INDEX0%]%% %%1
if %__PRED_INDEX1% LEQ 0 set __PRED_LIST[%__PRED_INDEX0%]=%1
shift

if "%~1" == ":" (
  shift
  set /A __PRED_INDEX0+=1
  set __PRED_INDEX1=0
) else (
  set /A __PRED_INDEX1+=1
)

if not "%~1" == "" goto PRED_LIST_LOOP

set /A __PRED_INDEX0+=1

:PRED_LIST_LOOP_END

if not defined __INDEX_VAR_NAME set __INDEX_VAR_NAME=INDEX0
set %__INDEX_VAR_NAME%=0
call set __INDEX0=%%%__INDEX_VAR_NAME%%%

:INDEX_LOOP
if %__INDEX0% GEQ %__SIZE% goto INDEX_LOOP_END

set __INDEX1=0

:EXEC_PRED_LIST_LOOP
if %__INDEX1% GEQ %__PRED_INDEX0% goto EXEC_PRED_LIST_LOOP_END

rem temporary enable delayed expansion to replace ${{ and }}$ by % character
setlocal EnableDelayedExpansion

set "__EXEC_CMD_LINE=!__PRED_LIST[%__INDEX1%]!"

rem preprocess command line
set __EXEC_CMD_LINE=!__EXEC_CMD_LINE:${{%__INDEX_VAR_NAME%}}$=%__INDEX0%!
set __EXEC_CMD_LINE=!__EXEC_CMD_LINE:${{=%%!
set __EXEC_CMD_LINE=!__EXEC_CMD_LINE:}}$=%%!

(
  endlocal
  set "__EXEC_CMD_LINE=%__EXEC_CMD_LINE%"
)

call set __EXEC_CMD_LINE=%__EXEC_CMD_LINE%

%__EXEC_CMD_LINE%

set /A __INDEX1+=1

goto EXEC_PRED_LIST_LOOP

:EXEC_PRED_LIST_LOOP_END

set /A %__INDEX_VAR_NAME%+=1
call set __INDEX0=%%%__INDEX_VAR_NAME%%%

goto INDEX_LOOP

:INDEX_LOOP_END

:EXIT
rem cleanup predicate list
for /F "usebackq eol= tokens=1,* delims==" %%i in (`set __PRED_LIST[ 2^>nul`) do set "%%i="

(
  set "?~nx0="
  if defined __INDEX_VAR_NAME set "%__INDEX_VAR_NAME%="
  set "__SIZE="
  set "__INDEX_VAR_NAME="
  set "__PRED_INDEX0="
  set "__PRED_INDEX1="
  set "__INDEX0="
  set "__INDEX1="
  set "__EXEC_CMD_LINE="
)

exit /b 0

