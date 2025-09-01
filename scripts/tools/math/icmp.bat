@echo off & ( if "%~1" == "" exit /b -1 ) & ( if "%~2" == "" exit /b -1 ) & ( if "%~3" == "" exit /b -1 ) & ^
setlocal DISABLEDELAYEDEXPANSION & set "L=%~1" & set "R=%~3" & ^
setlocal ENABLEDELAYEDEXPANSION & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" & set "LS=+" & set "RS=+" ^
  & ( if defined L if "!L:~0,1!" == "+" set "L=!L:~1!" ) & ( if defined R if "!R:~0,1!" == "+" set "R=!R:~1!" ) ^
  & ( if defined L if "!L:~0,1!" == "-" set "LS=-" & set "L=!L:~1!" ) & ( if defined R if "!R:~0,1!" == "-" set "RS=-" & set "R=!R:~1!" ) ^
  & ( if defined L set "L6=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) ^
  & ( if defined L set "L5=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if defined L set "L4=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if defined L set "L3=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if defined L set "L2=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if defined L set "L1=!L:~-3!" & set "L=!L:~0,-3!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ^
set "LR=!L!" & set "L=!LS!!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ^
set "RR=!R!" ^
  & ( if not "!LS!!RS!" == "--" ( set "R=!RS!!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" ) else set "R=!L!" & set "L=!RS!!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" ) ^
  & ( if "!L!" == "-000,000,000,000,000,000" set "L=+!L:~1!" ) & ( if "!R!" == "-000,000,000,000,000,000" set "R=+!R:~1!" ) & ^
set "LN=!L:-=1!" & set "LN=!LN:+=9!" & set "RN=!R:-=1!" & set "RN=!RN:+=9!"
for /F "tokens=* delims="eol^= %%a in ("!LS!") do for /F "tokens=* delims="eol^= %%b in ("!RS!") do ^
for /F "tokens=* delims="eol^= %%i in ("!LN!") do for /F "tokens=* delims="eol^= %%j in ("!RN!") do ^
for /F "usebackq tokens=* delims="eol^= %%l in ('"!LR!"') do for /F "usebackq tokens=* delims="eol^= %%r in ('"!RR!"') do endlocal ^
  & ( if "%%~l" == "" if "%%~r" == "" if "%%i" %~2 "%%j" ( exit /b 0 ) else exit /b 1 ) & ^
set "LR=%%~l" & set "RR=%%~r" ^
  & ( if defined LR ( set "LR=%%a%%~l" ) else set "LR=0" ) & ( if defined RR ( set "RR=%%b%%~r" ) else set "RR=0" ) & ^
set "OP=%~2" & setlocal ENABLEDELAYEDEXPANSION ^
  & ( if "!OP!" == "=="  set "OP=EQU" ) & ( if "!OP!" == "<" set "OP=LSS" ) & ( if "!OP!" == ">=" set "OP=GEQ" ) & ( if "!OP!" == ">" set "OP=GTR" ) & ( if "!OP!" == "<=" set "OP=LEQ" ) ^
  & ( if /i "!OP!" == "EQU" endlocal & ( if "%%i" EQU "%%j" ( call "%%~0" "%%LR%%" EQU "%%RR%%" & exit /b ) else exit /b 1 ) ) ^
  & ( if /i "!OP!" == "NEQ" endlocal & ( if "%%i" NEQ "%%j" ( exit /b 0 ) else call "%%~0" "%%LR%%" NEQ "%%RR%%" & exit /b ) ) ^
  & ( if /i "!OP!" == "LSS" endlocal & ( ( call "%%~0" "%%LR%%" LSS "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" LSS "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "GEQ" endlocal & ( ( call "%%~0" "%%LR%%" GTR "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" GEQ "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "GTR" endlocal & ( ( call "%%~0" "%%LR%%" GTR "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" GTR "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "LEQ" endlocal & ( ( call "%%~0" "%%LR%%" LSS "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" LEQ "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) )
exit /b -1

rem USAGE:
rem   icmp.bat <lvalue> <op> <rvalue>

rem Description:
rem   Compares unfolded signed integer number values as 0 complemented strings.
rem
rem   Positive exit code indicates a false.
rem   Zero exit code indicates a true.
rem   Negative exit code indicates an error.

rem <lvalue>, <rvalue>:
rem   String value of an unfolded integer number.
rem
rem   Format:
rem     [-]NNN[NNN[NNN[NNN[NNN[NNN[...]]]]]]
rem     , where NNN can begin by 0 but does not treated as an octal number.
rem
rem   Evaluates the sequence from the right to the left, but compares from the
rem   left to the right.
rem
rem   Can contain additional outer sequence(s) to the left of the inner
rem   sequence:
rem
rem     [[[[[[[[[[[[...]B1]B2]B3]B4]B5]B6]A1]A2]A3]A4]A5]A6
rem
rem   In that case a left sequence of `Bn` compares recursively before the
rem   right sequence comparison and if is weakly ordered, then the right
rem   sequence does compare after until of a strong order or until the end of a
rem   sequence or a comparison.
rem
rem   If a left sequence is empty for both arguments, then returns
rem   comparison result of the right sequence.
rem
rem   If a left sequence is not empty for one of arguments, then the left
rem   sequence of another argument is treated as 0.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit signed integer as
rem     a string input.
rem
rem     999999999999999999 is equivalent to 60-bit integer
rem     2147483647999999999999999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. Number comparison
rem      >
rem      call icmp.bat -10 LSS -9 && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   2. Still number comparison
rem      >
rem      call icmp.bat "-10" LSS "-9" && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   3. Still number comparison
rem      >
rem      call icmp.bat "-0" EQU "+0" && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   4. Invalid comparison
rem      >
rem      call icmp.bat "" EQU "0" && echo TRUE || echo FALSE
rem      rem ERRORLEVEL=-1
rem      rem FALSE
rem      call icmp.bat "-1" LSS "" && echo TRUE || echo FALSE
rem      rem ERRORLEVEL=-1
rem      rem FALSE
