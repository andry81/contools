@echo off & goto DOC_END

rem Description:
rem   Script installs x86 dependencies into Windows x86 (not x86 on x64).
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

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  "%SystemRoot%\Sysnative\cmd.exe" /c @"%~f0" %*
  exit /b
)

rem x64 is an option to continue

:X64

rem Windows XP
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\cscript.exe" //NOLOGO "%%~dpn0_winxp.vbs" %%*
