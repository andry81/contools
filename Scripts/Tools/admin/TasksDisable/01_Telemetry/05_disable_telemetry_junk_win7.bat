@echo off

setlocal

rem related to this article:
rem   `Is there a way to disable the telemetry through some setting(s)?`,
rem   https://superuser.com/questions/972501/how-to-stop-microsoft-from-gathering-telemetry-data-from-windows-7-8-and-8-1/972506#972506
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

wusa /uninstall /kb:3065988 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083325 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083324 %CMD_QUIET% /norestart
wusa /uninstall /kb:2976978 %CMD_QUIET% /norestart
wusa /uninstall /kb:3075853 %CMD_QUIET% /norestart
wusa /uninstall /kb:3065987 %CMD_QUIET% /norestart
wusa /uninstall /kb:3050265 %CMD_QUIET% /norestart
wusa /uninstall /kb:3050267 %CMD_QUIET% /norestart
wusa /uninstall /kb:3075851 %CMD_QUIET% /norestart
wusa /uninstall /kb:2902907 %CMD_QUIET% /norestart
rem https://www.catalog.update.microsoft.com/Search.aspx?q=kb3068708
wusa /uninstall /kb:3068708 %CMD_QUIET% /norestart
wusa /uninstall /kb:3022345 %CMD_QUIET% /norestart
rem https://www.catalog.update.microsoft.com/Search.aspx?q=kb2952664
wusa /uninstall /kb:2952664 %CMD_QUIET% /norestart
wusa /uninstall /kb:2990214 %CMD_QUIET% /norestart
wusa /uninstall /kb:3035583 %CMD_QUIET% /norestart
rem https://www.catalog.update.microsoft.com/Search.aspx?q=kb971033
wusa /uninstall /kb:971033 %CMD_QUIET% /norestart
rem https://www.catalog.update.microsoft.com/Search.aspx?q=kb3021917
wusa /uninstall /kb:3021917 %CMD_QUIET% /norestart
wusa /uninstall /kb:3044374 %CMD_QUIET% /norestart
wusa /uninstall /kb:3046480 %CMD_QUIET% /norestart
wusa /uninstall /kb:3075249 %CMD_QUIET% /norestart
rem https://www.catalog.update.microsoft.com/Search.aspx?q=kb3080149
wusa /uninstall /kb:3080149 %CMD_QUIET% /norestart
wusa /uninstall /kb:2977759 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083710 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083711 %CMD_QUIET% /norestart
wusa /uninstall /kb:3112336 %CMD_QUIET% /norestart
wusa /uninstall /kb:3123862 %CMD_QUIET% /norestart
