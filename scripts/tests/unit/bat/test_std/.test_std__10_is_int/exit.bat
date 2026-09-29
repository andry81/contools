@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" RETREF EQU TEST_IMPL_ERROR || exit /b 10

exit /b 0
