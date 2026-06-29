@echo off

rem CAUTION:
rem   The expression ` "XXX=YYY"` (immediately after the `set`) in the
rem   `set "XXX=YYY"` must fit in the 8192 bytes buffer, otherwise the line
rem   string will be trimmed!
rem   To reduce the trim probability we have to reduce the length of variable
rem   names.

rem CAUTION:
rem   Assignment through the delayed expansion in case of a command line buffer
rem   overflow will drop a variable!

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem CAUTION:
rem   The `STR_`, `STRB` and `STRL` variable names must has the same lengths,
rem   otherwise the algorithm would fluctuate.

rem overflow tests
setlocal ENABLEDELAYEDEXPANSION

set "STRL=" & rem limit
set STR_LEN_LIMIT=0

:REPEAT_LOOP
set "STR_PREV="
set STR_PREV_LEN=0

set STR_NEXT=a
set STR_NEXT_LEN=1

rem CAUTION: `STRB` can be truncated here if `STR_`, `STRB` and `STRL` is not the same length variable names!
set "STRB=!STRL!"
set /A STR_BASE_LEN=STR_LEN_LIMIT

set "STR_=!STRB!!STR_NEXT!"
set /A STR_LEN=STR_BASE_LEN+STR_NEXT_LEN

set STR_BASE_LEN

for /L %%i in (1,1,16) do (
  call :STRLEN

  echo !ERRORLEVEL! NEQ !STR_LEN!
  if !ERRORLEVEL! NEQ !STR_LEN! (
    rem CAUTION: `STR_` can be truncated here if `STR_`, `STRB` and `STRL` is not the same length variable names!
    set "STR_=!STRL!"
    set /A STR_LEN=STR_LEN_LIMIT
    if !STR_PREV_LEN! EQU 0 goto END
    goto REPEAT_LOOP
  )

  rem CAUTION: `STRL` can be truncated here if `STR_`, `STRB` and `STRL` is not the same length variable names!
  set "STRL=!STR_!"
  set /A STR_LEN_LIMIT=STR_LEN

  set "STR_PREV=!STR_NEXT!"
  set "STR_NEXT=!STR_NEXT!!STR_NEXT!"

  set /A STR_PREV_LEN=STR_NEXT_LEN
  set /A STR_NEXT_LEN*=2

  rem CAUTION: `STR_` can be truncated here if `STR_`, `STRB` and `STRL` is not the same length variable names!
  set "STR_=!STRB!!STR_NEXT!"
  set /A STR_LEN=STR_BASE_LEN+STR_NEXT_LEN
)

:END

echo;---
echo;Expression format:      `set "XXXX=STRING"`
echo;A variable name length: 4
echo;STRING max length:      !STR_LEN_LIMIT!
echo;Overall length:         2+4+1+!STR_LEN_LIMIT!=8191

set /A LEN=2+4+1+STR_LEN_LIMIT

if !LEN! EQU 8191 (
  call "%%CONTOOLS_TESTLIB_ROOT%%/set_test_passed.bat"
) else call "%%CONTOOLS_TESTLIB_ROOT%%/set_test_failed.bat"

endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:STRLEN
call "%%CONTOOLS_ROOT%%/std/strlen.bat" /v STR_
exit /b
