@echo off

rem USAGE:
rem   xcopy_dir.bat <from-path> <to-path> [<xcopy-flags>...]

rem Description:
rem   A build pipeline wrapper over `xcopy_dir.bat` script with bare flags from
rem   `XCOPY_DIR_CMD_BARE_FLAGS` variable.
rem
rem   Creates `<to-path>` directory if does not exist.

setlocal

call "%%~dp0__init__.bat" || exit /b

if "%~2" == "" (
  echo.%~nx0%: error: target directory is not defined.
  exit /b 255
) >&2

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist_strict.bat" "%%~2"
set LAST_ERROR=%ERRORLEVEL%

if %LAST_ERROR% NEQ 0 goto EXIT

call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat"%%XCOPY_DIR_CMD_BARE_FLAGS%% -- %%*
set LAST_ERROR=%ERRORLEVEL%

:EXIT
if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo.

exit /b %LAST_ERROR%
