@echo off

setlocal EnableDelayedExpansion

for /F "usebackq tokens=1,* delims=:" %%i in (`chcp 2^>nul`) do set LAST_CODE_PAGE=%%j
set LAST_CODE_PAGE=%LAST_CODE_PAGE: =%

chcp 65001 >nul

echo.ArpIp ^<= NsLookupIp ^<= MAC ^(DnsName^)
echo.========================================
for /f "usebackq tokens=1,2,* delims= " %%i in (`arp -a`) do (
    set "host=%%~i"
    set "mac=%%~j"
    if not "!host:~0,1!" == "" if /i not "!host:~0,1!" == "I" (
        set "server="
        for /f "usebackq tokens=1,* delims= " %%x in (`nslookup "!host!" 2^>nul`) do (
            if /i "%%x" == "Server:" (
              set "server=%%y"
            ) else if /i "%%x" == "Name:" (
              set "server=%%y"
            )
            if /i "%%x" == "Address:" (
                echo.!host! ^<= %%y ^<= !mac! ^(!server!^)
                rem resolve NETBIOS name into ip through the ping
                for /f "usebackq tokens=* delims=" %%i in (`ping -w 200 -n 1 "!host!" 2^>nul`) do (
                    set line=%%i
                    if defined line (
                        if /i not "!line:pinging=!" == "!line!" echo.  !line!
                        if /i not "!line:reply=!" == "!line!" echo.  !line!
                    )
                )
                echo.
            )
        )
        echo.----------------------------------------
    )
)

if not "%LAST_CODE_PAGE%" == "65001" chcp %LAST_CODE_PAGE% >nul

pause
