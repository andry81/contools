@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

setlocal

call "%%~dp0..\__init__\__init__.bat"

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/cmd_admin.bat" /c @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo.%~nx0: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /c %%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b 255
) >&2

:X64
:X32

set "CMD_QUIET="
set /P "IS_QUIET=Quiet uninstall? [y/N] "
if "%IS_QUIET%" == "y" set "CMD_QUIET=/quiet"

echo Uninstalling KB3068708
wusa.exe /uninstall /kb:3068708 %CMD_QUIET% /norestart
echo Uninstalling KB3022345
wusa.exe /uninstall /kb:3022345 %CMD_QUIET% /norestart
echo Uninstalling KB3075249
wusa.exe /uninstall /kb:3075249 %CMD_QUIET% /norestart
echo Uninstalling KB3080149
wusa.exe /uninstall /kb:3080149 %CMD_QUIET% /norestart
