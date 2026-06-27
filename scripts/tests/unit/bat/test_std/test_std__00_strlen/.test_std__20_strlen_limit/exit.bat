@echo off

if not defined STRING_VAR set STRING_VAR=__STRING__

call "%%CONTOOLS_ROOT%%/std/cmp_nvar.bat" STRING_LEN EQU TEST_IMPL_ERROR || exit /b 10

exit /b 0
