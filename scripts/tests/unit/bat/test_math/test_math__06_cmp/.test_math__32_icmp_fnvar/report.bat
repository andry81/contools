@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined LVAR set "L=!%LVAR%!"
if defined RVAR set "R=!%RVAR%!"

if not defined LVAR set "L=<undef>"
if not defined RVAR set "R=<undef>"

if !TEST_LAST_ERROR! NEQ 0 (
  echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: RETREF=`!RETREF!` RET=`!TEST_IMPL_ERROR!` OP=`!OP!` L=`!L!` R=`!R!`
  echo;
  exit /b 0
)

echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: RET=`!TEST_IMPL_ERROR!` OP=`!OP!` L=`!L!` R=`!R!`

exit /b 0
