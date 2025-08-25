@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined LVAR set "L=!%LVAR%!"
if defined RVAR set "R=!%RVAR%!"

if not defined LVAR set "L=<undef>"
if not defined RVAR set "R=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;FAILED: !TESTLIB__OVERALL_TESTS!.!TESTLIB__CURRENT_TESTS!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` OP=`!OP!` L=`!L!` R=`!R!`
  echo;
  exit /b 0
)

echo;PASSED: !TESTLIB__OVERALL_TESTS!.!TESTLIB__CURRENT_TESTS!: RET=`!TEST_IMPL_ERROR!` OP=`!OP!` L=`!L!` R=`!R!`

exit /b 0
