@echo off

rem Description:
rem   Script runs run_msys.bat under UAC promotion.

rem Restart shell if x64 mode
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
"%SystemRoot%\Syswow64\cmd.exe" /C ^(%0 %*^)
exit /b

:NOTX64

rem Create local variable's stack
setlocal

if %UAC_READY%0 EQU 10 goto UAC_READY
if %NO_UAC%0 EQU 10 goto NO_UAC

rem Check windows version and promote UAC if higher than Windows XP
for /F "usebackq eol= tokens=*" %%i in (`ver`) do (
  if not "%%i" == "" (
    set "STDOUT_VALUE=%%i"
    goto PARSE_WINVER
  )
)

rem If can't detect windows version then always try to promote UAC
goto PROMOTE_UAC

:PARSE_WINVER
for /F "eol= tokens=1,* delims=[" %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%j"
)

for /F "eol= tokens=1,* delims= " %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%j"
)

for /F "eol= tokens=1,* delims=]" %%i in ("%STDOUT_VALUE%") do (
  set STDOUT_VALUE=0
  set "STDOUT_VALUE=%%i"
)

for /F "eol= tokens=1,* delims=." %%i in ("%STDOUT_VALUE%") do (
  if %%i0 GTR 50 goto PROMOTE_UAC
)

goto NO_UAC

:PROMOTE_UAC
echo Promoting User Access Permissions...

rem Overwrite existing shortcut to bypass changes over the file made in previous execution
copy /Y "%~dp0..\Config\tmpl\runas_admin.lnk.dat" "%~dp0runas_admin.lnk">nul
if %ERRORLEVEL% NEQ 0 goto PAUSE_AND_EXIT

set UAC_READY=1
call "%%~dp0runas_admin.lnk" /c ^("%%~dp0run_msys.bat" %%*^)
exit /b

:UAC_READY
:NO_UAC
call "%%~dp0run_msys.bat" %%*
exit /b

:PAUSE_AND_EXIT
pause
