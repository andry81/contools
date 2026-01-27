@echo off & goto DOC_END

rem Description:
rem   ugrep wrapper script.
:DOC_END

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

rem use 64-bit application in 64-bit OS
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
goto X64

:NOTX64
if %TOOLS_VERBOSE%0 NEQ 0 (
  echo;^>^>"%CONTOOLS_UGREP_ROOT%\bin\win32\ugrep.exe" %*
  echo;
)
"%CONTOOLS_UGREP_ROOT%\bin\win32\ugrep.exe" %*

exit /b

:X64
if %TOOLS_VERBOSE%0 NEQ 0 (
  echo;^>^>"%CONTOOLS_UGREP_ROOT%\bin\win64\ugrep.exe" %*
  echo;
)
"%CONTOOLS_UGREP_ROOT%\bin\win64\ugrep.exe" %*

exit /b
