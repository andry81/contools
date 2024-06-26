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
  exit /b 255
) >&2

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist_strict.bat" "%%~3"
set LAST_ERROR=%ERRORLEVEL%

if %LAST_ERROR% NEQ 0 goto EXIT

if not defined XCOPY_FILE_CMD_BARE_FLAGS goto SKIP_XCOPY_FILE_CMD_BARE_FLAGS

set "XCOPY_FILE_CMD_BARE_FLAGS=%XCOPY_FILE_CMD_BARE_FLAGS:"=%"

if not "%XCOPY_FILE_CMD_BARE_FLAGS:~0,1%" == " " set "XCOPY_FILE_CMD_BARE_FLAGS= %XCOPY_FILE_CMD_BARE_FLAGS%"

:SKIP_XCOPY_FILE_CMD_BARE_FLAGS

call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat"%%XCOPY_FILE_CMD_BARE_FLAGS%% -- %%*
set LAST_ERROR=%ERRORLEVEL%

:EXIT
if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo.

exit /b %LAST_ERROR%
