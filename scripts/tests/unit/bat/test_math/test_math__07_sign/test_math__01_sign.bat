@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "RETREF="


setlocal
set RETREF=0
call :TEST
endlocal

for %%a in ("" + -) do (
  setlocal
  set RETREF=0
  call :TEST "%%~a"
  endlocal
)

for %%a in (0 +0 -0 00 +00 -00 "0,0" "+0,0" "-0,0" 00000000000000000000 +00000000000000000000 -00000000000000000000) do (
  setlocal
  set RETREF=0
  call :TEST "%%~a"
  endlocal
)

for %%a in (1 +1 01 +01 10 +10 "1,1" "+1,1" 12345678901234567890 +12345678901234567890) do (
  setlocal
  set RETREF=1
  call :TEST "%%~a"
  endlocal
)

for %%a in (-1 -01 -10 "-1,1" -12345678901234567890) do (
  setlocal
  set RETREF=-1
  call :TEST "%%~a"
  endlocal
)

echo;

:EXIT
rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
set "L_=%~1"

call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" L_
exit /b
