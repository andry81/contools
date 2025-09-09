@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined OUTVAR set "OUT=!%OUTVAR%!"
if defined LVAR set "L=!%LVAR%!"

if not defined OUTVAR set "OUT=<undef>"
if not defined LVAR set "L=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;FAILED: !TESTLIB__TEST_ORDER_NUMBER!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` OUTREF=`!OUTREF!` OUT=`!OUT!` L=`!L!` R=`!R!`
  echo;
  exit /b 0
)

echo;PASSED: !TESTLIB__TEST_ORDER_NUMBER!: RET=`!TEST_IMPL_ERROR!` OUT=`!OUT!` L=`!L!` R=`!R!`

exit /b 0
