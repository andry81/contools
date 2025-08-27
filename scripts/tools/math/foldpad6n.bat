@echo off & ( if "%~1" == "" exit /b 0 ) & setlocal ENABLEDELAYEDEXPANSION & ^
set "R=!%~2!" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if defined L6 if "!L6:~0,1!" == "0" set "L6=!L6:~1!" ) & ( if not defined L6 set "L6=0" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if defined L5 if "!L5:~0,1!" == "0" set "L5=!L5:~1!" ) & ( if not defined L5 set "L5=0" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if defined L4 if "!L4:~0,1!" == "0" set "L4=!L4:~1!" ) & ( if not defined L4 set "L4=0" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if defined L3 if "!L3:~0,1!" == "0" set "L3=!L3:~1!" ) & ( if not defined L3 set "L3=0" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if defined L2 if "!L2:~0,1!" == "0" set "L2=!L2:~1!" ) & ( if not defined L2 set "L2=0" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if defined L1 if "!L1:~0,1!" == "0" set "L1=!L1:~1!" ) & ( if not defined L1 set "L1=0" ) & ^
set "L=" & set "F=0" ^
  & ( if !L1! EQU 0 if !L2! EQU 0 if !L3! EQU 0 if !L4! EQU 0 if !L5! EQU 0 if !L6! EQU 0 set "F=1" ) ^
  & ( if defined R call "%%~0" L R && set "F=0" || set "L=" ) & ( if defined L set "L=!L!," ) & ^
for /F "tokens=* delims=" %%a in ("!L!!L1!,!L2!,!L3!,!L4!,!L5!,!L6!") do for /F "tokens=* delims=" %%i in ("!F!") do endlocal & set "%~1=%%a" & exit /b %%i
exit /b 0

rem USAGE:
rem   foldpad6n.bat <out-var> <var>

rem Description:
rem   Unsigned integer series fold script with 0 padding from the left.
rem
rem   Positive exit code indicates a zero value.
rem   Zero exit code indicates a not zero value.

rem <out-var>:
rem   A variable name for a string value of a folded integer number from <var>.
rem
rem   Format:
rem     NNN,NNN,NNN,NNN,NNN,NNN[,NNN,NNN,NNN,NNN,NNN,NNN[,...]]
rem     , where NNN does not begin by 0 except 0.
rem
rem   Folds the sequence from the right to the left.
rem
rem   The value does always split by the comma even if empty or not longer than
rem   `NNN` to be at least `N,N,N,N,N,N` formatted long.
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
rem      foldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,0,12,345,678,901,234,567,890
rem
rem   2. >
rem      set a=0123456000001002003
rem      foldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=123,456,0,1,2,3
rem
rem   3. >
rem      set a=12345
rem      foldpad6n.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=0,0,0,0,12,345
rem
rem   4. >
rem      foldpad6n.bat b
rem      rem ERRORLEVEL=1
rem      rem b=0,0,0,0,0,0
