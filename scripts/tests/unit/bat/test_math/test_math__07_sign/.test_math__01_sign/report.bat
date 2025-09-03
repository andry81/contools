@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined LVAR set "L=!%LVAR%!"

if not defined LVAR set "L=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;FAILED: !TESTLIB__TEST_ORDER_NUMBER!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` L=`!L!`
  echo;
  exit /b 0
)

echo;PASSED: !TESTLIB__TEST_ORDER_NUMBER!: RET=`!TEST_IMPL_ERROR!` L=`!L!`

exit /b 0
