@echo off

if "%__NEST_LVL%" == "" set __NEST_LVL=0

if %__NEST_LVL% GTR 0 exit /b 0

set __PASSED_TESTS=0
set __OVERALL_TESTS=0

set "TESTS_ROOT=%~dp0"
set "TESTS_ROOT=%TESTS_ROOT:\=/%"
if "%TESTS_ROOT:~-1%" == "/" set "TESTS_ROOT=%TESTS_ROOT:~0,-1%"

if "%CONTOOLS_ROOT%" == "" set "CONTOOLS_ROOT=%~dp0..\..\tools"
set "CONTOOLS_ROOT=%CONTOOLS_ROOT:\=/%"
if "%CONTOOLS_ROOT:~-1%" == "/" set "CONTOOLS_ROOT=%CONTOOLS_ROOT:~0,-1%"

if "%GNUWIN32_ROOT%" == "" set "GNUWIN32_ROOT=%CONTOOLS_ROOT%/gnuwin32"
set "GNUWIN32_ROOT=%GNUWIN32_ROOT:\=/%"
if "%GNUWIN32_ROOT:~-1%" == "/" set "GNUWIN32_ROOT=%GNUWIN32_ROOT:~0,-1%"

if "%SVNCMD_TOOLS_ROOT%" == "" set "SVNCMD_TOOLS_ROOT=%CONTOOLS_ROOT%/scm/svn"
set "SVNCMD_TOOLS_ROOT=%SVNCMD_TOOLS_ROOT:\=/%"
if "%SVNCMD_TOOLS_ROOT:~-1%" == "/" set "SVNCMD_TOOLS_ROOT=%SVNCMD_TOOLS_ROOT:~0,-1%"

if "%XML_TOOLS_ROOT%" == "" set "XML_TOOLS_ROOT=%CONTOOLS_ROOT%/xml"
set "XML_TOOLS_ROOT=%XML_TOOLS_ROOT:\=/%"
if "%XML_TOOLS_ROOT:~-1%" == "/" set "XML_TOOLS_ROOT=%XML_TOOLS_ROOT:~0,-1%"

if "%VARS_ROOT%" == "" set "VARS_ROOT=%CONTOOLS_ROOT%/vars"
set "VARS_ROOT=%VARS_ROOT:\=/%"
if "%VARS_ROOT:~-1%" == "/" set "VARS_ROOT=%VARS_ROOT:~0,-1%"

set "TEST_SRC_BASE_DIR=%~dp0"
set "TEST_SRC_BASE_DIR=%TEST_SRC_BASE_DIR:~0,-1%"

set "TEST_DATA_BASE_DIR=%TEST_SRC_BASE_DIR%\_testdata"
set "TEST_TEMP_BASE_DIR=%TEST_SRC_BASE_DIR%\..\..\Temp"

call :GET_ABSOLUTE_PATH "%%TEST_DATA_BASE_DIR%%"
set "TEST_DATA_BASE_DIR=%RETURN_VALUE%"

exit /b 0

:GET_ABSOLUTE_PATH
set "RETURN_VALUE=%~dpf1"
exit /b 0

