@echo off & goto DOC_END

rem USEAGE:
rem   get_wmi_cpu_get.vbs.bat <prop>...

rem Description:
rem   Gets CPU properties into `RETURN_VALUES[<index>]["<prop>"]` variables.

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

rem <prop>:
rem   Property name without globbing characters.
:DOC_END

rem drop return values
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set "RETURN_VALUES[" 2^>nul`) do set "%%i="

set INDEX=-1

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@"%%SystemRoot%%\System32\cscript.exe" //nologo "%~dp0print_wmi_cpu_get.vbs" 2^>nul`) do call :PROCESS %%*

set "RETURN_VALUES[" >nul 2>nul && exit /b 0

exit /b 1

:PROCESS
for %%# in (:) do set "NAME=%%i"

if "%NAME:~0,1%" == "[" set /A INDEX+=1

for %%k in (%*) do if "%%k" == "%%i" set "RETURN_VALUES[%INDEX%]["%%i"]=%%j"
