@echo off & setlocal ENABLEDELAYEDEXPANSION & ^
set "R=!%~2!" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if not defined L6 set "L6=0" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if not defined L5 set "L5=0" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if not defined L4 set "L4=0" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if not defined L3 set "L3=0" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if not defined L2 set "L2=0" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if not defined L1 set "L1=0" ) & ^
set /A "F=R" & set "R=" ^
  & ( if !L1! NEQ 0 set "R=!L1!" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L2! NEQ 0 ( set "R=!R!!L2!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L3! NEQ 0 ( set "R=!R!!L3!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L4! NEQ 0 ( set "R=!R!!L4!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L5! NEQ 0 ( set "R=!R!!L5!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L6! NEQ 0 ( set "R=!R!!L6!" ) else if defined R set "R=!R!0" )
for /F "tokens=* delims=" %%a in ("!R!") do endlocal & set "%~1=%%a" & exit /b %F%
endlocal & set /A "%~1=0" & if not "%~2" == "" if defined %~2 exit /b %F%
exit /b -1

rem USAGE:
rem   fold.bat <out-var> <var>

rem Description:
rem   Unsigned integer series fold script.
rem   Positive exit code indicates an overflow.
rem   Negative exit code indicates invalid input.

rem <var>:
rem   String value of unfolded <var>.

rem <out-var>:
rem   Integer series of numbers in the format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN]]]]]
rem     , where NNN must not begin by 0 except `0`

rem Examples:
rem   1. >
rem      set a=0123456000001002003
rem      fold.bat b a
rem      rem b=123,456,0,1,2,3
rem   2. >
rem      fold.bat b
rem      rem b=0