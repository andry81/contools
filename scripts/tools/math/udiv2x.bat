@echo off & set "D=%~3" & set /A "D=D/D - 1 + D" || exit /b -1 & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!%~2!") do ^
set "L01=%%i" & set "L02=%%j" & set "L03=%%k" & set "L04=%%l" & set "L05=%%m" & set "L06=%%n" & set "F=%%o" & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!F!,0") do ^
set "L07=%%i" & set "L08=%%j" & set "L09=%%k" & set "L10=%%l" & set "L11=%%m" & set "L12=%%n" & set "F=%%o" ^
  & ( if defined F if "!F:0=!" == "" set "F=" ) & ( if defined F call "%%~dp0unorm.bat" F F || set /A "L12+=!ERRORLEVEL!" ) & ^
set /A "L11+=L12 / 1000" & set /A "L12%%=1000" & set /A "L10+=L11 / 1000" & set /A "L11%%=1000" & set /A "L09+=L10 / 1000" & set /A "L10%%=1000" & ^
set /A "L08+=L09 / 1000" & set /A "L09%%=1000" & set /A "L07+=L08 / 1000" & set /A "L08%%=1000" & set /A "L06+=L07 / 1000" & set /A "L07%%=1000" & ^
set /A "L05+=L06 / 1000" & set /A "L06%%=1000" & set /A "L04+=L05 / 1000" & set /A "L05%%=1000" & set /A "L03+=L04 / 1000" & set /A "L04%%=1000" & ^
set /A "L02+=L03 / 1000" & set /A "L03%%=1000" & set /A "L01+=L02 / 1000" & set /A "L02%%=1000" & set /A "R=L01 %% D" & set /A "L01/=D" ^
  & ( if !R! NEQ 0 ( ( if "!L02:~2,1!" == "" set "L02=0!L02!" ) & ( if "!L02:~2,1!" == "" set "L02=0!L02!" ) & set "R=!R!!L02!" ) else set "R=!L02!" ) & set /A "L02=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L03:~2,1!" == "" set "L03=0!L03!" ) & ( if "!L03:~2,1!" == "" set "L03=0!L03!" ) & set "R=!R!!L03!" ) else set "R=!L03!" ) & set /A "L03=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L04:~2,1!" == "" set "L04=0!L04!" ) & ( if "!L04:~2,1!" == "" set "L04=0!L04!" ) & set "R=!R!!L04!" ) else set "R=!L04!" ) & set /A "L04=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L05:~2,1!" == "" set "L05=0!L05!" ) & ( if "!L05:~2,1!" == "" set "L05=0!L05!" ) & set "R=!R!!L05!" ) else set "R=!L05!" ) & set /A "L05=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L06:~2,1!" == "" set "L06=0!L06!" ) & ( if "!L06:~2,1!" == "" set "L06=0!L06!" ) & set "R=!R!!L06!" ) else set "R=!L06!" ) & set /A "L06=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L07:~2,1!" == "" set "L07=0!L07!" ) & ( if "!L07:~2,1!" == "" set "L07=0!L07!" ) & set "R=!R!!L07!" ) else set "R=!L07!" ) & set /A "L07=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L08:~2,1!" == "" set "L08=0!L08!" ) & ( if "!L08:~2,1!" == "" set "L08=0!L08!" ) & set "R=!R!!L08!" ) else set "R=!L08!" ) & set /A "L08=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L09:~2,1!" == "" set "L09=0!L09!" ) & ( if "!L09:~2,1!" == "" set "L09=0!L09!" ) & set "R=!R!!L09!" ) else set "R=!L09!" ) & set /A "L09=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L10:~2,1!" == "" set "L10=0!L10!" ) & ( if "!L10:~2,1!" == "" set "L10=0!L10!" ) & set "R=!R!!L10!" ) else set "R=!L10!" ) & set /A "L10=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L11:~2,1!" == "" set "L11=0!L11!" ) & ( if "!L11:~2,1!" == "" set "L11=0!L11!" ) & set "R=!R!!L11!" ) else set "R=!L11!" ) & set /A "L11=R / D" & set /A "R%%=D" ^
  & ( if !R! NEQ 0 ( ( if "!L12:~2,1!" == "" set "L12=0!L12!" ) & ( if "!L12:~2,1!" == "" set "L12=0!L12!" ) & set "R=!R!!L12!" ) else set "R=!L12!" ) & set /A "L12=R / D" & set /A "R%%=D" & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!L01!,!L02!,!L03!,!L04!,!L05!,!L06!,!L07!,!L08!,!L09!,!L10!,!L11!,!L12!") do endlocal & set "%~1=%%b" & exit /b %%a
endlocal & set "%~1=0,0,0,0,0,0,0,0,0,0,0,0" & exit /b 0

rem USAGE:
rem   udiv2x.bat <out-var> <lvar> <rvalue>

rem Description:
rem   An unsigned division script to workaround the `set /A` command 32-bit
rem   range limitation.
rem
rem   Exit code returns a remainder to a dividend, except division by zero when
rem   it returns -1.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.
rem
rem   NOTE:
rem     The output integer part division (except normalization) is limited by
rem     12 folded groups of digits.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as a division result of <lvar> with <rvalue>.
rem
rem   Format:
rem     NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N,N,N,N,N,N,N` formatted if a
rem   variable name is not empty and the divisor is not 0.
rem
rem   If the divisor is 0, then a variable value does not change.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer

rem <lvar>:
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
rem   Then the `An` divides by the <rvalue> and returns the remainder out to
rem   the exit code.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer

rem <rvalue>:
rem   An usigned integer number with the 32-bit range limitation.
rem   Must be less than 2147483648.
rem   If not defined, then is 0 and triggers a division by zero error.
rem
rem   CAUTION:
rem     The algorithm still can reach an underflow with a too big <rvalue>,
rem     even if it is less than 2147483648.
rem     To avoid this case do decrease the divisor by at least 1000 times or
rem     use the value less than 2147484. This will avoid an underflow
rem     condition.

rem Examples:
rem
rem   1. >
rem      rem 2,147,483,648,000,000,000,000,000,000,000,000
rem      set a=2,147,483,648
rem      udiv2x.bat b a 123
rem      rem ERRORLEVEL=8
rem      rem b=0,17,459,216,650,406,504,65,40,650,406,504
rem
rem   2. >
rem      rem 1,023,045,067,890,000,000,000,000,000,000,000
rem      set a=1,23,45,67,890
rem      udiv2x.bat b a 123456
rem      rem ERRORLEVEL=33216
rem      rem b=0,0,8,286,718,84,904,743,390,357,698,289
rem
rem   3. >
rem      rem 1,000,000,000,000,000,000,000,000,000,000,000
rem      set a=1
rem      set b=x
rem      udiv2x.bat b a
rem      Divide by zero error.
rem      rem ERRORLEVEL=-1
rem      rem b=x
