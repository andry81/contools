@echo off & setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!%~1!"') do for /F "usebackq tokens=* delims="eol^= %%j in ('"!%~3!"') do endlocal & if %~4 "%%~i" %~2 "%%~j" exit /b 0
exit /b 255

rem USAGE:
rem   cmp_var.bat <lvar> <op> <rvar> [<expr-prefix>]

rem Description:
rem   Compare string values in variables.

rem CAUTION:
rem   The delayed expansion feature must be disabled before this script call: `setlocal DISABLEDELAYEDEXPANSION`, otherwise
rem   the `!` character will be expanded.
rem

rem Examples:
rem
rem   1. >
rem      rem string comparison
rem      set "a=a b c"
rem      set "b=A B C"
rem      call cmp_var.bat a "==" b "/i not" && echo TRUE || echo FALSE
rem      rem FALSE
rem
rem   2. >
rem      rem still string comparison
rem      set "a=10"
rem      set "b=9"
rem      call cmp_var.bat a GTR b && echo TRUE || echo FALSE
rem      rem FALSE
rem
rem   3. >
rem      rem still string comparison
rem      set "a=a b c"
rem      set "b=A B C"
rem      call cmp_var.bat a EQU b "/i not" && echo TRUE || echo FALSE
rem      rem FALSE
rem      call cmp_var.bat a NEQ b "/i not" && echo TRUE || echo FALSE
rem      rem TRUE
rem      call cmp_var.bat a EQU b && echo TRUE || echo FALSE
rem      rem FALSE
rem      call cmp_var.bat a NEQ b && echo TRUE || echo FALSE
rem      rem TRUE
