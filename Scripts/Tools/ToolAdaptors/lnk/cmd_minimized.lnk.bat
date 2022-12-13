@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script runs under UAC promotion using builtin shortcut file.

setlocal

set "TEMP_FILE_SUFFIX=%RANDOM%-%RANDOM%"

echo.^
 4C 00 00 00 01 14 02 00 00 00 00 00 C0 00 00 00 00 00 00 46 81 02 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 29 01 14 00 1F 50 E0 4F D0 20 EA 3A 69 10 A2 D8 08 00 2B 30 ^
 30 9D 19 00 2F 5C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 52 00 31 00 00 ^
 00 00 00 00 00 00 00 10 00 57 69 6E 64 6F 77 73 00 3C 00 08 00 04 00 EF BE 00 00 00 00 00 00 00 ^
 00 2A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 57 00 69 00 6E ^
 00 64 00 6F 00 77 00 73 00 00 00 16 00 56 00 31 00 00 00 00 00 00 00 00 00 10 00 73 79 73 74 65 ^
 6D 33 32 00 00 3E 00 08 00 04 00 EF BE 00 00 00 00 00 00 00 00 2A 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 73 00 79 00 73 00 74 00 65 00 6D 00 33 00 32 00 00 ^
 00 18 00 52 00 32 00 00 00 00 00 00 00 00 00 00 00 63 6D 64 2E 65 78 65 00 3C 00 08 00 04 00 EF ^
 BE 00 00 00 00 00 00 00 00 2A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 63 00 6D 00 64 00 2E 00 65 00 78 00 65 00 00 00 16 00 00 00 14 03 00 00 01 00 00 A2 22 ^
 25 43 4F 4D 53 50 45 43 25 22 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 22 00 25 00 43 00 4F 00 4D 00 53 00 50 00 45 00 43 00 25 00 22 00 00 00 00 00 00 00 00 ^
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
 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ^
 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 05 00 00 A0 25 00 00 00 D5 00 00 00 1C 00 00 00 0B ^
 00 00 A0 77 4E C1 1A E7 02 5D 4E B7 44 2E B1 AE 51 98 B7 D5 00 00 00 00 00 00 00 ^
 > "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk.bin" || exit /b 255

certutil -f -decodeHex "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk" 2>&1 >nul || (
  del /f /q "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk" 2>&1 >nul
  exit /b 255
)

call "%%TEMP%%\cmd-minimized-%%TEMP_FILE_SUFFIX%%.lnk" %%*

set LAST_ERROR=%ERRORLEVEL%

del /f /q "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk.bin" "%TEMP%\cmd-minimized-%TEMP_FILE_SUFFIX%.lnk" 2>&1 >nul

exit /b %LAST_ERROR%