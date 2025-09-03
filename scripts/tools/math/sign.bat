@echo off & setlocal DISABLEDELAYEDEXPANSION & setlocal ENABLEDELAYEDEXPANSION & set "L=!%~1!" & ( if not defined L exit /b 0 ) & set "LS=+" ^
  & ( if "!L:~0,1!" == "+" set "L=!L:~1!" ) & ( if defined L if "!L:~0,1!" == "-" set "LS=-" & set "L=!L:~1!" ) & ( if not defined L exit /b 0 ) & ^
for /F "tokens=1,2 delims=,.:;" %%i in ("!LS!,!L!") do endlocal & ( if %%i%%j EQU 0 exit /b 0 ) & exit /b %%i1

rem USAGE:
rem   sign.bat <var>

rem Description:
rem   Returns the sign of a value in a variable as signed 1.
rem   If a variable has no value or undefined, then 0 is returned.
