@echo off

setlocal

set "FROM_LIST_FILE_HEX=%~1"
set "TO_LIST_FILE_HEX_UCP=%~2"
set "TO_LIST_FILE_DIR_HEX_UCP=%~dp2"

if not exist "%FROM_LIST_FILE_HEX%" (
  echo.%~nx0: error: FROM_LIST_FILE_HEX file does not exist: "%FROM_LIST_FILE_HEX%".
  exit /b 1
) >&2

if not exist "%TO_LIST_FILE_DIR_HEX_UCP%" (
  echo.%~nx0: error: TO_LIST_FILE_DIR_HEX_UCP directory does not exist: "%TO_LIST_FILE_DIR_HEX_UCP%".
  exit /b 2
) >&2

type nul > "%TO_LIST_FILE_HEX_UCP%"

setlocal ENABLEDELAYEDEXPANSION

set LINE_RETURN=0
set HEX_LINE_INDEX=0
for /F "usebackq tokens=1,* delims=	" %%i in ("%FROM_LIST_FILE_HEX%") do (
  set "HEX_LINE=%%j"
  call :PROCESS_HEX_LINE
  set /A HEX_LINE_INDEX+=1
)

exit /b 0

:PROCESS_HEX_LINE
if not defined HEX_LINE exit /b 0

set "HEX_LINE=%HEX_LINE:~0,48%"
set "HEX_LINE=%HEX_LINE: =%"

set HEX_LINE_OFFSET_1=2
set HEX_LINE_OFFSET_2=0

if %HEX_LINE_INDEX% NEQ 0 goto HEX_LINE_LOOP

rem exclude BOM characters
set /A HEX_LINE_OFFSET_1+=4
set /A HEX_LINE_OFFSET_2+=4

:HEX_LINE_LOOP
set "UTF_16_CHAR=!HEX_LINE:~%HEX_LINE_OFFSET_1%,2!!HEX_LINE:~%HEX_LINE_OFFSET_2%,2!"

if not defined UTF_16_CHAR exit /b 0

if not "%UTF_16_CHAR%" == "000d" if not "%UTF_16_CHAR%" == "000a" goto NOT_LINE_RETURN_CHAR
set LINE_RETURN=1
goto HEX_LINE_LOOP_NEXT

:NOT_LINE_RETURN_CHAR

if %LINE_RETURN% NEQ 0 (
  set LINE_RETURN=0
  echo.>> "%TO_LIST_FILE_HEX_UCP%"
)

rem echo w/o line return
set /P =^&#x%UTF_16_CHAR%;<nul >> "%TO_LIST_FILE_HEX_UCP%"

:HEX_LINE_LOOP_NEXT
set /A HEX_LINE_OFFSET_1+=4
set /A HEX_LINE_OFFSET_2+=4

if %HEX_LINE_OFFSET_1% GEQ 32 exit /b 0

goto HEX_LINE_LOOP
