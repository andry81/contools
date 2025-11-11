@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%a in ('"!%~2!"') do for /F "usebackq tokens=* delims="eol^= %%b in ('"!%~3!"') do ^
set "L=%%~a" & set "R=%%~b" & ( if not defined L set "L=0" ) & ( if not defined R set "R=0" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!L!") do ^
set "L01=%%i" & set "L02=%%j" & set "L03=%%k" & set "L04=%%l" & set "L05=%%m" & set "L06=%%n" & set "F=%%o" & ( if not defined F set "F=0" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!F!") do ^
set "L07=%%i" & set "L08=%%j" & set "L09=%%k" & set "L10=%%l" & set "L11=%%m" & set "L12=%%n" & set "F=%%o" & set "LS=" ^
  & ( if defined L01 if "!L01:~0,1!" == "+" set "L01=!L01:~1!" ) & ( if defined L01 if "!L01:~0,1!" == "-" set "LS=-" & set /A "L12=-L12" ) ^
  & ( if defined F call "%%~dp0unorm.bat" F F || set /A "L12+=!LS!(!ERRORLEVEL!)" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!R!") do ^
set "R01=%%i" & set "R02=%%j" & set "R03=%%k" & set "R04=%%l" & set "R05=%%m" & set "R06=%%n" & set "F=%%o" & ( if not defined F set "F=0" ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!F!") do ^
set "R07=%%i" & set "R08=%%j" & set "R09=%%k" & set "R10=%%l" & set "R11=%%m" & set "R12=%%n" & set "F=%%o" & set "RS=" ^
  & ( if defined R01 if "!R01:~0,1!" == "+" set "R01=!R01:~1!" ) & ( if defined R01 if "!R01:~0,1!" == "-" set "RS=-" & set /A "R12=-R12" ) ^
  & ( if defined F call "%%~dp0unorm.bat" F F || set /A "R12+=!RS!(!ERRORLEVEL!)" ) & ^
set /A "L12+=R12" & set /A "L11=!LS!L11 + !RS!R11" & set /A "L10=!LS!L10 + !RS!R10" & set /A "L09=!LS!L09 + !RS!R09" & ^
set /A "L08=!LS!L08 + !RS!R08" & set /A "L07=!LS!L07 + !RS!R07" & set /A "L06=!LS!L06+!RS!R06" & set /A "L05=!LS!L05 + !RS!R05" & ^
set /A "L04=!LS!L04 + !RS!R04" & set /A "L03=!LS!L03 + !RS!R03" & set /A "L02=!LS!L02 + !RS!R02" & set /A "L01+=R01" & ^
set /A "L11+=L12 / 1000" & set /A "L12%%=1000" & set /A "L10+=L11 / 1000" & set /A "L11%%=1000" & set /A "L09+=L10 / 1000" & set /A "L10%%=1000" & ^
set /A "L08+=L09 / 1000" & set /A "L09%%=1000" & set /A "L07+=L08 / 1000" & set /A "L08%%=1000" & set /A "L06+=L07 / 1000" & set /A "L07%%=1000" & ^
set /A "L05+=L06 / 1000" & set /A "L06%%=1000" & set /A "L04+=L05 / 1000" & set /A "L05%%=1000" & set /A "L03+=L04 / 1000" & set /A "L04%%=1000" & ^
set /A "L02+=L03 / 1000" & set /A "L03%%=1000" & set /A "L01+=L02 / 1000" & set /A "L02%%=1000" & set /A "R=L01 / 1000" & set /A "L01%%=1000" & set "S=" ^
  & ( if !L01! LSS 0 ( set "S=-" ) else if !L01! GTR 0 set "S=+" ) & ( if not defined S if !L02! LSS 0 ( set "S=-" ) else if !L02! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L03! LSS 0 ( set "S=-" ) else if !L03! GTR 0 set "S=+" ) & ( if not defined S if !L04! LSS 0 ( set "S=-" ) else if !L04! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L05! LSS 0 ( set "S=-" ) else if !L05! GTR 0 set "S=+" ) & ( if not defined S if !L06! LSS 0 ( set "S=-" ) else if !L06! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L07! LSS 0 ( set "S=-" ) else if !L07! GTR 0 set "S=+" ) & ( if not defined S if !L08! LSS 0 ( set "S=-" ) else if !L08! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L09! LSS 0 ( set "S=-" ) else if !L09! GTR 0 set "S=+" ) & ( if not defined S if !L10! LSS 0 ( set "S=-" ) else if !L10! GTR 0 set "S=+" ) ^
  & ( if not defined S if !L11! LSS 0 ( set "S=-" ) else if !L11! GTR 0 set "S=+" ) & ( if not defined S if !L12! LSS 0 ( set "S=-" ) else if !L12! GTR 0 set "S=+" ) ^
  & ( if "!S!" == "+" ( ( if !L12! LSS 0 set /A "L12+=1000" & set /A "L11-=1" ) & ( if !L11! LSS 0 set /A "L11+=1000" & set /A "L10-=1" ) ^
    & ( if !L10! LSS 0 set /A "L10+=1000" & set /A "L09-=1" ) & ( if !L09! LSS 0 set /A "L09+=1000" & set /A "L08-=1" ) ^
    & ( if !L08! LSS 0 set /A "L08+=1000" & set /A "L07-=1" ) & ( if !L07! LSS 0 set /A "L07+=1000" & set /A "L06-=1" ) ^
    & ( if !L06! LSS 0 set /A "L06+=1000" & set /A "L05-=1" ) & ( if !L05! LSS 0 set /A "L05+=1000" & set /A "L04-=1" ) ^
    & ( if !L04! LSS 0 set /A "L04+=1000" & set /A "L03-=1" ) & ( if !L03! LSS 0 set /A "L03+=1000" & set /A "L02-=1" ) ^
    & ( if !L02! LSS 0 set /A "L02+=1000" & set /A "L01-=1" ) ) else if "!S!" == "-" ( ( if !L12! GTR 0 set /A "L12-=1000" & set /A "L11+=1" ) ^
    & ( if !L11! GTR 0 set /A "L11-=1000" & set /A "L10+=1" ) & ( if !L10! GTR 0 set /A "L10-=1000" & set /A "L09+=1" ) ^
    & ( if !L09! GTR 0 set /A "L09-=1000" & set /A "L08+=1" ) & ( if !L08! GTR 0 set /A "L08-=1000" & set /A "L07+=1" ) ^
    & ( if !L07! GTR 0 set /A "L07-=1000" & set /A "L06+=1" ) & ( if !L06! GTR 0 set /A "L06-=1000" & set /A "L05+=1" ) ^
    & ( if !L05! GTR 0 set /A "L05-=1000" & set /A "L04+=1" ) & ( if !L04! GTR 0 set /A "L04-=1000" & set /A "L03+=1" ) ^
    & ( if !L03! GTR 0 set /A "L03-=1000" & set /A "L02+=1" ) & ( if !L02! GTR 0 set /A "L02-=1000" & set /A "L01+=1" ) ) ) & ( if defined S set "S=!S:+=!" ) & ^
for /F "tokens=1,* delims=," %%a in ("!R!,!S!!L01:-=!,!L02:-=!,!L03:-=!,!L04:-=!,!L05:-=!,!L06:-=!,!L07:-=!,!L08:-=!,!L09:-=!,!L10:-=!,!L11:-=!,!L12:-=!") do endlocal & set "%~1=%%b" & exit /b %%a
exit /b 0

rem USAGE:
rem   iadd2x_fnvar.bat <out-var> <lvar> <rvar>

rem Description:
rem   A signed integer number addition script to workaround the `set /A`
rem   command 32-bit range limitation.
rem
rem   Exit code indicates an overflow with a sign.
rem
rem   NOTE:
rem     The output integer part addition (except normalization) is limited by
rem     12 folded groups of digits.

rem <out-var>:
rem   A variable name for a string value of completely folded integer number
rem   as an addition result of <lvar> with <rvar>.
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
rem     A1[,A2[,A3[,..[,A11[,A12[,B1[,B2[,B3[,..[,B11[,B12[,...]]]]]]]]]]]]
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
rem     999,999,999,999,999,999 ^ 2 is equivalent to 120-bit integer

rem Examples:
rem
rem   1. >
rem      rem -1,002,003,000,000,000,000,000,000,000,000,000
rem      set a=-1,2,3
rem      iadd2x_fnvar.bat x a
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0,0,0,0,0,0,0
rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-1,2,3,0,0,0,0,0,0,0,12,345
rem
rem   2. >
rem      set a=-0,0,0,0,0,0,0,0,0,1,2,3
rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x a b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,0,1,14,348
rem
rem   3. >
rem      set b=-0,0,0,0,0,0,0,0,0,0,0,12345
rem      iadd2x_fnvar.bat x "" b
rem      rem ERRORLEVEL=0
rem      rem x=-0,0,0,0,0,0,0,0,0,0,12,345
rem
rem   4. >
rem      iadd2x_fnvar.bat x
rem      rem ERRORLEVEL=0
rem      rem x=0,0,0,0,0,0,0,0,0,0,0,0
