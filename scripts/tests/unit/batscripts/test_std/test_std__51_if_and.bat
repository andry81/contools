@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set "TEST_FLAGS="

rem to test the negative variant
set "RETURN_REFERENCE_XOR=0

for /L %%i in (1,1,2) do (
  if %%i EQU 2 call set "TEST_FLAGS=not" & set "RETURN_REFERENCE_XOR=1"

  set CMDLINE="1 EQU 0"
  set "RETURN_REFERENCE=0"
  call :TEST %%TEST_FLAGS%%

  set CMDLINE="1 EQU 1"
  set "RETURN_REFERENCE=1"
  call :TEST %%TEST_FLAGS%%

  set CMDLINE="a == A"
  set "RETURN_REFERENCE=0"
  call :TEST %%TEST_FLAGS%%
  set "RETURN_REFERENCE=1"
  call :TEST /i %%TEST_FLAGS%%

  set CMDLINE="a == a"
  set "RETURN_REFERENCE=1"
  call :TEST %%TEST_FLAGS%%
  set "RETURN_REFERENCE=1"
  call :TEST /i %%TEST_FLAGS%%
)

rem not inversed
set "TEST_FLAGS="
set "RETURN_REFERENCE_XOR=0"

set CMDLINE="1 EQU 0" "1 EQU 0"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 1" "1 EQU 0"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 1" "1 EQU 1"
set "RETURN_REFERENCE=1"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 0" "1 EQU 1"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="a == A" "A == a"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=1"
call :TEST /i %%TEST_FLAGS%%

set CMDLINE="a == a" "a == a"
set "RETURN_REFERENCE=1"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=1"
call :TEST /i %%TEST_FLAGS%%

set CMDLINE="a == a" "A == a"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=1"
call :TEST /i %%TEST_FLAGS%%

rem inversed
set "TEST_FLAGS=not"
set "RETURN_REFERENCE_XOR=0"

set CMDLINE="1 EQU 0" "1 EQU 0"
set "RETURN_REFERENCE=1"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 1" "1 EQU 0"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 1" "1 EQU 1"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="1 EQU 0" "1 EQU 1"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%

set CMDLINE="a == A" "A == a"
set "RETURN_REFERENCE=1"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=0"
call :TEST /i %%TEST_FLAGS%%

set CMDLINE="a == a" "a == a"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=0"
call :TEST /i %%TEST_FLAGS%%

set CMDLINE="a == a" "A == a"
set "RETURN_REFERENCE=0"
call :TEST %%TEST_FLAGS%%
set "RETURN_REFERENCE=0"
call :TEST /i %%TEST_FLAGS%%

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
setlocal
set /A "RETURN_REFERENCE^=RETURN_REFERENCE_XOR"
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
endlocal
set "RETURN_REFERENCE=-1"
exit /b
