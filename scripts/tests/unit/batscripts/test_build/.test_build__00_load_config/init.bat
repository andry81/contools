@echo off

set "CONFIG_FILE=%~1"
set "TEST_VAR_NAME_PREFIX=%~2"
set "REFERENCE_VAR_NAME_PREFIX=%~3"

call "%%CONTOOLS_ROOT%%/std/setshift.bat" 3 TEST_VAR_NAME_SUFFIX_LIST %%*

pushd "%TEST_DATA_IN_ROOT%/test_build__00_load_config"

exit /b 0
