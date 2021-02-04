@echo off

rem Description:
rem   Independent to Windows OS version request.

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool!
rem

rem Drop last error level
type nul >nul

rem drop return value
set "RETURN_VALUE="

for /F "usebackq eol= tokens=1,2 delims==" %%i in (`"%%SystemRoot%%\System32\wbem\wmic.exe" path Win32_OperatingSystem get Version /VALUE 2^>nul`) do if "%%i" == "Version" set "RETURN_VALUE=%%j"

if defined RETURN_VALUE ( set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0 )

exit /b 1
