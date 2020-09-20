@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Script remounts Cygwin paths in the registry by path read from "cygwin.vars".
rem To remount Cygwin by this script you should properly set variables
rem "CYGWIN_PATH" and "CYGWIN_REGKEY_PATH" before.

rem Restart shell if x64 mode
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if defined PROCESSOR_ARCHITEW6432 goto NOTX64
"%SystemRoot%\Syswow64\cmd.exe" /C ^(%0 %*^)
exit /b

:NOTX64

rem Drom last error level
type nul>nul

rem Save all variables to stack
setlocal

call "%%~dp0__init__.bat" || exit /b

rem make all paths canonical
call :CANONICAL_PATH CONTOOLS_ROOT "%%CONTOOLS_ROOT%%"
set "CONTOOLS_ROOT=%CONTOOLS_ROOT:/=\%"
set "CONTOOLS_ROOT_NATIVE=%CONTOOLS_ROOT%"

call :CANONICAL_PATH CONFIG_PATH "%%~dp0..\Config"
set "CONFIG_PATH=%CONFIG_PATH:/=\%"

rem Update variables pointing temporary directories
call :CANONICAL_PATH TEMP "%%~dp0..\Temp"
set "TEMP=%TEMP:/=\%"
set "TMP=%TEMP%"

rem Save all variables to stack
setlocal

:CHECK_CMD
call "%%CONTOOLS_ROOT%%\isnativecmd.bat"
if %ERRORLEVEL% NEQ 0 (
  echo %~nx0: error: ^(%ERRORLEVEL%^) Script doesn't support not native Command Interpreter.>&2
  exit /b 1
)

:CHECK_CYGWIN_VARS
rem Load variables from cygwin.vars.
if not exist "%CONFIG_PATH%\cygwin.vars" (
  echo %~nx0: error: "cygwin.vars" not found.>&2
  exit /b 3
)

call "%%CONTOOLS_ROOT%%\setvarsfromfile.bat" "%%CONFIG_PATH%%\cygwin.vars"
rem Replace all "/" characters to "\" characters
set "CYGWIN_PATH=%CYGWIN_PATH:/=\%"
rem remove back slash
if "%CYGWIN_PATH:~-1%" == "\" set "CYGWIN_PATH=%CYGWIN_PATH:~0,-1%"

if not exist "%CYGWIN_PATH%\bin\cygwin?.dll" (
  echo %~nx0: CYGWIN_PATH: "%CYGWIN_PATH%">&2
  echo %~nx0: error: Cygwin installation directory doesn't exist or incorrect.>&2
  exit /b 4
)

rem Run cygcheck to check main cygwin dll version.
call "%%CONTOOLS_ROOT%%\cygver.bat" cygwin "%%CYGWIN_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  echo %~nx0: error: ^(%ERRORLEVEL%^) Failed to run cygcheck utility to detect cygwin dll version.>&2
  exit /b 6
)

set CYGWIN_VER_1_7_X=0
if defined CYGWIN_VER_STR (
  for /F "eol= tokens=1,2,* delims=." %%i in ("%CYGWIN_VER_STR%") do (
    rem If Cygwin version is 1.7 or higher, then no need to check registry installation,
    rem because the Cygwin with version 1.7 and higher implements mingw style of working.
    if %%i0 GTR 10 (
      set CYGWIN_VER_1_7_X=1
    ) else if %%i0 GEQ 10 if %%j0 GEQ 70 (
      set CYGWIN_VER_1_7_X=1
    )
  )
) else (
  echo %~nx0: warning: Cygcheck utility not reported version of cygwin dll, cygwin installation may be corrupted. Continue as Cygwin has 1.6.x version and older.>&2
)

if %CYGWIN_VER_1_7_X% EQU 0 goto REMOUNT_CYGWIN_1_6_X
  rem Nothing needs remount.
  echo %~nx0: info: Remount destination is Cygwin version 1.7.x or higher and doesn't need to be remounted.>&2
  exit /b 7

:REMOUNT_CYGWIN_1_6_X
rem Make remount in the Windows registry.
if not defined CYGWIN_REGKEY_PATH (
  echo %~nx0: error: Variable CYGWIN_REGKEY_PATH doesn't set properly by "cygwin.vars" ^(required for cygwin version 1.6.x and older^).>&2
  exit /b 8
)

