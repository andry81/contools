@echo off

setlocal ENABLEDELAYEDEXPANSION

if defined %STRING_VAR% (
  set "STRING=!%STRING_VAR%:~0,5!...!%STRING_VAR%:~-5!"
) else (
  set "STRING_VAR=__STRING__"
  set "STRING="
)

if !TEST_LAST_ERROR! NEQ 0 (
  echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: !TEST_IMPL_ERROR! == !STRING_LEN!: !STRING_VAR!=`!STRING!`
  echo;
  exit /b 0
)

echo;!TESTLIB__TEST_STATUS_MSG!: !TESTLIB__TEST_ORDER_NUMBER!: LEN=`!STRING_LEN!`: !STRING_VAR!=`!STRING!`

exit /b 0
