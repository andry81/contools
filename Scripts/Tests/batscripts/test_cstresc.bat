@echo off

rem Drop last error level
cd .

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

set __STRING__=a\b\.c
set __CHARS__=\.
set "STRING_REFERENCE=a\\b\\\.c"
call :TEST 6

set __STRING__=a\b\.c
set __CHARS__=.
set "STRING_REFERENCE=a\b\\.c
call :TEST 6

set __STRING__=a\b\.c
set "__CHARS__="
set "STRING_REFERENCE=a\\b\\.c"
call :TEST 6

set __STRING__= ^	-'`^?^*^&^|^<^>^(^)
set __CHARS__= '^?
set "STRING_REFERENCE=\ 	-\'`\?*&|<>()"
call :TEST 13

set __STRING__= ^	-'`^?^*
set __CHARS__=	^*
set "STRING_REFERENCE= \	-'`?\*"
call :TEST 7

set __STRING__='`^?^*^&^|^<^>^(^)
set __CHARS__=^|^?
set "STRING_REFERENCE='`\?*&\|<>()"
call :TEST 10

set __STRING__= ^	-'`^?^*^&^|^<^>^(^)'`%%
set __CHARS__=%% 
set "STRING_REFERENCE=\ 	-'`?*&|<>()'`\%%"
call :TEST 16

set __STRING__=	
set __CHARS__= 
set "STRING_REFERENCE=	"
call :TEST 1

set __STRING__= ^	
set __CHARS__= 
set "STRING_REFERENCE=\ 	"
call :TEST 2

set __STRING__=^^
set __CHARS__=^^
set "STRING_REFERENCE=\^"
call :TEST 1

set "__STRING__="
set __CHARS__=\
set "STRING_REFERENCE="
call :TEST 0

echo.

goto EXIT

:TEST
set STRING_LEN=%~1

call :CMD "%%CONTOOLS_ROOT%%/cstresc.bat" "%%__STRING__%%" STRING_ESCAPED "%%__CHARS__%%"
set LASTERRORLEVEL=%ERRORLEVEL%
goto CMD_END

:CMD
echo.^>%~nx1 %2 %3 %4
(%*)
exit /b
:CMD_END

"%CONTOOLS_ROOT%/envvarcmp.exe" STRING_ESCAPED STRING_REFERENCE "" ^
  "PASSED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}`" ^
  "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"
if %ERRORLEVEL% NEQ 0 goto TEST_END

rem additional test on string length equalness
if %LASTERRORLEVEL% NEQ %STRING_LEN% (
  "%CONTOOLS_ROOT%/envvarcmp.exe" STRING_ESCAPED STRING_REFERENCE "" ^
    "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}`" ^
    "FAILED: %__COUNTER1%: (%LASTERRORLEVEL% == %STRING_LEN%) RESULT=`{0}` STRING=`${__STRING__}` REFERENCE=`{1}` CHARS=`${__CHARS__}` (`{0hs}` != `{1hs}`)"
  goto TEST_END
)

set /A __PASSED_TESTS+=1

:TEST_END
set /A __OVERALL_TESTS+=1
set /A __COUNTER1+=1

goto :EOF

:EXIT
rem Drop internal variables but use some changed value(s) for the return
(
  endlocal
  set __PASSED_TESTS=%__PASSED_TESTS%
  set __OVERALL_TESTS=%__OVERALL_TESTS%
  set __NEST_LVL=%__NEST_LVL%
)

set /A __NEST_LVL-=1

if %__NEST_LVL%0 EQU 0 (
  echo    %__PASSED_TESTS% of %__OVERALL_TESTS% tests is passed.
  pause
)
