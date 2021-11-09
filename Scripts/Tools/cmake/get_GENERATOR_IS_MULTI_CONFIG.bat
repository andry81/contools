@echo off

rem drop return variable
set "GENERATOR_IS_MULTI_CONFIG="

setlocal

set "CMAKE_GENERATOR=%~1"

for %%i in (CMAKE_GENERATOR CONTOOLS_ROOT TACKLELIB_CMAKE_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

rem create temporary directory
call "%%CONTOOLS_ROOT%%\wmi\get_wmic_local_datetime.bat"
set "DATETIME_VALUE=%RETURN_VALUE%"

if not defined DATETIME_VALUE (
  echo.%~nx0: error: could not retrieve a date time value to create unique temporary directory.
  exit /b -128
) >&2

set "DATETIME_VALUE=%DATETIME_VALUE:~0,18%"

set "TEMP_DATE=%DATETIME_VALUE:~0,4%_%DATETIME_VALUE:~4,2%_%DATETIME_VALUE:~6,2%"
set "TEMP_TIME=%DATETIME_VALUE:~8,2%_%DATETIME_VALUE:~10,2%_%DATETIME_VALUE:~12,2%_%DATETIME_VALUE:~15,3%"

set "TEMP_OUTPUT_DIR=%TEMP%\%~n0.%TEMP_DATE%.%TEMP_TIME%"

rem create temporary files to store local context output
if exist "%TEMP_OUTPUT_DIR%\" (
  echo.%~nx0: error: temporary generated directory TEMP_OUTPUT_DIR is already exist: "%TEMP_OUTPUT_DIR%"
  exit /b -255
) >&2

mkdir "%TEMP_OUTPUT_DIR%"

rem drop rest variables
(
  endlocal
  set "TEMP_OUTPUT_DIR=%TEMP_OUTPUT_DIR:\=/%"
)

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%TEMP_OUTPUT_DIR%"

(
  set "LASTERROR="
  set "TEMP_OUTPUT_DIR="
  exit /b %LASTERROR%
)

:MAIN
rem arguments: <out_file_file>

call :CMD cmake -G "%%~1" "-DCMAKE_MODULE_PATH=%%TACKLELIB_CMAKE_ROOT%%" ^
  -P "%%TACKLELIB_CMAKE_ROOT%%/tacklelib/tools/GeneratorIsMulticonfig.cmd.cmake" ^
  --flock "%%TEMP_OUTPUT_DIR%%/lock" "%%TEMP_OUTPUT_DIR%%/var_values.lst" || exit /b

(
  echo.GENERATOR_IS_MULTI_CONFIG
) > "%TEMP_OUTPUT_DIR%/var_names.lst" || exit /b

call :CMD "%%CONTOOLS_ROOT%%/std/set_vars_from_locked_file_pair.bat" ^
  "%%TEMP_OUTPUT_DIR%%/lock" "%%TEMP_OUTPUT_DIR%%/var_names.lst" "%%TEMP_OUTPUT_DIR%%/var_values.lst" ^
  "%%PRINT_VARS_SET%%" || exit /b

exit /b 0

:CMD
if %TOOLS_VERBOSE%0 NEQ 0 (
  echo.^>^>%*
  echo.
)
(
  %*
)
exit /b
