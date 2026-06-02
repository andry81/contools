@echo off & goto DOC_END

rem CAUTION:
rem   The `set_fileshortname.vbs` script must be a 32-bit process to create `jcb.tools` object.
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

if "%PROCESSOR_ARCHITECTURE%" == "x86" goto X86

if not exist "%SystemRoot%\SysWOW64\*" (
  echo;%?~%: error: not x86 system or without SysWOW64 system directory.
  exit /b 255
) >&2

echo;^>"%SystemRoot%\Syswow64\cscript.exe" //nologo "%~dp0set_fileshortname.vbs" %*
"%SystemRoot%\Syswow64\cscript.exe" //nologo "%~dp0set_fileshortname.vbs" %*
exit /b

:X86
echo;^>"%SystemRoot%\System32\cscript.exe" //nologo "%~dp0set_fileshortname.vbs" %*
"%SystemRoot%\System32\cscript.exe" //nologo "%~dp0set_fileshortname.vbs" %*
