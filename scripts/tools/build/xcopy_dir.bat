@echo off & goto DOC_END

rem USAGE:
rem   xcopy_dir.bat <from-path> <to-path> [<xcopy-flags>...]

rem Description:
rem   A build pipeline wrapper over `xcopy_dir.bat` script with bare flags from
rem   `XCOPY_DIR_CMD_BARE_FLAGS` variable.
rem
rem   Does support long paths, but can not create `<to-path>` directory.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like builtin `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` builtin variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.
rem
rem   Creates `<to-path>` directory if does not exist.
:DOC_END

setlocal

call "%%~dp0__init__.bat" || exit /b

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%~2" == "" (
  echo;%?~%%: error: target directory is not defined.
  if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;
  exit /b 255
) >&2

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist_strict.bat" "%%~2"
set LAST_ERROR=%ERRORLEVEL%

if %LAST_ERROR% NEQ 0 goto EXIT

if not defined XCOPY_DIR_CMD_BARE_FLAGS goto SKIP_XCOPY_DIR_CMD_BARE_FLAGS

set "XCOPY_DIR_CMD_BARE_FLAGS=%XCOPY_DIR_CMD_BARE_FLAGS:"=%"

if not "%XCOPY_DIR_CMD_BARE_FLAGS:~0,1%" == " " set "XCOPY_DIR_CMD_BARE_FLAGS= %XCOPY_DIR_CMD_BARE_FLAGS%"

:SKIP_XCOPY_DIR_CMD_BARE_FLAGS

call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat"%%XCOPY_DIR_CMD_BARE_FLAGS%% -- %%*
set LAST_ERROR=%ERRORLEVEL%

:EXIT
if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;

exit /b %LAST_ERROR%
