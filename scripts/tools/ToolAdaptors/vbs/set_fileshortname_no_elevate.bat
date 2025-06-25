@echo off

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\Syswow64\*" (
  echo;%?~%: error: not x86 system without Syswow64 system directory.
  exit /b 255
) >&2

echo;^>cscript.exe //nologo "%~dp0set_fileshortname.vbs" %*
"%SystemRoot%\Syswow64\cscript.exe" //nologo "%~dp0set_fileshortname.vbs" %*
exit /b

:X86
echo;^>cscript.exe //nologo "%~dp0set_fileshortname.vbs" %*
cscript.exe //nologo "%~dp0set_fileshortname.vbs" %*
