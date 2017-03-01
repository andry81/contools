@echo off

if "%NEST_LVL%" == "" set NEST_LVL=0

if %NEST_LVL% GTR 0 exit /b 0

set __PASSED_TESTS=0
set __OVERALL_TESTS=0

set "TOOLS_PATH=%~dp0..\..\Tools"
set "TEST_SRC_BASE_DIR=%~dp0"
set "TEST_SRC_BASE_DIR=%TEST_SRC_BASE_DIR:~0,-1%"
set "TEST_DATA_BASE_DIR=%TEST_SRC_BASE_DIR%\_testdata"
set "TEST_TEMP_BASE_DIR=%TEST_SRC_BASE_DIR%\..\..\Temp"
