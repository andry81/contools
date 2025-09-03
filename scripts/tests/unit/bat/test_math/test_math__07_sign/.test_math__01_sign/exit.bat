@echo off

rem reset error
call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" RETREF EQU TEST_IMPL_ERROR || exit /b 20

exit /b 0
