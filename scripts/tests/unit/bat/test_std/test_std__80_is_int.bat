@echo off

setlocal DISABLEDELAYEDEXPANSION

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

rem reset all test variables at first
set "IN="
set "RETREF=255"


rem not integer characters

setlocal
call :TEST
endlocal

setlocal
call :TEST ""
endlocal

setlocal
set "RETREF=1"

for %%i in (: . - + /) do call :TEST %%~i

call :TEST *
call :TEST ?
call :TEST !
call :TEST !!

endlocal

setlocal
set "IN=^="
set RETREF=1
call :TEST
endlocal

setlocal
set "IN=="
set RETREF=255
call :TEST
endlocal

setlocal
set "IN=^&"
set RETREF=1
call :TEST
endlocal

setlocal
set "IN=&"
set RETREF=255
call :TEST
endlocal


rem valid integers

setlocal
set RETREF=0

rem zeros with sign
for %%i in ("" + -) do ^
for %%j in (0 00 0000 00000000 0000000000000000 00000000000000000000000000000000) do call :TEST %%~i%%j

rem 32-bit positive numbers
for %%i in ("" +) do for %%j in (01 1 2147483647 4294967295) do call :TEST %%~i%%j

rem 32-bit negative numbers
for %%i in (-01 -1 -2147483648 -4294967296) do call :TEST %%i

endlocal


rem double signed integers

setlocal
set RETREF=1

for %%i in (++ --) do (
  for %%j in (0 00 0000 00000000 0000000000000000 00000000000000000000000000000000) do call :TEST %%~i%%j

  for %%j in (01 09 1 2147483647 2147483648 4294967295 4294967296) do call :TEST %%~i%%j
)

endlocal


rem 32-bit overflow integers

setlocal
set RETREF=0

rem positive numbers
for %%i in ("" +) do for %%j in (2147483648 4294967296 999999999999) do call :TEST %%~i%%j

rem negative numbers
for %%i in (-2147483649 -4294967297 -999999999999) do call :TEST %%i

endlocal


rem invalid octal numbers

setlocal
set RETREF=1

for %%i in ("" + -) do for %%j in (08 09) do call :TEST %%~i%%j

endlocal


rem integer expressions

setlocal
set RETREF=1

call :TEST 0+0
call :TEST 0-0
call :TEST 0*0
call :TEST 0/1

call :TEST 0/0 & rem NOTE: division by zero, no error print

call :TEST 1+1
call :TEST 1-1
call :TEST 1*1
call :TEST 1/1

setlocal
set "IN=1^1"
call :TEST
endlocal

endlocal

rem not integer expression

setlocal
set RETREF=1

set A=1
set B=1

call :TEST A
call :TEST +A
call :TEST -A
call :TEST A+0
call :TEST 0+A
call :TEST A+B

endlocal

rem not integer numbers

setlocal
set RETREF=1

call :TEST 0.
call :TEST 0.0
call :TEST 1.
call :TEST 1.0

setlocal
set "IN=1^,1"
call :TEST
endlocal

setlocal
set "IN=1^;1"
call :TEST
endlocal

endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
