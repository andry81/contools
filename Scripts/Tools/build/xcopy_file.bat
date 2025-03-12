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

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%~3" == "" (
  echo.%?~%%: error: target directory is not defined.
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
