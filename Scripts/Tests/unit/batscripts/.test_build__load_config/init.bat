@echo off

set "CONFIG_FILE=%~1"
set "TEST_VAR_NAME_PREFIX=%~2"
set "REFERENCE_VAR_NAME_PREFIX=%~3"
shift
shift
shift

set "TEST_VAR_NAME_SUFFIX_LIST="

:READ_TEST_VAR_NAME_SUFFIX_LOOP
set "TEST_VAR_NAME_SUFFIX=%~1"
if not defined TEST_VAR_NAME_SUFFIX goto READ_TEST_VAR_NAME_SUFFIX_LOOP_END
set "TEST_VAR_NAME_SUFFIX_LIST=%TEST_VAR_NAME_SUFFIX_LIST% %TEST_VAR_NAME_SUFFIX%"
shift
goto READ_TEST_VAR_NAME_SUFFIX_LOOP

:READ_TEST_VAR_NAME_SUFFIX_LOOP_END
pushd "%TEST_DATA_BASE_DIR%/test_build__load_config"

exit /b 0