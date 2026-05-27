@echo off & goto DOC_END

rem Description:
rem   Script installs x64 dependencies into Windows x64 including WOW64.
rem
rem   NOTE:
rem     In case of Windows XP 64, where 32-bit variant of `chcp.com` is absent,
rem     use `encoding/chcp.bat` as a replacement.
:DOC_END

setlocal

rem call "%%~dp0script_init.bat" %%0 %%* || exit /b
rem if %IMPL_MODE%0 EQU 0 exit /b
rem goto IMPL

call "%%~dp0__init__.bat" || exit /b

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%USERBIN_SCRIPTS_BAT_ROOT%/runas/hta/cmd-admin.bat" /k @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
rem script names call stack, disabled due to self call and partial inheritance (process elevation does not inherit a parent process variables by default)
rem if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"
set "?~=%~nx0"

call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo;%?~%: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64

if not defined PROCESSOR_ARCHITEW6432 (
  echo;%?~%: error: script must be run only for Windows x64.
  exit /b 255
) >&2

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  "%SystemRoot%\Sysnative\cmd.exe" /c @"%~f0" %*
  exit /b
)

rem x64 is a requirement to continue
(
  echo;%?~%: error: run script in 64-bit console ONLY ^(in administrative mode^)!
  exit /b 255
) >&2

:X64

call "%%~dp0install_system64_link.bat"
if %ERRORLEVEL% EQU 0 (
  echo;%?~%: info: installed: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"
) else (
  echo;%?~%: info: installation is cancelled: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"
)

echo;

exit /b 0
