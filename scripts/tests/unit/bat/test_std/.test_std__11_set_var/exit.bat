@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_var.bat" "%%LVAR%%" EQU VARREF || exit /b 10
call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" TEST_PREV_ERROR EQU TEST_IMPL_ERROR || exit /b 20

exit /b 0
