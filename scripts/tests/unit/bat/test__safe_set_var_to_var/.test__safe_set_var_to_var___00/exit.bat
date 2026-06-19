@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" LVAR EQU RVAR || exit /b 10

exit /b 0
