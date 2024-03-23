@echo off

rem USAGE:
rem   xcopy_file.bat <from-path> <from-file-pttn> <to-path> [<xcopy-flags>...]

rem Description:
rem   A build pipeline wrapper over `xcopy_file.bat` script with bare flags
rem   from `XCOPY_FILE_CMD_BARE_FLAGS` variable.
rem
rem   Creates `<to-path>` directory if does not exist.

setlocal

call "%%~dp0__init__.bat" || exit /b

if "%~3" == "" (
  echo.%~nx0%: error: target directory is not defined.
  echo.
  exit /b 255
) >&2

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist_strict.bat" "%%~3"
set LAST_ERROR=%ERRORLEVEL%

if %LAST_ERROR% NEQ 0 goto EXIT

call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat"%%XCOPY_FILE_CMD_BARE_FLAGS%% %%*
set LAST_ERROR=%ERRORLEVEL%

:EXIT
echo.

exit /b %LAST_ERROR%
