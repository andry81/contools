@echo off & setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~1!"') do for /F "usebackq tokens=* delims="eol^= %%j in ('"!%~3!"') do endlocal & if %~4 %%~i %~2 %%~j exit /b 0
exit /b 255

rem USAGE:
rem   cmp_nvar.bat <lvar> <op> <rvar> [<expr-prefix>]

rem Description:
rem   Compare number values in variables.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem Examples:
rem
rem   1. >
rem      rem number comparison
rem      set "a=10"
rem      set "b=9"
rem      call cmp_nvar.bat a GTR b && echo TRUE || echo FALSE
rem      rem TRUE
rem
rem   2. >
rem      rem CAUTION: still string comparison
rem      set a="10"
rem      set b="9"
rem      call cmp_nvar.bat a GTR b && echo TRUE || echo FALSE
rem      rem FALSE
