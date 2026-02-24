@echo off

rem Description:
rem   Script installs x64 dependency the `System64` sub directory symbolic
rem   link.
rem   Requires in case of Windows XP x64, because x32 `chcp.com` is absent
rem   there.

setlocal

call "%%~dp0..\__init__\__init__.bat"

rem script names call stack, disabled due to self call and partial inheritance (process elevation does not inherit a parent process variables by default)
rem if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"
set "?~=%~nx0"

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/cmd_admin.bat" /c @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo;%?~%: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /c @%%0 %%*
  exit /b
)

(
  echo;%?~%: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b 255
) >&2

:X64
:X32

if exist "\\?\%SystemRoot%\System64\*" goto IGNORE_MKLINK_SYSTEM64

call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/install_system64_link.bat"

if not exist "\\?\%SystemRoot%\System64\*" (
  echo;%?~%: error: could not create directory link: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"
  exit /b 255
) >&2

echo;

:IGNORE_MKLINK_SYSTEM64
