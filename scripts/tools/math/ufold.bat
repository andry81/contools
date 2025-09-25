@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
set "R=!%~2!" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if not defined L6 set "L6=0" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if not defined L5 set "L5=0" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if not defined L4 set "L4=0" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if not defined L3 set "L3=0" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if not defined L2 set "L2=0" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if not defined L1 set "L1=0" ) & ^
set /A "F=R" & set "R=" ^
  & ( if !L1! NEQ 0 set "R=!L1!" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L2! NEQ 0 ( set "R=!R!!L2!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L3! NEQ 0 ( set "R=!R!!L3!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L4! NEQ 0 ( set "R=!R!!L4!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L5! NEQ 0 ( set "R=!R!!L5!" ) else if defined R set "R=!R!0" ) & ( if defined R set "R=!R!," ) ^
  & ( if !L6! NEQ 0 ( set "R=!R!!L6!" ) else if defined R set "R=!R!0" )
for /F "tokens=* delims=" %%a in ("!R!") do endlocal & set "%~1=%%a" & exit /b %F%
endlocal & set "%~1=0" & if not "%~2" == "" if defined %~2 exit /b %F%
exit /b 0

rem USAGE:
rem   ufold.bat <out-var> <var>

rem Description:
rem   Unsigned integer series fold script without 0 padding from the left.
rem
rem   Exit code indicates an overflow.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.
rem
rem   NOTE:
rem     The `ifold.bat` version of the script has no sense, because a padding
rem     to the complete length `N,N,N,N,N,N` is required in case of a sign.
rem     Use `ifoldpad6*.bat` script(s) for a signed variant.

rem <out-var>:
rem   A variable name for a string value of a folded integer number from <var>.
rem
rem   Format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN]]]]]
rem     , where NNN does not begin by 0 except 0.
rem
rem   Folds the sequence from the right to the left.
rem
rem   The value must only be splitted by the comma if not empty and longer
rem   than NNN, and is not required to be the full length formatted as
rem   `N,N,N,N,N,N`.
rem
rem   To use the full length format output you can use either
rem   `ufoldpad6*.bat` scripts or `uadd.bat` script instead:
rem
rem     >
rem     set a=12345678901234567890
rem     ufoldpad6n.bat b a
rem     rem ERRORLEVEL=0
rem     rem b=0,0,0,0,0,12,345,678,901,234,567,890
rem
rem     >
rem     set a=12345
rem     ufoldpad6n.bat b a
rem     rem ERRORLEVEL=0
rem     rem b=0,0,0,0,12,345
rem
rem     >
rem     set a=12345678901234567890
rem     ufoldpad6.bat b a
rem     rem ERRORLEVEL=0
rem     rem b=12,345,678,901,234,567,890
rem
rem     >
rem     set a=12345
rem     ufoldpad6.bat b a
rem     rem ERRORLEVEL=0
rem     rem b=0,0,0,0,12,345
rem
rem     >
rem     uadd.bat b "" 12345
rem     rem ERRORLEVEL=0
rem     rem b=0,0,0,0,12,345
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem <var>:
rem   A variable name for a string value of an unfolded integer number.
rem   The value digits must not be splitted by separator character(s).
rem
rem   Format:
rem     NNN[NNN[NNN[NNN[NNN[NNN[...]]]]]]
rem     , where NNN can begin by 0 but does not treated as an octal number.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string input.
rem
rem     999999999999999999 is equivalent to 60-bit integer
rem     2147483647999999999999999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. >
rem      set a=12345678901234567890
rem      ufold.bat b a
rem      rem ERRORLEVEL=12
rem      rem b=345,678,901,234,567,890
rem
rem   2. >
rem      set a=0123456000001002003
rem      ufold.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=123,456,0,1,2,3
rem
rem   3. >
rem      set a=12345
rem      ufold.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=12,345
rem
rem   4. >
rem      ufold.bat b
rem      rem ERRORLEVEL=0
rem      rem b=0
