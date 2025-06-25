@echo off

rem drop return variable
set "GENERATOR_IS_MULTI_CONFIG="

setlocal

call "%%~dp0__init__.bat" || exit /b

set "CMAKE_GENERATOR=%~1"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/check_vars.bat" CMAKE_GENERATOR CONTOOLS_ROOT TACKLELIB_CMAKE_ROOT || exit /b

rem create temporary directory
if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_OUTPUT_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%"
) else set "TEMP_OUTPUT_DIR=%TEMP%\%~n0.%RANDOM%-%RANDOM%"

rem create temporary files to store local context output

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
rem arguments: <out_file_file>

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" cmake -G "%%~1" "-DCMAKE_MODULE_PATH=%%TACKLELIB_CMAKE_ROOT%%" ^
  -P "%%TACKLELIB_CMAKE_ROOT%%/tacklelib/tools/GeneratorIsMulticonfig.cmd.cmake" ^
  --flock "%%TEMP_OUTPUT_DIR%%/lock" "%%TEMP_OUTPUT_DIR%%/var_values.lst" || exit /b

(
  echo;GENERATOR_IS_MULTI_CONFIG
) > "%TEMP_OUTPUT_DIR%/var_names.lst" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_ROOT%%/std/set_vars_from_locked_file_pair.bat" ^
  "%%TEMP_OUTPUT_DIR%%/lock" "%%TEMP_OUTPUT_DIR%%/var_names.lst" "%%TEMP_OUTPUT_DIR%%/var_values.lst" ^
  "%%PRINT_VARS_SET%%" || exit /b

exit /b 0
