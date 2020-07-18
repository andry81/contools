@echo off

if /i "%CONTOOLS_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

call :CANONICAL_PATH CONFIGURE_ROOT     "%%~dp0.."
call :CANONICAL_PATH CONTOOLS_ROOT      "%%CONFIGURE_ROOT%%/Scripts/Tools"
call :CANONICAL_PATH UTILITIES_ROOT     "%%CONFIGURE_ROOT%%/Utilities"
call :CANONICAL_PATH UTILITY_ROOT       "%%UTILITIES_ROOT%%/bin"
call :CANONICAL_PATH BUILD_TOOLS_ROOT   "%%CONTOOLS_ROOT%%/build"
call :CANONICAL_PATH GNUWIN32_ROOT      "%%CONTOOLS_ROOT%%/gnuwin32"
call :CANONICAL_PATH SVNCMD_TOOLS_ROOT  "%%CONTOOLS_ROOT%%/scm/svn"
call :CANONICAL_PATH SQLITE_TOOLS_ROOT  "%%CONTOOLS_ROOT%%/sqlite"
call :CANONICAL_PATH TESTLIB_ROOT       "%%CONTOOLS_ROOT%%/testlib"
call :CANONICAL_PATH XML_TOOLS_ROOT     "%%CONTOOLS_ROOT%%/xml"
call :CANONICAL_PATH HASHDEEP_ROOT      "%%CONTOOLS_ROOT%%/hash/hashdeep"
call :CANONICAL_PATH VARS_ROOT          "%%CONTOOLS_ROOT%%/vars"

exit /b 0

:CANONICAL_PATH
set "%~1=%~dpf2"
call set "%%~1=%%%~1:\=/%%"
exit /b 0