rem Replace all "/" characters to "\" characters
set "CYGWIN_REGKEY_PATH=%CYGWIN_REGKEY_PATH:/=\%"
rem remove back slash
if "%CYGWIN_REGKEY_PATH:~-1%" == "\" set "CYGWIN_REGKEY_PATH=%CYGWIN_REGKEY_PATH:~0,-1%"

rem For cygwin versions 1.6.x and older test if cygwin at least was installed.
call "%%CONTOOLS_ROOT%%\regquery.bat" "%%CYGWIN_REGKEY_PATH%%\/" "native"
if %ERRORLEVEL% NEQ 0 (
  echo %~nx0: error: ^(%ERRORLEVEL%^) Cygwin was not installed properly or registry key not found.>&2
  exit /b 9
)

rem Replace all "/" characters to "\" characters
set "__CURRENT_CYGWIN_PATH=%REGQUERY_VALUE:/=\%"

rem Drop last slash/back-slash character.
if "%__CURRENT_CYGWIN_PATH:~-1%" == "\" set "__CURRENT_CYGWIN_PATH=%__CURRENT_CYGWIN_PATH:~0,-1%"

call "%%CONTOOLS_ROOT%%/std/strlen.bat" "" "%%__CURRENT_CYGWIN_PATH%%"
set __CURRENT_CYGWIN_PATH_LEN=%ERRORLEVEL%

call "%%CONTOOLS_ROOT%%/std/strlen.bat" "" "%%CYGWIN_REGKEY_PATH%%"
set __CYGWIN_REGKEY_PATH_LEN=%ERRORLEVEL%
set /A __CYGWIN_REGKEY_PATH_LEN+=1

set __OVERALL_PATHS=0
set __REMOUNTED_PATHS=0

echo Remounting Cygwin installation...
rem Read each subkey of registry key and process it.
for /F "usebackq eol= tokens=*" %%i in (`call "%%CONTOOLS_ROOT%%\regenum.bat" "%%CYGWIN_REGKEY_PATH%%\"`) do (
  if not "%%i" == "" (
    call :PROCESS_CYGWIN_MOUNT_REGKEY "%%i"
  )
)

echo.  %__REMOUNTED_PATHS% of %__OVERALL_PATHS% paths is remounted.

goto EXIT

:PROCESS_CYGWIN_MOUNT_REGKEY
rem Ignore root path, because it is path to registry key.
set "__VALUE=%~1"
call set "__VALUE=%%__VALUE:~%__CYGWIN_REGKEY_PATH_LEN%%%"
if not defined __VALUE exit /b
if "%__VALUE%" == "~%__CYGWIN_REGKEY_PATH_LEN%" exit /b

set /A __OVERALL_PATHS+=1
call "%%CONTOOLS_ROOT%%\regquery.bat" "%%CYGWIN_REGKEY_PATH%%\%%__VALUE%%" "native"
rem Ignore empty mounts.
if %ERRORLEVEL% NEQ 0 exit /b

call set "__VALUE2_1=%%REGQUERY_VALUE:~0,%__CURRENT_CYGWIN_PATH_LEN%%%"
call set "__VALUE2_2=%%REGQUERY_VALUE:~%__CURRENT_CYGWIN_PATH_LEN%%%"

rem Replace all "/" characters to "\" characters
set "__VALUE2_1=%__VALUE2_1:/=\%"

rem Ignore already correct mounts.
if /i "%CYGWIN_PATH%" == "%__VALUE2_1%" exit /b

rem Change only mounts which paths begins from root mount minus drive.
if /i not "%__CURRENT_CYGWIN_PATH:~1%" == "%__VALUE2_1:~1%" exit /b

set "__VALUE2_2_1=%__VALUE2_2:\=/%"
if defined __VALUE2_2 if not "%__VALUE2_2_1:~0,1%" == "/" exit /b

rem Write new value to registry.
reg.exe add "%CYGWIN_REGKEY_PATH%\%__VALUE%" /v "native" /d "%CYGWIN_PATH%%__VALUE2_2%" /f >nul 2>&1
echo %__VALUE% -^> "%CYGWIN_PATH%%__VALUE2_2%"
set /A __REMOUNTED_PATHS+=1

exit /b

:REMOUNT_CYGWIN_1_7_X
rem Make remount in the local /etc/fstab file.
echo %~nx0: warning: /etc/fstab should be manually remounted.>&2

exit /b

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
set "RETURN_VALUE=%~dpf2"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
if "%RETURN_VALUE:~-1%" == "/" set "RETURN_VALUE=%RETURN_VALUE:~0,-1%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0

:EXIT
exit /b 0
