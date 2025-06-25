@echo off

setlocal

set "HASHES_FILE=%~df1"

for /F "usebackq eol=# tokens=1,2,3,* delims=," %%i in ("%HASHES_FILE%") do call :PROCESS_HASH_LINE "%%i" "%%j" "%%k" "%%l"
exit /b

:PROCESS_HASH_LINE
set "FILE_SIZE=%~1"
set "HASH_MD5=%~2"
set "HASH_SHA256=%~3"
set "FILE_PATH=%~4"

if "%FILE_SIZE:~0,1%" == "%%" exit /b 0

echo;%FILE_SIZE%^|%HASH_MD5%^|%HASH_SHA256%^|"%FILE_PATH%"
