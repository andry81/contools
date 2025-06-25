@echo off & goto DOC_END

rem Description:
rem   Script detects MSI binary file bitness.
rem   OS: Windows XP+
:DOC_END

rem drop return value
set "RETURN_VALUE="

setlocal

call "%%~dp0__init__.bat" || exit /b

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=1,* delims=;"eol^= %%i in (`@"%%SystemRoot%%\System32\cscript.exe" //nologo "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/vbs/read_msi_summary_template.vbs" %*`) do set "RETURN_VALUE=%%i"

if not defined RETURN_VALUE set "RETURN_VALUE=."

if not "%RETURN_VALUE:*64=%" == "%RETURN_VALUE%" (
  set "RETURN_VALUE=64"
) else set "RETURN_VALUE=32"

(
  endlocal
  set "RETURN_VALUE=%RETURN_VALUE%"
  exit /b 0
)
