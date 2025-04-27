@echo off

rem USAGE:
rem   xmove_dir.bat <from-path> <to-path> [<xmove-flags>...]

rem Description:
rem   A build pipeline wrapper over `xmove_dir.bat` script with bare flags from
rem   `XMOVE_DIR_CMD_BARE_FLAGS` variable.

setlocal

call "%%~dp0__init__.bat" || exit /b

if not defined XMOVE_DIR_CMD_BARE_FLAGS goto SKIP_XMOVE_DIR_CMD_BARE_FLAGS

set "XMOVE_DIR_CMD_BARE_FLAGS=%XMOVE_DIR_CMD_BARE_FLAGS:"=%"

if not "%XMOVE_DIR_CMD_BARE_FLAGS:~0,1%" == " " set "XMOVE_DIR_CMD_BARE_FLAGS= %XMOVE_DIR_CMD_BARE_FLAGS%"

:SKIP_XMOVE_DIR_CMD_BARE_FLAGS

call "%%CONTOOLS_ROOT%%/std/xmove_dir.bat"%%XMOVE_DIR_CMD_BARE_FLAGS%% -- %%*
set LAST_ERROR=%ERRORLEVEL%

if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo;

exit /b %LAST_ERROR%
