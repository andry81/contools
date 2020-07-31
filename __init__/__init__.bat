@echo off

if /i "%CONTOOLS_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined PROJECT_ROOT       call :CANONICAL_PATH PROJECT_ROOT       "%%~dp0.."
if not defined CONTOOLS_ROOT      call :CANONICAL_PATH CONTOOLS_ROOT      "%%PROJECT_ROOT%%/Scripts/Tools"
if not defined UTILITIES_ROOT     call :CANONICAL_PATH UTILITIES_ROOT     "%%PROJECT_ROOT%%/Utilities"
if not defined UTILITY_ROOT       call :CANONICAL_PATH UTILITY_ROOT       "%%UTILITIES_ROOT%%/bin"
if not defined BUILD_TOOLS_ROOT   call :CANONICAL_PATH BUILD_TOOLS_ROOT   "%%CONTOOLS_ROOT%%/build"
if not defined GNUWIN32_ROOT      call :CANONICAL_PATH GNUWIN32_ROOT      "%%CONTOOLS_ROOT%%/gnuwin32"
if not defined SVNCMD_TOOLS_ROOT  call :CANONICAL_PATH SVNCMD_TOOLS_ROOT  "%%CONTOOLS_ROOT%%/scm/svn"
if not defined SQLITE_TOOLS_ROOT  call :CANONICAL_PATH SQLITE_TOOLS_ROOT  "%%CONTOOLS_ROOT%%/sqlite"
if not defined TESTLIB_ROOT       call :CANONICAL_PATH TESTLIB_ROOT       "%%CONTOOLS_ROOT%%/testlib"
if not defined XML_TOOLS_ROOT     call :CANONICAL_PATH XML_TOOLS_ROOT     "%%CONTOOLS_ROOT%%/xml"
if not defined HASHDEEP_ROOT      call :CANONICAL_PATH HASHDEEP_ROOT      "%%CONTOOLS_ROOT%%/hash/hashdeep"
if not defined VARS_ROOT          call :CANONICAL_PATH VARS_ROOT          "%%CONTOOLS_ROOT%%/vars"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
set "RETURN_VALUE=%~dpf2"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
if "%RETURN_VALUE:~-1%" == "/" set "RETURN_VALUE=%RETURN_VALUE:~0,-1%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
