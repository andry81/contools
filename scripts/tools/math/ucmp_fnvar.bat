@echo off & ( if "%~1" == "" exit /b -1 ) & ( if "%~2" == "" exit /b -1 ) & ( if "%~3" == "" exit /b -1 ) & ^
setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%a in ('"!%~1!"') do for /F "usebackq tokens=* delims="eol^= %%b in ('"!%~3!"') do ^
set "L=%%~a" & set "R=%%~b" & ( if not defined L exit /b -1 ) & ( if not defined R exit /b -1 ) & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%a in ("!L!") do ^
set "L1=%%a" & set "L2=%%b" & set "L3=%%c" & set "L4=%%d" & set "L5=%%e" & set "L6=%%f" & set "LR=%%g" ^
  & ( if not defined L1 set "L1=0" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) ^
  & ( if not defined L2 set "L2=0" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if not defined L3 set "L3=0" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if not defined L4 set "L4=0" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if not defined L5 set "L5=0" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if not defined L6 set "L6=0" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & set "L=!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" & ^
for /F "tokens=1,2,3,4,5,6,* delims=,.:;" %%a in ("!R!") do ^
set "L1=%%a" & set "L2=%%b" & set "L3=%%c" & set "L4=%%d" & set "L5=%%e" & set "L6=%%f" & set "RR=%%g" ^
  & ( if not defined L1 set "L1=0" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) ^
  & ( if not defined L2 set "L2=0" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if not defined L3 set "L3=0" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if not defined L4 set "L4=0" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if not defined L5 set "L5=0" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if not defined L6 set "L6=0" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" )
for /F "tokens=* delims="eol^= %%i in ("!L!") do for /F "tokens=* delims="eol^= %%j in ("!L1!,!L2!,!L3!,!L4!,!L5!,!L6!") do ^
for /F "usebackq tokens=* delims="eol^= %%l in ('"!LR!"') do for /F "usebackq tokens=* delims="eol^= %%r in ('"!RR!"') do endlocal ^
  & ( if "%%~l" == "" if "%%~r" == "" if "%%i" %~2 "%%j" ( exit /b 0 ) else exit /b 1 ) & ^
set "LR=%%~l" & set "RR=%%~r" ^
  & ( if not defined LR set "LR=0" ) & ( if not defined RR set "RR=0" ) ^
  & ( if /i "%~2" == "EQU" if "%%i" EQU "%%j" ( call "%%~0" LR EQU RR & exit /b ) else exit /b 1 ) ^
  & ( if /i "%~2" == "NEQ" if "%%i" NEQ "%%j" ( exit /b 0 ) else call "%%~0" LR NEQ RR & exit /b ) ^
  & ( if /i "%~2" == "LSS" if "%%i" LSS "%%j" ( exit /b 0 ) else if "%%i" EQU "%%j" ( call "%%~0" LR LSS RR & exit /b ) else exit /b 1 ) ^
  & ( if /i "%~2" == "GEQ" if "%%i" GTR "%%j" ( exit /b 0 ) else if "%%i" EQU "%%j" ( call "%%~0" LR GEQ RR & exit /b ) else exit /b 1 ) ^
  & ( if /i "%~2" == "GTR" if "%%i" GTR "%%j" ( exit /b 0 ) else if "%%i" EQU "%%j" ( call "%%~0" LR GTR RR & exit /b ) else exit /b 1 ) ^
  & ( if /i "%~2" == "LEQ" if "%%i" LSS "%%j" ( exit /b 0 ) else if "%%i" EQU "%%j" ( call "%%~0" LR LEQ RR & exit /b ) else exit /b 1 )
exit /b -1

rem USAGE:
rem   ucmp_fnvar.bat <lvar> <op> <rvar>

rem Description:
rem   Compares folded unsigned integer number values in variables as 0
rem   complemented strings.
rem
rem   Positive exit code indicates a false.
rem   Zero exit code indicates a true.
rem   Negative exit code indicates an error.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.

rem <lvar>, <rvar>:
rem   A variable name for a string value of a partially folded integer number.
rem
rem   Format:
rem     NNN[,NNN[,NNN[,NNN[,NNN[,NNN[,...]]]]]]
rem     , where NNN can begin by 0 but does not treated as an octal number.
rem
rem   Unfolds the sequence from the left to the right.
rem
rem   Can contain additional inner sequence(s) to the right of the outer
rem   sequence:
rem
rem     A1[,A2[,A3[,A4[,A5[,A6[,B1[,B2[,B3[,B4[,B5[,B6[,...]]]]]]]]]]]]
rem
rem   In that case the left sequence `An` compares before a right sequence
rem   comparison and if is weakly ordered, then a right sequence does compare
rem   recursively until of a strong order or until the end of a sequence or a
rem   comparison.
rem
rem   If a right sequence is empty for both arguments, then returns comparison
rem   result of a left sequence
rem
rem   If a right sequence is not empty for one of arguments, then the right
rem   sequence of another argument is treated as 0.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string input.
rem
rem     999,999,999,999,999,999 is equivalent to 60-bit integer
rem     2147483647,999,999,999,999,999 is equivalent to 81-bit integer

rem <op>:
rem   Comparison operator. See `if /?` for details.
rem   The `==` operator does not supported.

rem Examples:
rem
rem   1. Folded number comparison
rem      >
rem      set a=10,0
rem      set b=9,0
rem      call ucmp_fnvar.bat a GTR b && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   2. Folded number comparison
rem      >
rem      set a=0,0,0,0,0,0,0,10,0
rem      set b=0,0,0,0,0,0,0,9,0
rem      call ucmp_fnvar.bat a GTR b && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   3. Folded number comparison
rem      >
rem      set a=0,0,0,0,0,0,0,1,0
rem      set b=0,0,0,0,0,0,0,01,0
rem      call ucmp_fnvar.bat a EQU b && echo TRUE || echo FALSE
rem      rem TRUE
