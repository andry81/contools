@echo off & goto DOC_END

rem USEAGE:
rem   get_wmi_class_all_obj_props.vbs.bat [--] <ClassName> [<prop>...]

rem Description:
rem   Gets selected property names and values of all class instances into
rem   `RETURN_VALUES[<index>]["<prop>"]` variables.

rem CAUTION:
rem   The `for %%i in (%*)` statement still can expand the globbing characters
rem   for the files in a current directory. You must avoid them.

rem <ClassName>:
rem   The WMI class name.

rem <prop>:
rem   Property name without globbing characters.
:DOC_END

rem drop return values
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set "RETURN_VALUES[" 2^>nul`) do set "%%i="

setlocal DISABLEDELAYEDEXPANSION

set "?~dp0=%~dp0"

rem script flags
set /A "FLAG_SHIFT=0"

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "--" shift & set /A FLAG_SHIFT+=1

set "CLASS_NAME=%~1" & set /A FLAG_SHIFT+=1

set "CMDLINE_PROPS="
set ARG_INDEX=-1

rem read and skip
for %%i in (%*) do call :COLLECT_PROPS

goto COLLECT_PROPS_END

:COLLECT_PROPS
set /A ARG_INDEX+=1

if %ARG_INDEX% LSS %FLAG_SHIFT% exit /b

for %%# in (:) do set "CMDLINE_PROPS=%CMDLINE_PROPS% %%i"

exit /b

:COLLECT_PROPS_END
set INDEX=-1

rem CAUTION:
rem   `for /F` does not return a command error code
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@"%%?~dp0%%print_wmi_class_all_obj_props.vbs.bat" %*`) do call :PROCESS

rem return values, excessive `endlocal` does ignore
for /F "usebackq tokens=1,* delims=="eol^= %%i in (`@set "RETURN_VALUES[" 2^>nul`) do endlocal & set "%%i=%%j"

set "RETURN_VALUES[" >nul 2>nul && exit /b 0

exit /b 1

:PROCESS
for %%# in (:) do set "NAME=%%i"

if defined NAME if "%NAME:~0,1%" == "[" set /A "INDEX+=1" & exit /b

if defined CMDLINE_PROPS (
  for %%k in (%CMDLINE_PROPS%) do if "%%k" == "%%i" set "RETURN_VALUES[%INDEX%]["%%i"]=%%j"
) else for %%# in (:) do set "RETURN_VALUES[%INDEX%]["%%i"]=%%j"
