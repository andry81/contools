@echo off

set /P "FILE_PATH="

echo.^>TortoiseProc.exe %COMMAND% %* /path:"%FILE_PATH%"
TortoiseProc.exe %COMMAND% %* /path:"%FILE_PATH%"
