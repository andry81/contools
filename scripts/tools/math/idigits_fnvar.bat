@echo off & ( if "%~1" == "" exit /b 1 ) & setlocal ENABLEDELAYEDEXPANSION & ^
set "R=!%~1!" & ( if not defined R exit /b 1 ) & for /F "tokens=1,2,3,4,5,6,* delims=,.:;'" %%i in ("!R!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" ^
  & ( if defined L1 if "!L!:~0,1!" == "+" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "-" set "L1=!L1:~1!" ) ^
  & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) ^
  & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) ^
  & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) ^
  & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) ^
  & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) ^
  & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ^
set /A "L1+=0" & set /A "L2+=0" & set /A "L3+=0" & set /A "L4+=0" & set /A "L5+=0" & set /A "L6+=0" & ^
set "L=0" & ( if "!L1!!L2!!L3!!L4!!L5!!L6!" == "000000" call "%%~dp0udigits_fnvar.bat" F & set /A "L+=!ERRORLEVEL!" & exit /b !L! ) ^
  & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) ^
  & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ^
set "R=!L1!!L2!!L3!!L4!!L5!!L6!" & call "%%~dp0udigits_nvar.bat" R & set /A "L+=!ERRORLEVEL!" ^
  & ( if defined F set "F=1!F!" & call "%%~dp0udigits_fnvar.bat" F & set /A "L+=!ERRORLEVEL!-1" ) & exit /b !L!
exit /b 1

rem USAGE:
rem   idigits_fnvar.bat <var>

rem Description:
rem   A signed integer number digits counter script to count digits in a
rem   folded integer number.
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
rem   A variable name for a string value of a folded integer number.
rem
rem   Format:
rem     [+|-]NNN[,NNN[,NNN[,NNN[,NNN[,NNN[...]]]]]]
rem     , where NNN can begin by 0 but does not treated as an octal number.
rem
rem   Evaluates the sequence from the left to the right.
rem
rem   Can contain additional inner sequence(s) to the right of the outer
rem   sequence:
rem
rem     A1[,A2[,A3[,A4[,A5[,A6[,B1[,B2[,B3[,B4[,B5[,B6[,...]]]]]]]]]]]]
rem
rem   In that case the right sequence `Bn` does evaluate the same way as the
rem   left sequence `An`. If the whole sequence is consisted of zero(s), then
rem   does treated as a single `0`. If `An` is not zero, then leading zeros
rem   in `Bn` does count.
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
rem      set a=-000,123,000
rem      idigits_fnvar.bat a
rem      rem ERRORLEVEL=15
rem
rem   2. >
rem      set a=+000,000,000
rem      idigits_fnvar.bat a
rem      rem ERRORLEVEL=1
rem
rem   3. >
rem      set a=-xxx
rem      idigits_fnvar.bat a
rem      rem ERRORLEVEL=1
rem      rem a=-xxx
