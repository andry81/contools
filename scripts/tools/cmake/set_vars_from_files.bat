@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CONTOOLS_ROOT TACKLELIB_CMAKE_ROOT || exit /b

rem create temporary directory
if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_OUTPUT_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%"
) else set "TEMP_OUTPUT_DIR=%TEMP%\%~n0.%RANDOM%-%RANDOM%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEMP_OUTPUT_DIR%%" >nul || exit /b -255

rem drop rest variables
endlocal & set "TEMP_OUTPUT_DIR=%TEMP_OUTPUT_DIR:\=/%"

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%TEMP_OUTPUT_DIR%"

(
  set "LAST_ERROR="
  set "TEMP_OUTPUT_DIR="
  exit /b %LAST_ERROR%
)

:MAIN
setlocal
call :SET_FLAGS %%*

endlocal & ^
call :MAIN_IMPL ^
%__SET_VARS_FROM_FILES_FLAGS__% ^
--flock "%%TEMP_OUTPUT_DIR%%/lock" --vars "%%TEMP_OUTPUT_DIR%%/var_names.lst" --values "%%TEMP_OUTPUT_DIR%%/var_values.lst" ^
"%%~1" "%%~2" "%%~3" "%%~4" "%%~5" "%%~6"

exit /b

:SET_FLAGS
set "__SET_VARS_FROM_FILES_FLAGS__="

shift
shift
shift
shift
shift
shift

:FLAGS_LOOP
set "__FLAGS__=%~1"

if not defined __FLAGS__ goto FLAGS_LOOP_END

rem safe set call
setlocal ENABLEDELAYEDEXPANSION & if defined __SET_VARS_FROM_FILES_FLAGS__ (
  for /F "tokens=1,* delims=|"eol^= %%i in ("!__SET_VARS_FROM_FILES_FLAGS__!|!__FLAGS__!") do endlocal & set __SET_VARS_FROM_FILES_FLAGS__=%%i "%%j"
) else for /F "tokens=* delims="eol^= %%i in ("!__FLAGS__!") do endlocal & set __SET_VARS_FROM_FILES_FLAGS__="%%i"

shift

goto FLAGS_LOOP

:FLAGS_LOOP_END

if defined __SET_VARS_FROM_FILES_FLAGS__ ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__SET_VARS_FROM_FILES_FLAGS__:%%=%%%%!") do endlocal & set "__SET_VARS_FROM_FILES_FLAGS__=%%i"

rem safe set call
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%i in ("!__SET_VARS_FROM_FILES_FLAGS__!") do endlocal & set "__SET_VARS_FROM_FILES_FLAGS__=%%i"

exit /b 0

:MAIN_IMPL
rem arguments: <flag0>[...<flagN>] "<file0>[...\;<fileN>]" <os_name> <compiler_name> <config_name> <arch_name> <list_separator_char>

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" cmake "-DCMAKE_MODULE_PATH=%%TACKLELIB_CMAKE_ROOT%%" ^
  -P "%%TACKLELIB_CMAKE_ROOT%%/tacklelib/tools/SetVarsFromFiles.cmd.cmake" %%* || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_ROOT%%/std/set_vars_from_locked_file_pair.bat" ^
  "%%TEMP_OUTPUT_DIR%%/lock" "%%TEMP_OUTPUT_DIR%%/var_names.lst" "%%TEMP_OUTPUT_DIR%%/var_values.lst" ^
  "%%PRINT_VARS_SET%%" || exit /b

exit /b 0
