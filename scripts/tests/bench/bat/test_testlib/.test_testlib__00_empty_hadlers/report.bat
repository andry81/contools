@echo off

setlocal ENABLEDELAYEDEXPANSION

if !TEST_LAST_ERROR! NEQ 0 (
  echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: ...
  echo;
  exit /b 0
)

echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: ...

exit /b 0
