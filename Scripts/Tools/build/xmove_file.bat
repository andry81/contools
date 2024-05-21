@echo off

rem USAGE:
rem   xmove_file.bat <from-path> <from-file-pttn> <to-path> [<xmove-flags>...]

rem Description:
rem   A build pipeline wrapper over `xmove_file.bat` script with bare flags
rem   from `XMOVE_FILE_CMD_BARE_FLAGS` variable.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_ROOT%%/std/xmove_file.bat"%%XMOVE_FILE_CMD_BARE_FLAGS%% -- %%*
set LAST_ERROR=%ERRORLEVEL%

if %NO_PRINT_LAST_BLANK_LINE%0 EQU 0 echo.

exit /b %LAST_ERROR%
