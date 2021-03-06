@echo off

rem Description:
rem   Independent to Windows first display resolution request.

rem CAUTION:
rem   In Windowx XP an elevated call under data protection flag will block the wmic tool!
rem

rem Drop last error level
type nul >nul

rem drop return value
set "RETURN_VALUE="

set "CurrentHorizontalResolution="
set "CurrentVerticalResolution="

for /F "usebackq eol= tokens=1,2 delims==" %%i in (`"%%SystemRoot%%\System32\wbem\wmic.exe" path Win32_VideoController get CurrentHorizontalResolution^,CurrentVerticalResolution /VALUE 2^>nul`) do (
  if "%%i" == "CurrentHorizontalResolution" set "CurrentHorizontalResolution=%%j"
  if "%%i" == "CurrentVerticalResolution" set "CurrentVerticalResolution=%%j"
)
if defined CurrentHorizontalResolution if defined CurrentVerticalResolution set "RETURN_VALUE=%CurrentHorizontalResolution%|%CurrentVerticalResolution%"

if defined RETURN_VALUE ( set "RETURN_VALUE=%RETURN_VALUE%" & exit /b 0 )

exit /b 1
