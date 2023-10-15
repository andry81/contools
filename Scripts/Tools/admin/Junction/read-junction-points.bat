@echo off

for /F "usebackq eol= tokens=* delims=" %%i in ("%~1") do for /F "usebackq eol= tokens=4,* delims= " %%j in (`dir /A:L "%%i\.." 2^>nul ^| findstr /R /C:"\[.*\]"`) do if "%%~ni" == "%%j" ( set "J=%%k" & call echo.%%i*%%J:~1,-1%%)
