@echo off & ( if "%~1" == "" exit /b -1 ) & ( if "%~2" == "" exit /b -1 ) & ( if "%~3" == "" exit /b -1 ) & ^
setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & set "R=%~1" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ^
set "L=!L1!,!L2!,!L3!,!L4!,!L5!,!L6!" & set "LR=!R!" & set "R=%~3" & set "L1=0" & set "L2=0" & set "L3=0" & set "L4=0" & set "L5=0" & set "L6=0" ^
  & ( if defined R set "L6=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) & ( if "!L6:~2,1!" == "" set "L6=0!L6!" ) ^
  & ( if defined R set "L5=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) & ( if "!L5:~2,1!" == "" set "L5=0!L5!" ) ^
  & ( if defined R set "L4=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) & ( if "!L4:~2,1!" == "" set "L4=0!L4!" ) ^
  & ( if defined R set "L3=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) & ( if "!L3:~2,1!" == "" set "L3=0!L3!" ) ^
  & ( if defined R set "L2=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) & ( if "!L2:~2,1!" == "" set "L2=0!L2!" ) ^
  & ( if defined R set "L1=!R:~-3!" & set "R=!R:~0,-3!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" ) & ( if "!L1:~2,1!" == "" set "L1=0!L1!" )
for /F "tokens=* delims="eol^= %%i in ("!L!") do for /F "tokens=* delims="eol^= %%j in ("!L1!,!L2!,!L3!,!L4!,!L5!,!L6!") do ^
for /F "usebackq tokens=* delims="eol^= %%l in ('"!LR!"') do for /F "usebackq tokens=* delims="eol^= %%r in ('"!R!"') do endlocal & ^
set "LR=%%~l" & set "RR=%%~r" & ( if not defined LR if not defined RR if "%%i" %~2 "%%j" ( exit /b 0 ) else exit /b 1 ) ^
  & ( if not defined LR set "LR=0" ) & ( if not defined RR set "RR=0" ) & ^
setlocal ENABLEDELAYEDEXPANSION & set "OP=%~2" ^
  & ( if "!OP!" == "=="  set "OP=EQU" ) & ( if "!OP!" == "<" set "OP=LSS" ) & ( if "!OP!" == ">=" set "OP=GEQ" ) & ( if "!OP!" == ">" set "OP=GTR" ) & ( if "!OP!" == "<=" set "OP=LEQ" ) ^
  & ( if /i "!OP!" == "EQU" endlocal & ( if "%%i" EQU "%%j" ( call "%%~0" "%%LR%%" EQU "%%RR%%" & exit /b ) else exit /b 1 ) ) ^
  & ( if /i "!OP!" == "NEQ" endlocal & ( if "%%i" NEQ "%%j" ( exit /b 0 ) else call "%%~0" "%%LR%%" NEQ "%%RR%%" & exit /b ) ) ^
  & ( if /i "!OP!" == "LSS" endlocal & ( ( call "%%~0" "%%LR%%" LSS "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" LSS "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "GEQ" endlocal & ( ( call "%%~0" "%%LR%%" GTR "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" GEQ "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "GTR" endlocal & ( ( call "%%~0" "%%LR%%" GTR "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" GTR "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) ) ^
  & ( if /i "!OP!" == "LEQ" endlocal & ( ( call "%%~0" "%%LR%%" LSS "%%RR%%" && exit /b 0 ) & ( call "%%~0" "%%LR%%" EQU "%%RR%%" && ( if "%%i" LEQ "%%j" ( exit /b 0 ) else exit /b 1 ) || exit /b ) ) )
exit /b -1

rem USAGE:
rem   ucmp.bat <lvalue> <op> <rvalue>

rem Description:
rem   Compare unfolded unsigned integer number values as `0` complemented
rem   strings.
rem
rem   Negative exit code indicates an error.

rem Examples:
rem
rem   1. Number comparison
rem      >
rem      call ucmp.bat 10 GTR 9 && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   2. Still number comparison
rem      >
rem      call ucmp.bat "10" GTR "9" && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   3. Invalid comparison
rem      >
rem      call ucmp.bat "" EQU "0" && echo TRUE || echo FALSE
rem      rem ERRORLEVEL=-1
rem      rem FALSE
rem      call ucmp.bat "1" GTR "" && echo TRUE || echo FALSE
rem      rem ERRORLEVEL=-1
rem      rem FALSE
