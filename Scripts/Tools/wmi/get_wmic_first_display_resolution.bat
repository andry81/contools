@echo off

rem Description:
rem   Independent to Windows first display resolution request.

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool!
rem

rem CAUTION:
rem   The `wmic` executable has an issue with different output codepage:
rem
rem     https://stackoverflow.com/questions/55310573/wmic-command-in-batch-outputting-non-utf-8-text-files/55312341#55312341
rem
rem   The encoding of wmic's output depends on where the output is being sent
rem     * If you send the output to a disk file by using a redirection operator
rem       or the /output switch, wmic will use UCS-2 LE BOM
rem     * If you send the output to the console or to a pipe, wmic will use OEM
rem       codepage
rem

rem drop return value
set "RETURN_VALUE="

rem Drop last error level
call;

setlocal

set "CurrentHorizontalResolution="
set "CurrentVerticalResolution="

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=1,2 delims=="eol^= %%i in (`@"%%SystemRoot%%\System32\wbem\wmic.exe" path Win32_VideoController get CurrentHorizontalResolution^,CurrentVerticalResolution /VALUE 2^>nul`) do (
  if "%%i" == "CurrentHorizontalResolution" set "CurrentHorizontalResolution=%%j"
  if "%%i" == "CurrentVerticalResolution" set "CurrentVerticalResolution=%%j"
)
if defined CurrentHorizontalResolution if defined CurrentVerticalResolution set "RETURN_VALUE=%CurrentHorizontalResolution%|%CurrentVerticalResolution%"

if defined RETURN_VALUE endlocal & set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0

exit /b 1
