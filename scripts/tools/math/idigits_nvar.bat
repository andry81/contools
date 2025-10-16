@echo off & ( if "%~1" == "" exit /b 1 ) & setlocal ENABLEDELAYEDEXPANSION & set "R=!%~1!" & ( if not defined R exit /b 1 ) ^
  & ( if "!R:~0,1!" == "+" set "R=!R:~1!" ) & ( if defined R if "!R:~0,1!" == "-" set "R=!R:~1!" ) & ( if not defined R exit /b 1 ) & ^
for /F "tokens=* delims=0"eol^= %%i in ("!R!") do set "L=1" & set "R=%%i" & set /A "F=!R:~0,9!" & ^
if !F! NEQ 0 ( for %%i in (65536 32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!R:~%%i,1!" == "" set /A "L+=%%i" & set "R=!R:~%%i!" ) & exit /b !L!
exit /b 1

rem USAGE:
rem   idigits_nvar.bat <var>

rem Description:
rem   A signed integer number digits counter script to count digits in an
rem   unfolded integer number.
rem
rem   Exit code returns number of digits excluding leading zeros if a number is
rem   not zero. Returns `1` if a number consists only of zeros.
rem
rem   NOTE:
rem     Empty or not a number value treated as `0`.
rem
rem   CAUTION:
rem     Supports numbers not longer than 65536 characters.

rem <var>:
rem   A variable name for a string value of an unfolded integer number.
rem
rem   Format:
rem     [+|-]N[N[...]]
rem     , where a sequence can begin by 0 but does not treated as an octal
rem       number.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string input.
rem
rem     999999999999999999 is equivalent to 60-bit integer
rem     2147483647999999999999999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. >
rem      set a=-000123000
rem      idigits_nvar.bat a
rem      rem ERRORLEVEL=6
rem
rem   2. >
rem      set a=+000000000
rem      idigits_nvar.bat a
rem      rem ERRORLEVEL=1
rem
rem   3. >
rem      set a=-xxx
rem      idigits_nvar.bat a
rem      rem ERRORLEVEL=1
rem      rem a=-xxx
