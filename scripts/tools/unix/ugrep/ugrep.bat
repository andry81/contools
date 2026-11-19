@echo off & goto DOC_END

rem Description:
rem   ugrep wrapper script.
:DOC_END

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if not defined PROCESSOR_ARCHITECTURE (
  echo;%~nx0: error: PROCESSOR_ARCHITECTURE is not defined.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if not "%PROCESSOR_ARCHITECTURE:64=%" == "%PROCESSOR_ARCHITECTURE%" goto X64

:NOTX64
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_UGREP_ROOT%%\bin\win32\ugrep.exe" %%*
exit /b

:X64
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_UGREP_ROOT%%\bin\win64\ugrep.exe" %%*
exit /b
