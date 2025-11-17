@echo off

call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" TEST_IMPL_ERROR EQU ARGS_COUNT_REFERENCE || exit /b 10

exit /b 0
