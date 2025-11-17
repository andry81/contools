@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" VERSION_RETURNED EQU VERSION_REF || exit /b 10

if %TEST_IMPL_ERROR% NEQ 0 exit /b 20

exit /b 0
