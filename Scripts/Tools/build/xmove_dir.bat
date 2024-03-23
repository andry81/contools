@echo off

rem USAGE:
rem   xmove_dir.bat <from-path> <to-path> [<xmove-flags>...]

rem Description:
rem   A build pipeline wrapper over `xmove_dir.bat` script with bare flags from
rem   `XMOVE_DIR_CMD_BARE_FLAGS` variable.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/xmove_dir.bat"%%XMOVE_DIR_CMD_BARE_FLAGS%% %%*
set LAST_ERROR=%ERRORLEVEL%

echo.

exit /b %LAST_ERROR%
