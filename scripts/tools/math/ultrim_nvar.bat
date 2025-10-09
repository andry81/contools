@echo off & ( if "%~1" == "" exit /b -1 ) & setlocal ENABLEDELAYEDEXPANSION & set "R=!%~2!" & ( if not defined R exit /b -1 ) & ^
for /F "tokens=* delims=0"eol^= %%i in ("!R!") do endlocal & set "%~1=%%i" & exit /b 0
endlocal & set "%~1=0" & exit /b 0

rem USAGE:
rem   ultrim_nvar.bat <out-var> <var>

rem Description:
rem   An unsigned integer number zero trim script to trim zeros from the left
rem   in an unfolded integer number.
rem
rem   Zero exit code indicates a success.
rem   Negative exit code indicates an error and <out-var> does not change.
rem
rem   NOTE:
rem     The `unsigned` in case of an integer number prefix does mean you must
rem     not use negative `-` nor positive `+` signs.

rem <out-var>:
rem   A variable name for a string value of a trimmed integer <var>.
rem
rem   Format:
rem     NNN[NNN[NNN[NNN[NNN[NNN[...]]]]]]
rem     , where a not first NNN can begin by 0 but does not treated as an octal
rem       number.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999999999999999999 is equivalent to 60-bit integer
rem     2147483647999999999999999 is equivalent to 81-bit integer

rem <var>:
rem   A variable name for a string value of an unfolded integer number.
rem
rem   Format:
rem     NNN[NNN[NNN[NNN[NNN[NNN[...]]]]]]
rem     , where NNN can begin by 0 but does not treated as an octal number.
rem
rem   NOTE:
rem     The number can represent a value greater than 32-bit unsigned integer
rem     as a string output.
rem
rem     999999999999999999 is equivalent to 60-bit integer
rem     2147483647999999999999999 is equivalent to 81-bit integer

rem Examples:
rem
rem   1. >
rem      set a=000123000
rem      ultrim_nvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=123000
rem
rem   2. >
rem      set a=+000123000
rem      ultrim_nvar.bat b a
rem      rem ERRORLEVEL=0
rem      rem b=+000123000
rem
rem   3. >
rem      set b=x
rem      ultrim_nvar.bat b
rem      rem ERRORLEVEL=-1
rem      rem b=x
