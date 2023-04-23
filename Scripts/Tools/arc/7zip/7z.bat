@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   7zip wrapper script.

rem Drop last error level
call;

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

rem use 64-bit application in 64-bit OS
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
goto X64

:NOTX64
rem WORKAROUND: The last slash must be backward otherwise "Unknown algorithm" error will be thrown.
if %TOOLS_VERBOSE%0 NEQ 0 (
  echo.^>^>"%CONTOOLS_7ZIP_ROOT%\x86\7z.exe" %*
  echo.
)
"%CONTOOLS_7ZIP_ROOT%\x86\7z.exe" %* > nul

exit /b

:X64
rem WORKAROUND: The last slash must be backward otherwise "Unknown algorithm" error will be thrown.
if %TOOLS_VERBOSE%0 NEQ 0 (
  echo.^>^>"%CONTOOLS_7ZIP_ROOT%\x64\7z.exe" %*
  echo.
)
"%CONTOOLS_7ZIP_ROOT%\x64\7z.exe" %* > nul

exit /b
