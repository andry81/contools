@echo off

rem Create local variable's stack
setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

set "TEST_FLAGS="

rem to test the negative variant
set "IFN_COUNT_SHIFT=0"
set "RETURN_REFERENCE_XOR=0

for /L %%i in (1,1,2) do (
  if %%i EQU 2 call set "TEST_FLAGS=not" & set "IFN_COUNT_SHIFT=1" & set "RETURN_REFERENCE_XOR=1"

  set "CMDLINE=1 EQU 0"
  set /A "IFN_COUNT=3+IFN_COUNT_SHIFT"
  set "RETURN_REFERENCE=0"
  call :TEST %%IFN_COUNT%% %%TEST_FLAGS%%

  set "CMDLINE=1 EQU 1"
  set /A "IFN_COUNT=3+IFN_COUNT_SHIFT"
  set "RETURN_REFERENCE=1"
  call :TEST %%IFN_COUNT%% %%TEST_FLAGS%%

  set CMDLINE=a "==" A
  set /A "IFN_COUNT=3+IFN_COUNT_SHIFT"
  set "RETURN_REFERENCE=0"
  call :TEST %%IFN_COUNT%% %%TEST_FLAGS%%
  set /A "IFN_COUNT+=1"
  set "RETURN_REFERENCE=1"
  call :TEST %%IFN_COUNT%% /i %%TEST_FLAGS%%

  set CMDLINE=a "==" a
  set /A "IFN_COUNT=3+IFN_COUNT_SHIFT"
  set "RETURN_REFERENCE=1"
  call :TEST %%IFN_COUNT%% %%TEST_FLAGS%%
  set /A "IFN_COUNT+=1"
  set "RETURN_REFERENCE=1"
  call :TEST %%IFN_COUNT%% /i %%TEST_FLAGS%%
)

set "TEST_FLAGS="

rem not inversed
set "RETURN_REFERENCE_XOR=0"

set CMDLINE=3 1 EQU 0 3 1 EQU 0
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=3 1 EQU 1 3 1 EQU 0
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=3 1 EQU 1 3 1 EQU 1
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=3 1 EQU 0 3 1 EQU 1
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=3 a "==" A 3 A "==" a
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=4 /i a "==" A 4 /i A "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=3 a "==" a 3 a "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=4 /i a "==" a 4 /i a "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=3 a "==" a 3 A "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=4 /i a "==" a 4 /i A "==" a
set "RETURN_REFERENCE=1"
call :TEST

rem inversed
set "RETURN_REFERENCE_XOR=0"

set CMDLINE=4 not 1 EQU 0 4 not 1 EQU 0
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=4 not 1 EQU 1 4 not 1 EQU 0
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=4 not 1 EQU 1 4 not 1 EQU 1
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=4 not 1 EQU 0 4 not 1 EQU 1
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=4 not a "==" A 4 not A "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=5 /i not a "==" A 5 /i not A "==" a
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=4 not a "==" a 4 not a "==" a
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=5 /i not a "==" a 5 /i not a "==" a
set "RETURN_REFERENCE=0"
call :TEST

set CMDLINE=4 not a "==" a 4 not A "==" a
set "RETURN_REFERENCE=1"
call :TEST

set CMDLINE=5 /i not a "==" a 5 /i not A "==" a
set "RETURN_REFERENCE=0"
call :TEST

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
