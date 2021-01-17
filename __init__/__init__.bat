@echo off

if /i "%CONTOOLS_PROJECT_ROOT_INIT0_DIR%" == "%~dp0" exit /b 0

set "CONTOOLS_PROJECT_ROOT_INIT0_DIR=%~dp0"

if not defined NEST_LVL set NEST_LVL=0

if not defined CONTOOLS_PROJECT_ROOT              call :CANONICAL_PATH CONTOOLS_PROJECT_ROOT              "%%~dp0.."

if not defined CONTOOLS_ROOT                      call :CANONICAL_PATH CONTOOLS_ROOT                      "%%CONTOOLS_PROJECT_ROOT%%/Scripts/Tools"
if not defined CONTOOLS_BUILD_TOOLS_ROOT          call :CANONICAL_PATH CONTOOLS_BUILD_TOOLS_ROOT          "%%CONTOOLS_ROOT%%/build"
if not defined CONTOOLS_SQLITE_TOOLS_ROOT         call :CANONICAL_PATH CONTOOLS_SQLITE_TOOLS_ROOT         "%%CONTOOLS_ROOT%%/sqlite"
if not defined CONTOOLS_TESTLIB_ROOT              call :CANONICAL_PATH CONTOOLS_TESTLIB_ROOT              "%%CONTOOLS_ROOT%%/testlib"
if not defined CONTOOLS_XML_TOOLS_ROOT            call :CANONICAL_PATH CONTOOLS_XML_TOOLS_ROOT            "%%CONTOOLS_ROOT%%/xml"
if not defined CONTOOLS_VARS_ROOT                 call :CANONICAL_PATH CONTOOLS_VARS_ROOT                 "%%CONTOOLS_ROOT%%/vars"

if not defined SVNCMD_TOOLS_ROOT                  call :CANONICAL_PATH SVNCMD_TOOLS_ROOT                  "%%CONTOOLS_ROOT%%/scm/svn"

if not defined CONTOOLS_UTILITIES_ROOT            call :CANONICAL_PATH CONTOOLS_UTILITIES_ROOT            "%%CONTOOLS_PROJECT_ROOT%%/Utilities"
if not defined CONTOOLS_UTILITIES_BIN_ROOT        call :CANONICAL_PATH CONTOOLS_UTILITIES_BIN_ROOT        "%%CONTOOLS_UTILITIES_ROOT%%/bin"
if not defined CONTOOLS_GNUWIN32_ROOT             call :CANONICAL_PATH CONTOOLS_GNUWIN32_ROOT             "%%CONTOOLS_UTILITIES_BIN_ROOT%%/gnuwin32"
if not defined CONTOOLS_UTILITIES_HASHDEEP_ROOT   call :CANONICAL_PATH CONTOOLS_UTILITIES_HASHDEEP_ROOT   "%%CONTOOLS_UTILITIES_BIN_ROOT%%/hashdeep"
if not defined CONTOOLS_UTILITIES_SQLITE_ROOT     call :CANONICAL_PATH CONTOOLS_UTILITIES_SQLITE_ROOT     "%%CONTOOLS_UTILITIES_BIN_ROOT%%/sqlite"

exit /b 0

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("%~2\.") do set "RETURN_VALUE=%%~fi"
rem set "RETURN_VALUE=%RETURN_VALUE:\=/%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0
