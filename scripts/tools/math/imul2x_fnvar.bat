@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%a in ('"!%~2!"') do for /F "usebackq tokens=* delims="eol^= %%b in ('"!%~3!"') do ^
set "L=%%~a" & set "R=%%~b" & ( if not defined L set "L=0" ) & ( if not defined R set "R=0" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;'" %%i in ("!L!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "LF=%%o" & set "LS=" & set "LR=0" ^
  & ( if defined L1 if "!L1:~0,1!" == "+" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "-" set "LS=-" ) ^
  & ( if defined LF call "%%~dp0unorm.bat" LF LF || set /A "LR=!ERRORLEVEL!" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;'" %%i in ("!R!") do ^
set "R1=%%i" & set "R2=%%j" & set "R3=%%k" & set "R4=%%l" & set "R5=%%m" & set "R6=%%n" & set "RF=%%o" & set "RS=" & set "RR=0" ^
  & ( if defined R1 if "!R1:~0,1!" == "+" set "R1=!R1:~1!" ) & ( if defined R1 if "!R1:~0,1!" == "-" set "RS=-" ) ^
  & ( if defined RF call "%%~dp0unorm.bat" RF RF || set /A "RR=!ERRORLEVEL!" ) & ^
set /A "L1+=0" & set /A "L2=!LS!L2" & set /A "L3=!LS!L3" & set /A "L4=!LS!L4" & set /A "L5=!LS!L5" & set /A "L6=!LS!(L6 + LR)" & ^
set /A "R1+=0" & set /A "R2=!RS!R2" & set /A "R3=!RS!R3" & set /A "R4=!RS!R4" & set /A "R5=!RS!R5" & set /A "R6=!RS!(R6 + RR)" & ^
set "X1=0" & set /A "X2=L1*R1" & set /A "X3=L1*R2 + L2*R1" & set /A "X4=L2*R2 + L1*R3 + L3*R1" & ^
set /A "X5=L2*R3 + L3*R2 + L1*R4 + L4*R1" & set /A "X6=L3*R3 + L2*R4 + L4*R2 + L1*R5 + L5*R1" & ^
set /A "X7=L3*R4 + L4*R3 + L2*R5 + L5*R2 + L1*R6 + L6*R1" & set /A "X8=L4*R4 + L3*R5 + L5*R3 + L2*R6 + L6*R2" & ^
set /A "X9=L4*R5 + L5*R4 + L3*R6 + L6*R3" & set /A "X10=L5*R5 + L4*R6 + L6*R4" & set /A "X11=L5*R6 + L6*R5" & set /A "X12=L6*R6" & ^
set /A "X11+=X12 / 1000" & set /A "X12%%=1000" & set /A "X10+=X11 / 1000" & set /A "X11%%=1000" & set /A "X9+=X10 / 1000" & set /A "X10%%=1000" & ^
set /A "X8+=X9 / 1000" & set /A "X9%%=1000" & set /A "X7+=X8 / 1000" & set /A "X8%%=1000" & set /A "X6+=X7 / 1000" & set /A "X7%%=1000" & ^
set /A "X5+=X6 / 1000" & set /A "X6%%=1000" & set /A "X4+=X5 / 1000" & set /A "X5%%=1000" & set /A "X3+=X4 / 1000" & set /A "X4%%=1000" & ^
set /A "X2+=X3 / 1000" & set /A "X3%%=1000" & set /A "X1+=X2 / 1000" & set /A "X2%%=1000" & set /A "R=X1 / 1000" & set /A "X1%%=1000" & set "S=" ^
  & ( if !X1! LSS 0 ( set "S=-" ) else if !X1! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X2! LSS 0 ( set "S=-" ) else if !X2! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X3! LSS 0 ( set "S=-" ) else if !X3! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X4! LSS 0 ( set "S=-" ) else if !X4! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X5! LSS 0 ( set "S=-" ) else if !X5! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X6! LSS 0 ( set "S=-" ) else if !X6! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X7! LSS 0 ( set "S=-" ) else if !X7! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X8! LSS 0 ( set "S=-" ) else if !X8! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X9! LSS 0 ( set "S=-" ) else if !X9! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X10! LSS 0 ( set "S=-" ) else if !X10! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X11! LSS 0 ( set "S=-" ) else if !X11! GTR 0 set "S=+" ) ^
  & ( if not defined S if !X12! LSS 0 ( set "S=-" ) else if !X12! GTR 0 set "S=+" ) & ( if defined S set "S=!S:+=!" ) & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!S!!X1:-=!,!X2:-=!,!X3:-=!,!X4:-=!,!X5:-=!,!X6:-=!,!X7:-=!,!X8:-=!,!X9:-=!,!X10:-=!,!X11:-=!,!X12:-=!") do endlocal & ^
set "%~1=%%b" & exit /b %%a
endlocal & set "%~1=0,0,0,0,0,0,0,0,0,0,0,0" & exit /b 0

rem USAGE:
rem   imul2x_fnvar.bat <out-var> <lvar> <rvar>

rem Description:
rem   A signed integer number multiplication script to workaround the `set /A`
rem   command 32-bit range limitation.
rem
rem   Exit code indicates an overflow with a sign.
rem
rem   NOTE:
rem     Only the integer part multiplication is implemented, the fractional
rem     part multiplication is not implemented.
rem
rem   NOTE:
rem     Also, the input integer part multiplication (except normalization) is
rem     limited to 6 folded groups of digits and the output integer part is
rem     extended to 12 folded groups to receive the overflow.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as a multiplication result of <lvar> with <rvar>.
rem
rem   Format:
rem     [-]NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN,NNN
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N,N,N,N,N,N,N` formatted if a
rem   variable name is not empty.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer

rem <lvar>, <rvar>:
rem   A variable name for a string value of a partially folded integer number.
rem
rem   Format:
rem     [+|-]NNN[,NNN[,NNN[,NNN[,NNN[,NNN[,...]]]]]]
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
rem   Then the `An` of <lvar> and <rvar> are multiplied and normalizes to
rem   return the self overflow out to the exit code.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer
rem
rem   CAUTION:
rem     An input number groups are used as is and an output number groups does
rem     normalize after the input multiplication.
rem
rem   CAUTION:
rem     In case of a value greater by modulo than `999,999,999,999,999,999`,
rem     the `<lvar>[Ai] x <rvar>[Aj]` product can give an overflow:
rem
rem         X2  <= 2147483647
rem       2*X3  <= 2147483647
rem       3*X4  <= 2147483647
rem       4*X5  <= 2147483647
rem       5*X6  <= 2147483647
rem       6*X7  <= 2147483647
rem       5*X8  <= 2147483647
rem       4*X9  <= 2147483647
rem       3*X10 <= 2147483647
rem       2*X11 <= 2147483647
rem         X12 <= 2147483647
rem
rem       , where Xn = Ai x Aj
rem
rem     Then Xn must be in average by modulo less or equal than
rem     `sqrt(2147483647 / K)`, where K=6 is a maximum quantity of additions
rem     (accumulation) into `X7` group, excluding the normalization:
rem
rem       Xn <= sqrt(2147483647 / 6) = 18918
rem
rem     Normalization gives additional condition:
rem
rem       6*X7^2 + 5*X8^2 / 1000 <= 2147483647
rem
rem     Then Xn by modulo must be not greater than an extremum in X7
rem     (average maximum):
rem
rem       Xn <= sqrt(2147483647 * 1000 / 6005) = 18910
rem
rem     Then average maximum number would be:
rem
rem       18910,18910,18910,18910,18910,18910
rem
rem     And this one number will give an overflow in the middle of an output
rem     number:
rem
rem       18911,18911,18911,18911,18911,18911
rem
rem     Note that the A2..A6 groups does NOT normalize before the
rem     multiplication. But because basically they has been already normalized,
rem     then the extremum would be accumulated mostly by A1:
rem
rem       X2 = A1^2 <= 2147483647
rem
rem       A1 <= sqrt(2147483647) = 46340
rem
rem     Normalization gives additional condition:
rem
rem       X2 + X3 / 1000 <= 2147483647
rem
rem       A1^2 + 2*A1*999 / 1000 <= 2147483647
rem
rem       A1 <= (sqrt(2147483647998001) - 999)/1000 = 46339
rem
rem     Then the positive maximum number would be:
rem
rem       46339,999,999,999,999,999
rem
rem     And this one number will give an overflow in the exit code:
rem
rem       46340,999,999,999,999,999

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000
rem      set a=-1,2,3
rem      imul2x_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0
rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,12,369,727,35,0,0,0
rem
rem   2. >
rem      set a=-0,0,0,1,2,3
rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,12,369,727,35
rem
rem   3. >
rem      set b=0,0,0,0,0,12345
rem      imul2x_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0,0,0,0,0,0,0
rem
rem   4. >
rem      imul2x_fnvar.bat x
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0,0,0,0,0,0,0
