@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined OUTVAR set "OUT=!%OUTVAR%!"
if defined INVAR set "IN=!%INVAR%!"

if not defined OUTVAR set "OUT=<undef>"
if not defined INVAR set "IN=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;FAILED: !TESTLIB__TEST_ORDER_NUMBER!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` OUTREF=`!OUTREF!` OUT=`!OUT!` IN=`!IN!`
  echo;
  exit /b 0
)

echo;PASSED: !TESTLIB__TEST_ORDER_NUMBER!: RET=`!TEST_IMPL_ERROR!` OUT=`!OUT!` IN=`!IN!`

exit /b 0
