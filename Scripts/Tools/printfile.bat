@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script simply outputs text file line by line with expand option.

rem Command arguments:
rem %1 - Path to file with wildcards using.
rem %2 - Flags 1:
rem    -e - Additionally expand each string.

if "%~1" == "" exit /b 65

if "%~2" == "-e" (
  rem If file can't be found, then exit code - 1.
  for /F "usebackq tokens=*" %%f in ("%~1") do call echo.%%f
) else (
  type "%~1"
)
