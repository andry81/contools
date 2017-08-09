@echo off

setlocal

set /P USE_PROXY=Use proxy [Y/n] ^>
if not defined USE_PROXY set USE_PROXY=1
if "%USE_PROXY%" == "y" set USE_PROXY=1
if not "%USE_PROXY%" == "1" set USE_PROXY=0

set PROXY_SERVER=
set PROXY_USER=
set PROXY_PASS=

if %USE_PROXY% EQU 0 goto PROXY_END
set /P PROXY_SERVER=Enter proxy server ^(format: ^<ip/name^>:^<port^>^) ^>
set /P PROXY_USER=Enter proxy user [default: not set] ^>
set /P PROXY_PASS=Enter proxy password [default: not set] ^>

:PROXY_END
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d %USE_PROXY% /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "%PROXY_SERVER%" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyUser /t REG_SZ /d "%PROXY_USER%" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyPass /t REG_SZ /d "%PROXY_PASS%" /f
