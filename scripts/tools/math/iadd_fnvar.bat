@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%a in ('"!%~2!"') do for /F "usebackq tokens=* delims="eol^= %%b in ('"!%~3!"') do ^
set "L=%%~a" & set "R=%%~b" & ( if not defined L set "L=0" ) & ( if not defined R set "R=0" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!L!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" & set "LS=" ^
  & ( if defined L1 if "!L1:~0,1!" == "+" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "-" set "LS=-" & set /A "L6=-L6" & if defined F set "F=-!F!" ) ^
  & ( if defined F call "%%~dp0inorm.bat" F F || set /A "L6+=!ERRORLEVEL!" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!R!") do ^
set "R1=%%i" & set "R2=%%j" & set "R3=%%k" & set "R4=%%l" & set "R5=%%m" & set "R6=%%n" & set "F=%%o" & set "RS=" ^
  & ( if defined R1 if "!R1:~0,1!" == "+" set "R1=!R1:~1!" ) & ( if defined R1 if "!R1:~0,1!" == "-" set "RS=-" & set /A "R6=-R6" & if defined F set "F=-!F!" ) ^
  & ( if defined F call "%%~dp0inorm.bat" F F || set /A "R6+=!ERRORLEVEL!" ) & ^
set /A "L6+=R6" & set /A "L5=!LS!L5 + !RS!R5" & set /A "L4=!LS!L4 + !RS!R4" & set /A "L3=!LS!L3 + !RS!R3" & set /A "L2=!LS!L2 + !RS!R2" & set /A "L1+=R1" & ^
set /A "L5+=L6 / 1000" & set /A "L6%%=1000" & set /A "L4+=L5 / 1000" & set /A "L5%%=1000" & set /A "L3+=L4 / 1000" & set /A "L4%%=1000" & ^
set /A "L2+=L3 / 1000" & set /A "L3%%=1000" & set /A "L1+=L2 / 1000" & set /A "L2%%=1000" & set /A "R=L1 / 1000" & set /A "L1%%=1000" & set "LS=" ^
  & ( if !L1! LSS 0 ( set "LS=-" ) else if !L1! GTR 0 set "LS=+" ) ^
  & ( if not defined LS if !L2! LSS 0 ( set "LS=-" ) else if !L2! GTR 0 set "LS=+" ) ^
  & ( if not defined LS if !L3! LSS 0 ( set "LS=-" ) else if !L3! GTR 0 set "LS=+" ) ^
  & ( if not defined LS if !L4! LSS 0 ( set "LS=-" ) else if !L4! GTR 0 set "LS=+" ) ^
  & ( if not defined LS if !L5! LSS 0 ( set "LS=-" ) else if !L5! GTR 0 set "LS=+" ) ^
  & ( if not defined LS if !L6! LSS 0 ( set "LS=-" ) else if !L6! GTR 0 set "LS=+" ) ^
  & ( if "!LS!" == "+" if !L6! LSS 0 set /A "L6+=1000" & set /A "L5-=1" & set /A "L4+=L5 / 1000" & set /A "L5%%=1000" ) ^
  & ( if "!LS!" == "+" if !L5! LSS 0 set /A "L5+=1000" & set /A "L4-=1" & set /A "L3+=L4 / 1000" & set /A "L4%%=1000" ) ^
  & ( if "!LS!" == "+" if !L4! LSS 0 set /A "L4+=1000" & set /A "L3-=1" & set /A "L2+=L3 / 1000" & set /A "L3%%=1000" ) ^
  & ( if "!LS!" == "+" if !L3! LSS 0 set /A "L3+=1000" & set /A "L2-=1" & set /A "L1+=L2 / 1000" & set /A "L2%%=1000" ) ^
  & ( if "!LS!" == "+" if !L2! LSS 0 set /A "L2+=1000" & set /A "L1-=1" & set /A "R+=L1 / 1000" & set /A "L1%%=1000" ) & ( if defined LS set "LS=!LS:+=!" ) & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!LS!!L1:-=!,!L2:-=!,!L3:-=!,!L4:-=!,!L5:-=!,!L6:-=!") do endlocal & set "%~1=%%b" & exit /b %%a
exit /b 0

rem USAGE:
rem   iadd_fnvar.bat <out-var> <lvar> <rvar>

rem Description:
rem   A signed integer number addition script to workaround the `set /A`
rem   command 32-bit range limitation.
rem
rem   Exit code indicates an overflow with a sign.
rem
rem   NOTE:
rem     The output integer part addition is limited by 6 folded groups of
rem     digits. To add into 12 folded groups number use `iadd2x*.bat`
rem     script(s) instead.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as an addition result of <lvar> with <rvar>.
rem
rem   Format:
rem     [-]NNN,NNN,NNN,NNN,NNN,NNN
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N` formatted if a variable name is
rem   not empty.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

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
rem   Then the `An` of <lvar> and <rvar> are added up and normalizes to return
rem   the self overflow out to the exit code.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000
rem      set a=-1,2,3
rem      iadd_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0
rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,12,345
rem
rem   2. >
rem      set a=-0,0,0,1,2,3
rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,1,14,348
rem
rem   3. >
rem      set b=-0,0,0,0,0,12345
rem      iadd_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,12,345
rem
rem   4. >
rem      iadd_fnvar.bat x
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0
