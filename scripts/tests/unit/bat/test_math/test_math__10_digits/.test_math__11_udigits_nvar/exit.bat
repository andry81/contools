@echo off

if defined INREF call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" INREF EQU IN || exit /b 10

if defined RETREF call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" RETREF EQU TEST_IMPL_ERROR || exit /b 20

exit /b 0
