@echo off & ( if "%~1" == "" exit /b -1 ) & setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & ^
set "R=!%~2!" & ( if not defined R exit /b -1 ) & for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%i in ("!R!") do ^
set "L1=%%i" & set "L2=%%j" & set "L3=%%k" & set "L4=%%l" & set "L5=%%m" & set "L6=%%n" & set "F=%%o" ^
  & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) ^
  & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) ^
  & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) ^
  & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) ^
  & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) ^
  & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ^
set /A "L1+=0" & set /A "L2+=0" & set /A "L3+=0" & set /A "L4+=0" & set /A "L5+=0" & set /A "L6+=0" & set "L=!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" ^
  & ( if "!L!" == "0,0,0,0,0,0" set "L=0" ) ^
  & ( if not defined F for /F "tokens=* delims=" %%a in ("!L!") do endlocal & endlocal & set "%~1=%%a" & exit /b 0 ) ^
  & ( if "!L!" NEQ "0" for /F "tokens=* delims=" %%a in ("!L!,!F!") do endlocal & endlocal & set "%~1=%%a" & exit /b 0 ) & ^
for /F "tokens=* delims=" %%a in ("!F!") do endlocal & set "R=%%a" & call "%%~0" L R & ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims=" %%a in ("!L!") do endlocal & endlocal & set "%~1=%%a" & exit /b 0

rem USAGE:
rem   ultrim_fnvar.bat <out-var> <var>

rem Description:
rem   An unsigned integer number zero groups trim script to trim groups from
rem   the left in a folded integer number.
rem
rem   Zero exit code indicates a success.
rem   Negative exit code indicates an error and <out-var> does not change.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.
rem
rem   CAUTION:
rem     The <var> does not normalize before the trim. If you want a folded
rem     number explicit normalization, then you have to call the `unorm.bat`
rem     script before this one. Note that all the math operation scripts does
rem     normalize the output.

rem <out-var>:
rem   A variable name for a string value of a trimmed integer <var>.
rem
rem   Format:
rem     0|NNN,NNN,NNN,NNN,NNN,NNN[,NNN,NNN,NNN,NNN,NNN,NNN[,...]]
rem     , where NNN does not begin by 0 except 0.
rem
rem   The output value is always `N,N,N,N,N,N[,N,N,N,N,N,N[,...]]` formatted if
rem   a variable name is not empty and has a not zero number value.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem <var>:
rem   A variable name for a string value of a folded integer number.
rem
rem   Format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN[...]]]]]]
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
rem   left sequence `An` if `An` is trimmed (`An=0`). If the whole sequence is
rem   consisted of zero(s), then `0` returns.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. >
rem      set a=000,123,000
rem      ultrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,123,0,0,0,0
rem
rem   2. >
rem      set a=123000
rem      ultrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=123000,0,0,0,0,0
rem
rem   3. >
rem      set a=0,0,0,0,00,000,0,0,0,0,0,1
rem      ultrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,1
rem
rem   4. >
rem      set a=0,0,0,0,00,000
rem      ultrim_fnvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0
rem
rem   5. >
rem      set b=x
rem      ultrim_fnvar.bat b
rem      rem ERRORLEVEL=-1
rem      rem b=x
