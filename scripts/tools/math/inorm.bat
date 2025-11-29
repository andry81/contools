@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;'" %%i in ("!%~2!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" & set "S=" ^
  & ( if defined L1 if "!L1:~0,1!" == "+" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "-" set "S=-" & set /A "L6=-L6" ) ^
  & ( if defined F call "%%~dp0unorm.bat" F F || set /A "L6+=!S!(!ERRORLEVEL!)" ) & ^
set /A "L5=!S!L5 + L6 / 1000" & set /A "L6%%=1000" & set /A "L4=!S!L4 + L5 / 1000" & set /A "L5%%=1000" & set /A "L3=!S!L3 + L4 / 1000" & set /A "L4%%=1000" & ^
set /A "L2=!S!L2 + L3 / 1000" & set /A "L3%%=1000" & set /A "L1+=L2 / 1000" & set /A "L2%%=1000" & set /A "R=L1 / 1000" & set /A "L1%%=1000" & set "S=" ^
  & ( if !L1! LSS 0 ( set "S=-" ) else if !L1! GTR 0 set "S=+" ) & ( if not defined S if !L2! LSS 0 ( set "S=-" ) else if !L2! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L3! LSS 0 ( set "S=-" ) else if !L3! GTR 0 set "S=+" ) & ( if not defined S if !L4! LSS 0 ( set "S=-" ) else if !L4! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L5! LSS 0 ( set "S=-" ) else if !L5! GTR 0 set "S=+" ) & ( if not defined S if !L6! LSS 0 ( set "S=-" ) else if !L6! GTR 0 set "S=+" ) ^
  & ( if "!S!" == "+" ( ( if !L6! LSS 0 set /A "L6+=1000" & set /A "L5-=1" ) & ( if !L5! LSS 0 set /A "L5+=1000" & set /A "L4-=1" ) ^
    & ( if !L4! LSS 0 set /A "L4+=1000" & set /A "L3-=1" ) & ( if !L3! LSS 0 set /A "L3+=1000" & set /A "L2-=1" ) ^
    & ( if !L2! LSS 0 set /A "L2+=1000" & set /A "L1-=1" ) ) else if "!S!" == "-" ( ( if !L6! GTR 0 set /A "L6-=1000" & set /A "L5+=1" ) ^
    & ( if !L5! GTR 0 set /A "L5-=1000" & set /A "L4+=1" ) & ( if !L4! GTR 0 set /A "L4-=1000" & set /A "L3+=1" ) ^
    & ( if !L3! GTR 0 set /A "L3-=1000" & set /A "L2+=1" ) & ( if !L2! GTR 0 set /A "L2-=1000" & set /A "L1+=1" ) ) ) & ( if defined S set "S=!S:+=!" ) ^
  & ( if defined F set "F=,!F!" ) & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!S!!L1:-=!,!L2:-=!,!L3:-=!,!L4:-=!,!L5:-=!,!L6:-=!!F!") do endlocal & set "%~1=%%b" & exit /b %%a
endlocal & set "%~1=0,0,0,0,0,0" & exit /b 0

rem USAGE:
rem   inorm.bat <out-var> <var>

rem Description:
rem   A signed integer number normalization script to normalize a folded
rem   integer number representation.
rem
rem   Exit code indicates an overflow with a sign.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as a normalization result of <var>.
rem
rem   Format:
rem     [-]NNN,NNN,NNN,NNN,NNN,NNN[,NNN,NNN,NNN,NNN,NNN,NNN[,...]]
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N[,N,N,N,N,N,N[,...]]` formatted if
rem   a variable name is not empty.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
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
rem     [+|-]NNN[,[+|-]NNN[,[+|-]NNN[,[+|-]NNN[,[+|-]NNN[,[+|-]NNN[,...]]]]]]
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
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer
rem
rem   Each folded group can has a sign. In that case all the signs to the
rem   right of the A1 group does remove through the normalization.
rem
rem   The leading minus sign does invert signs in folded groups to the right
rem   of the A1 group and, if the leading sign is the minus, then all
rem   the positive numbers does complement to -1000, otherwise all the negative
rem   numbers does complement to +1000:
rem
rem   >
rem   rem   1,+1,-1,+1,-1,+1
rem   set a=1,+1,-1,+1,-1,+1
rem   inorm.bat b a
rem   rem b=1,0,999,0,999,1
rem
rem   >
rem   rem   -1,-1,+1,-1,+1,-1
rem   set a=-1,+1,-1,+1,-1,+1
rem   inorm.bat b a
rem   rem b=-1,0,999,0,999,1
rem
rem   Because each folded group can has a standalone sign, then you can use
rem   the signed normalization instead of an addition with the zero.
rem
rem   These operations are equivalent, but the normalization script is faster:
rem
rem   >
rem   set a=0,0,0,0,0,-2147483647
rem   iadd.bat x a 0
rem   >
rem   inorm.bat x a
rem
rem   If you don't need the normalization, then a signed fold script is even
rem   more faster (but evaluated from the right to the left):
rem
rem   >
rem   set a=-2147483647
rem   ifoldpad6.bat x a

rem Examples:
rem
rem   1. >
rem      rem   -1,1002,1003,000,000,000
rem      set a=-1,1002,1004
rem      inorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-2,3,4,0,0,0
rem
rem   2. >
rem      set a=-0,0,0,1,2,3,1005
rem      inorm.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=-0,0,0,1,2,4,5,0,0,0,0,0
rem
rem   3. >
rem      inorm.bat b
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,0
