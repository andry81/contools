@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script to set project build time.

setlocal

call "%%~dp0__init__.bat" || exit /b

call "%%CONTOOLS_WMI_ROOT%%\get_wmic_local_datetime.bat"
(
  endlocal
  set "PROJECT_BUILD_DATE=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%"
  set "PROJECT_BUILD_TIME=%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"
)
