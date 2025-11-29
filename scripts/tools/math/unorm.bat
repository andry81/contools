@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;'" %%i in ("!%~2!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" ^
  & ( if defined F call "%%~0" F F || set /A "L6+=!ERRORLEVEL!" ) & ^
set /A "L5+=L6 / 1000" & set /A "L6%%=1000" & set /A "L4+=L5 / 1000" & set /A "L5%%=1000" & set /A "L3+=L4 / 1000" & set /A "L4%%=1000" & ^
set /A "L2+=L3 / 1000" & set /A "L3%%=1000" & set /A "L1+=L2 / 1000" & set /A "L2%%=1000" & set /A "R=L1 / 1000" & set /A "L1%%=1000" ^
  & ( if defined F set "F=,!F!" ) & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!L1!,!L2!,!L3!,!L4!,!L5!,!L6!!F!") do endlocal & set "%~1=%%b" & exit /b %%a
endlocal & set "%~1=0,0,0,0,0,0" & exit /b 0

rem USAGE:
rem   unorm.bat <out-var> <var>

rem Description:
rem   An unsigned integer number normalization script to normalize a folded
rem   integer number representation.
rem
rem   Exit code indicates an overflow.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as a normalization result of <var>.
rem
rem   Format:
rem     NNN,NNN,NNN,NNN,NNN,NNN[,NNN,NNN,NNN,NNN,NNN,NNN[,...]]
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N[,N,N,N,N,N,N[,...]]` formatted if
rem   a variable name is not empty.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer
rem     etc

rem <var>:
rem   A variable name for a string value of a partially folded integer number.
rem
rem   Format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN[,...]]]]]]
rem     , where NNN must not begin by 0 except 0 or except sequence of zeroes.
rem
rem   Evaluates the sequence from the left to the right.
rem
rem   Can contain additional inner sequence(s) to the right of the outer
rem   sequence:
rem
rem     A1[,A2[,A3[,A4[,A5[,A6[,B1[,B2[,B3[,B4[,B5[,B6[,...]]]]]]]]]]]]
rem
rem   In that case the right sequence `Bn` does evaluate the same way as the
rem   left sequence `An`, and the overflow result of the `Bn` does add up to
rem   the `An` after the normalization of the `Bn`.
rem
rem   Then the `An` normalizes to return the self overflow out to the exit
rem   code.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem NOTE:
rem   These operations are equivalent, but the normalization script is faster:
rem
rem   >
rem   set a=0,0,0,0,0,2147483647
rem   uadd.bat x a 0
rem   >
rem   unorm.bat x a

rem Examples:
rem
rem   1. >
rem      rem   1,1002,1003,000,000,000
rem      set a=1,1002,1004
rem      unorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=2,3,4,0,0,0
rem
rem   2. >
rem      set a=0,0,0,1,2,3,1005
rem      unorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,1,2,4,5,0,0,0,0,0
rem
rem   3. >
rem      unorm.bat b
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
