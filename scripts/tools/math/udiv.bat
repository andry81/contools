@echo off & ( if "%~1" == "" exit /b -1 ) & set "D=%~3" & set /A "D=D/D - 1 + D" || exit /b -1 & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!%~2!") do ^
set /A "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" ^
  & ( if defined F call "%%~dp0uadd.bat" F F 0 || call set /A "L6+=%%ERRORLEVEL%%" ) & ^
set /A "L5+=L6 / 1000" & set /A "L6%%=1000" & set /A "L4+=L5 / 1000" & set /A "L5%%=1000" & set /A "L3+=L4 / 1000" & set /A "L4%%=1000" & ^
set /A "L2+=L3 / 1000" & set /A "L3%%=1000" & set /A "L1+=L2 / 1000" & set /A "L2%%=1000" & ^
set /A "R=L1 %% D" & set /A "L1/=D" ^
  & ( if !R! NEQ 0 ( ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & set "R=!R!!L2!" ) else set "R=!L2!" ) & ^
set /A "L2=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & set "R=!R!!L3!" ) else set "R=!L3!" ) & ^
set /A "L3=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & set "R=!R!!L4!" ) else set "R=!L4!" ) & ^
set /A "L4=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & set "R=!R!!L5!" ) else set "R=!L5!" ) & ^
set /A "L5=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & set "R=!R!!L6!" ) else set "R=!L6!" ) & ^
set /A "L6=R / D" & set /A "R%%=D" & ^
for /F "tokens=1,2,3,4,5,6,7 delims=," %%a in ("!L1!,!L2!,!L3!,!L4!,!L5!,!L6!,!R!") do endlocal & set "%~1=%%a,%%b,%%c,%%d,%%e,%%f" & exit /b %%g
endlocal & set "%~1=0,0,0,0,0,0" & if not "%~2" == "" if defined %~2 exit /b 0
exit /b -1

rem USAGE:
rem   udiv.bat <out-var> <var> <value>

rem Description:
rem   An unsigned division script to workaround the `set /A` command 32-bit
rem   range limitation.
rem
rem   Not negative exit code returns an unsigned remainder to a dividend.
rem   The exit code -1 indicates an invalid or incomplete input.
rem
rem   NOTE:
rem     Both <out-var> and the exit code still can be 0. But for a valid
rem     division the exit code must has a not negative value.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as a division result of <var> with <value>.
rem
rem   Format:
rem     NNN,NNN,NNN,NNN,NNN,NNN
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is `N,N,N,N,N,N` formatted if a variable name is
rem   not empty and the divisor is not 0.
rem
rem   If the divisor is 0, then a variable value does not change.
rem
rem   NOTE:
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem <var>:
rem   A variable name for a string value of a partially folded integer number.
rem
rem   Format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN]]]]]
rem     , where NNN must not begin by 0 except 0 or except sequence of zeroes.
rem
rem   Evaluates the sequence from the left to the right.
rem
rem   Does contain only an integer part without a fractional:
rem
rem     A1[,A2[,A3[,A4[,A5[,A6]]]]]

rem <value>:
rem   An unsigned integer number with the 32-bit range limitation.
rem   Must be less than 2147483648.
rem   If not defined, then is 0 and triggers a division by zero error.
rem
rem   CAUTION:
rem     The algorithm still can reach an underflow with a too big <value>, even
rem     if it is less than 2147483648.
rem     To avoid this case do decrease the divisor by at least 1000 or use the
rem     value less than 2147484. This will avoid an underflow condition.

rem Examples:
rem   1. >
rem      rem 2,147,483,648,000,000
rem      set a=2,147,483,648
rem      udiv.bat b a 123
rem      rem ERRORLEVEL=62
rem      rem b=0,17,459,216,650,406
rem   2. >
rem      rem 1,023,045,067,890,000
rem      set a=1,23,45,67,890
rem      udiv.bat b a 123456
rem      rem ERRORLEVEL=111696
rem      rem b=0,0,8,286,718,84
rem   3. >
rem      rem 1,000,000,000,000,000
rem      set a=1
rem      set b=x
rem      udiv.bat b a
rem      Divide by zero error.
rem      rem ERRORLEVEL=-1
rem      rem b=x
