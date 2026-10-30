@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" INDEX EQU INDEXREF || exit /b 10

exit /b 0
