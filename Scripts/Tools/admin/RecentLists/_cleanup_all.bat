@echo off

setlocal

rem scripts must run in administrator mode
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /C @%%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b -254
) >&2

:X64
:X32

call "%%~dp0cleanup_windows_shell.bat"
call "%%~dp0cleanup_windows_internal_apps.bat"

call "%%~dp0cleanup_7zip.bat"
call "%%~dp0cleanup_adobe_acrobat_reader.bat"
call "%%~dp0cleanup_araxis_merge.bat"
call "%%~dp0cleanup_mpc_hc.bat"
call "%%~dp0cleanup_totalcmd.bat"

exit /b 0

:CMD
call :CMD_ECHO %%*
echo.^>%*
(
  %*
)
exit /b

:CMD_W_INDENT
call :CMD_ECHO_W_INDENT %%*
(
  %*
)
exit /b

:CMD_ECHO
echo.^>%*
exit /b

:CMD_ECHO_W_INDENT
echo.%CMD_INDENT_STR%^>%*
exit /b
