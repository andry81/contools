@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" STRING_TRIMMED EQU STRING_REFERENCE || exit /b 10

if %TEST_IMPL_ERROR% NEQ 0 exit /b 20

exit /b 0
