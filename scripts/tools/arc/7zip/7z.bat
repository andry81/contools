@echo off & goto DOC_END

rem Description:
rem   7zip wrapper script.
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
rem WORKAROUND: The last slash must be backward otherwise "Unknown algorithm" error will be thrown.
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_7ZIP_ROOT%%\x86\7z.exe" %%* >nul
exit /b

:X64
rem WORKAROUND: The last slash must be backward otherwise "Unknown algorithm" error will be thrown.
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callsub.bat" "%%CONTOOLS_7ZIP_ROOT%%\x64\7z.exe" %%* >nul
exit /b
