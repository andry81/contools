@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script runs under UAC promotion using builtin shortcut file.

setlocal

set "TEMP_FILE_SUFFIX=%RANDOM%-%RANDOM%"

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%"
) else set "TEMP_DIR=%TEMP%"

echo.^
 4C 00 00 00 01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46 81 02 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 29 01 14 00 1F 50 E0 4F D0 20 EA 3A 69 10 A2 D8 08 00 2B 30 ^
 30 9D 19 00 2F 5C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 52 00 31 00 00 ^
 00 00 00 00 00 00 00 10 00 57 69 6E 64 6F 77 73 00 3C 00 08 00 04 00 EF BE 00 00 00 00 00 00 00 ^
 00 2A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 57 00 69 00 6E ^
 00 64 00 6F 00 77 00 73 00 00 00 16 00 56 00 31 00 00 00 00 00 00 00 00 00 10 00 53 79 73 74 65 ^
 6D 36 34 00 00 3E 00 08 00 04 00 EF BE 00 00 00 00 00 00 00 00 2A 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 53 00 79 00 73 00 74 00 65 00 6D 00 36 00 34 00 00 ^
 00 18 00 52 00 32 00 00 00 00 00 00 00 00 00 00 00 63 6D 64 2E 65 78 65 00 3C 00 08 00 04 00 EF ^
 BE 00 00 00 00 00 00 00 00 2A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 63 00 6D 00 64 00 2E 00 65 00 78 00 65 00 00 00 16 00 00 00 14 03 00 00 01 00 00 A0 25 ^
 53 79 73 74 65 6D 52 6F 6F 74 25 5C 53 79 73 74 65 6D 36 34 5C 63 6D 64 2E 65 78 65 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 25 00 53 00 79 00 73 00 74 00 65 00 6D 00 52 00 6F 00 6F 00 74 00 25 00 5C 00 53 00 79 ^
 00 73 00 74 00 65 00 6D 00 36 00 34 00 5C 00 63 00 6D 00 64 00 2E 00 65 00 78 00 65 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 05 00 00 A0 24 00 00 00 7F 00 00 00 1C 00 00 00 0B ^
 00 00 A0 04 F4 8B F3 43 1D F2 42 93 05 67 DE 0B 28 FC 23 7F 00 00 00 00 00 00 00 ^
 > "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk.bin" || exit /b 255

"%SystemRoot%\System32\certutil.exe" -f -decodeHex "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk" >nul 2>nul || (
  del /F /Q /A:-D "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk" >nul 2>nul
  exit /b 255
)

call "%%TEMP_DIR%%\cmd-system64-%%TEMP_FILE_SUFFIX%%.lnk" %%*

set LAST_ERROR=%ERRORLEVEL%

del /F /Q /A:-D "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP_DIR%\cmd-system64-%TEMP_FILE_SUFFIX%.lnk" >nul 2>nul

exit /b %LAST_ERROR%
