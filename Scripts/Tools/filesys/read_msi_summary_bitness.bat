@echo off

rem Description:
rem   Script detects MSI binary file bitness.
rem   OS: Windows XP+

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq eol= tokens=1,* delims=;" %%i in (`@"%%SystemRoot%%\System32\cscript.exe" //nologo "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_msi_summary_template.vbs" %*`) do set "RETURN_VALUE=%%i"

if not defined RETURN_VALUE set "RETURN_VALUE=."

if not "%RETURN_VALUE:*64=%" == "%RETURN_VALUE%" (
  set "RETURN_VALUE=64"
) else set "RETURN_VALUE=32"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
  exit /b 0
)
