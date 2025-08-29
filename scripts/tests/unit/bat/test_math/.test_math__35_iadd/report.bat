@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined OUTVAR set "OUT=!%OUTVAR%!"
if defined INVAR set "IN=!%INVAR%!"

if not defined OUTVAR set "OUT=<undef>"
if not defined INVAR set "IN=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;FAILED: !TESTLIB__OVERALL_TESTS!.!TESTLIB__CURRENT_TESTS!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` OUTREF=`!OUTREF!` OUT=`!OUT!` IN=`!IN!` VALUE=`!VALUE!`
  echo;
  exit /b 0
)

echo;PASSED: !TESTLIB__OVERALL_TESTS!.!TESTLIB__CURRENT_TESTS!: RET=`!TEST_IMPL_ERROR!` IN=`!IN!` OUT=`!OUT!` VALUE=`!VALUE!`

exit /b 0
