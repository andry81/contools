@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Script checks and prepare Cygwin environment to run Cygwin login in it.
rem Cygwin parameters reads from "cygwin.vars".

rem Command arguments:
rem %1 - Flags 1:
rem    -c - (Default) Check if cygwin installation path is the same as path
rem         from "cygwin.vars". Valid only for Cygwin version 1.6.x and older.
rem    -r - Remount Cygwin installation paths to path read from "cygwin.vars".

rem Before run we should check Cygwin version 1.6.x and older for correct
rem installation. To do it we reads registry for installation directory.

rem Restart shell if x64 mode
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if not "%PROCESSOR_ARCHITEW6432%" == "" goto NOTX64
"%SystemRoot%\Syswow64\cmd.exe" /C ^(%0 %*^)
goto :EOF

:NOTX64

rem Drop last error level
type nul>nul

rem Create local variable's stack with disabled of delayed expansion (to avoid ! characters expansion)
setlocal DisableDelayedExpansion

call "%%~dp0__init__.bat" || goto :EOF

rem make all paths canonical
call "%%CONTOOLS_ROOT%%/abspath.bat" "%%CONTOOLS_ROOT%%"
set "CONTOOLS_ROOT=%RETURN_VALUE%"
set "CONTOOLS_ROOT_NATIVE=%RETURN_VALUE%"

call "%%CONTOOLS_ROOT_NATIVE%%\abspath.bat" "%%~dp0..\Config"
set "CONFIG_PATH=%RETURN_VALUE%"

rem Update variables pointing temporary directories
call "%%CONTOOLS_ROOT_NATIVE%%\abspath.bat" "%%~dp0..\Temp"
set "TEMP=%RETURN_VALUE%"
set "TMP=%RETURN_VALUE%"

rem Save all variables to stack again
setlocal

:CHECK_CMD
call "%%CONTOOLS_ROOT_NATIVE%%\isnativecmd.bat"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Script doesn't support not native Command Interpreter.>&2
  exit /b 1
)

rem Check path to this script for invalid characters
set "__STRING__=%~dp0"
set __CHARS__= ^	-^"'`^?^*^&^|^<^>^(^)^^#%%!

call "%%CONTOOLS_ROOT_NATIVE%%\strchr.bat" /v
if not %ERRORLEVEL% GEQ 0 goto CHECK_CYGWIN_VARS

call "%%CONTOOLS_ROOT_NATIVE%%\stresc.bat" /v __STRING__ STRING_ESCAPED __CHARS__ {EC} {#}
call :cecho %%~nx0: {0C}error{#}: {0C}Path to the script has incorrect characters{#}: ^^^"%%STRING_ESCAPED%%^".>&2
exit /b 2

:CHECK_CYGWIN_VARS
rem Load variables from cygwin.vars.
if not exist "%CONFIG_PATH%\cygwin.vars" (
  call :cecho %%~nx0: {0C}error{#}: {0C}"cygwin.vars" not found.>&2
  exit /b 3
)

call "%%CONTOOLS_ROOT_NATIVE%%\setvarsfromfile.bat" "%%CONFIG_PATH%%\cygwin.vars"
rem Replace all "/" characters to "\" characters
set "CYGWIN_PATH=%CYGWIN_PATH:/=\%"
rem remove back slash
if "%CYGWIN_PATH:~-1%" == "\" set "CYGWIN_PATH=%CYGWIN_PATH:~0,-1%"

if not exist "%CYGWIN_PATH%\bin\cygwin?.dll" (
  call :cecho %%~nx0: {0F}CYGWIN_PATH{#}: "{0F}%%CYGWIN_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}Cygwin installation directory doesn't exist or incorrect.>&2
  exit /b 4
)

if not exist "%CYGWIN_PATH%\cygwin.bat" (
  call :cecho %%~nx0: {0F}CYGWIN_PATH{#}: "{0F}%%CYGWIN_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}Cygwin startup batch file doesn't exist or incorrect.>&2
  exit /b 6
)

rem Check main cygwin dll version.
call "%%CONTOOLS_ROOT_NATIVE%%\cygver.bat" cygwin "%%CYGWIN_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Failed to run cygcheck utility to detect cygwin dll version.>&2
  exit /b 7
)

set CYGWIN_VER_1_7_X=0
if not "%CYGWIN_VER_STR%" == "" (
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
  call :cecho %%~nx0: {0C}error{#}: {0C}Couldn't detect cygwin dll version, cygwin installation corrupted.>&2
  exit /b 8
)

title Cygwin v%CYGWIN_VER_STR% - %CYGWIN_PATH%

call :cecho %%~nx0: {0B}info{#}: {0B}Cygwin dll version{#}: {0F}%%CYGWIN_VER_STR%%{#}.

if %CYGWIN_VER_1_7_X% EQU 1 (
  rem Read cygwin drive prefix.
  call :CHECK_CYGWIN_DRIVE
  goto PREPARE_CYGWIN_ENV
)

rem Seems cygwin version is 1.6.x or older (or installation corrupted).
if "%CYGWIN_REGKEY_PATH%" == "" (
  call :cecho %%~nx0: {0C}error{#}: {0C}Variable CYGWIN_REGKEY_PATH doesn't set properly by "cygwin.vars" ^^^(required for cygwin version 1.6.x and older^^^).>&2
  exit /b 8
)

rem Replace all "/" characters to "\" characters
set "CYGWIN_REGKEY_PATH=%CYGWIN_REGKEY_PATH:/=\%"
rem remove back slash
if "%CYGWIN_REGKEY_PATH:~-1%" == "\" set "CYGWIN_REGKEY_PATH=%CYGWIN_REGKEY_PATH:~0,-1%"

if "%~1" == "-r" call :REMOUNT_CYGWIN

rem For cygwin versions 1.6.x and older test if cygwin at least was installed.
call "%%CONTOOLS_ROOT_NATIVE%%\regquery.bat" "%%CYGWIN_REGKEY_PATH%%\/" "native"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Cygwin was not installed properly or registry key not found.>&2
  exit /b 9
)

rem Replace all "/" characters to "\" characters
set "REGQUERY_VALUE=%REGQUERY_VALUE:/=\%"

if /i not "%REGQUERY_VALUE%" == "%CYGWIN_PATH%" (
  call :cecho %%~nx0: {0F}CYGWIN_PATH{#}: "{0F}%%CYGWIN_PATH%%{#}">&2
  call :cecho %%~nx0: {0F}registry key{#}: "{0F}%%CYGWIN_REGKEY_PATH%%\/=%%REGQUERY_VALUE%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}Cygwin is not correctly installed or installed on a different drive. Use flag "-r" to remount Cygwin installation.>&2
  exit /b 10
)

call :CHECK_CYGWIN_DRIVE

goto PREPARE_CYGWIN_ENV

:REMOUNT_CYGWIN
call :cecho %%~nx0: Remounting cygwin installation...
call "%%~dp0remount_cygwin_reg.bat"
if %ERRORLEVEL% EQU 0 (
  call :cecho %%~nx0: {0B}info{#}: {0B}Cygwin mounted{#}: "{0F}%%CYGWIN_PATH%%{#}".
) else (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Cygwin remount failed.>&2
  exit /b 11
)

goto :EOF

:CHECK_CYGWIN_DRIVE
if /i not "%CYGWIN_PATH:~0,1%:" == "%~d0" (
  call :cecho %%~nx0: {0B}info{#}: {0B}Cygwin is running from different drive{#}: "{0F}%%CYGWIN_PATH%%{#}", current drive: "{0F}%%~d0{#}".
)

goto :EOF

:PREPARE_CYGWIN_ENV
if not exist "%TEMP%" mkdir "%TEMP%"

rem Convert all required variables before login into cygwin.
rem Variable PATH will be converted itself automatically on the Cygwin login.

rem Complete path converting
call "%%CONTOOLS_ROOT_NATIVE%%\setvarfromstd.bat" "%%CYGWIN_PATH%%\bin\cygpath.exe" -u "%%TEMP%%"
set "CYGDRIVE_TEMP=%STDOUT_VALUE%"

call "%%CONTOOLS_ROOT_NATIVE%%\setvarfromstd.bat" "%%CYGWIN_PATH%%\bin\cygpath.exe" -u "%%TMP%%"
set "CYGDRIVE_TMP=%STDOUT_VALUE%"

call "%%CONTOOLS_ROOT_NATIVE%%\setvarfromstd.bat" "%%CYGWIN_PATH%%\bin\cygpath.exe" -u "%%CONTOOLS_ROOT%%"
set "CYGDRIVE_CONTOOLS_ROOT=%STDOUT_VALUE%"

rem Update CONTOOLS_ROOT variable for the cygwin shell scripts
set "CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"

echo %~nx0: Unmounting backend directories...

rem Unmount mount points that can potentially interfere with the backend
"%CYGWIN_PATH%\bin\bash" "%CYGDRIVE_CONTOOLS_ROOT%/unmountdir.sh" "/usr/local"
if %ERRORLEVEL% EQU 0 echo /usr/local

"%CYGWIN_PATH%\bin\bash" "%CYGDRIVE_CONTOOLS_ROOT%/unmountdir.sh" "/usr"
if %ERRORLEVEL% EQU 0 echo /usr

echo.

echo %~nx0: Mounting local directories...

if "%CYGDRIVE_TMP%" == "/tmp" goto TMP_MOUNTED

"%CYGWIN_PATH%\bin\bash" "%CYGDRIVE_CONTOOLS_ROOT%/mountdir.sh" "%TMP%" "/tmp"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Couldn't mount /tmp directory.>&2
  call :cecho %%~nx0: {0F}/tmp{#}: "{0F}%%TMP%%{#}">&2
  call :cecho %%~nx0: {0F}hint{#}: {0F}Ensure for the Windows x32 that the registry key "HKEY_LOCAL_MACHINE/SOFTWARE/Cygnus Solutions" has "Full Access" at least for the "Authenticated User(s)".>&2
  call :cecho %%~nx0: {0F}      Ensure for the Windows x64 that the registry key "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node" has "Full Access" at least for the "Authenticated User(s)".>&2
  call :cecho %%~nx0: {0F}      Ensure that all subnodes of the "HKEY_LOCAL_MACHINE/SOFTWARE/Cygnus Solutions" or "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Cygnus Solutions" key has that access rule.>&2
  exit /b 14
)

rem Need to update permission for the /tmp because of remount!
rem "%CYGWIN_PATH%\bin\chmod" 1777 /tmp 2>/dev/null 

:TMP_MOUNTED
echo "%TMP%" "/tmp"

if not exist "%MINGW_PATH%" goto RESTORE_CONTOOLS_ROOT

rem In case if the Mingw binaries used under the Cygwin platform
"%CYGWIN_PATH%\bin\bash" "%CYGDRIVE_CONTOOLS_ROOT%/mountdir.sh" "%MINGW_PATH%" "/mingw"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0F}MINGW_PATH{#}: "{0F}%%MINGW_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Couldn't mount /mingw directory.>&2
  exit /b 15
)
echo "%MINGW_PATH%" "/mingw"

:RESTORE_CONTOOLS_ROOT
echo.

rem Restore CONTOOLS_ROOT variable
set "CONTOOLS_ROOT=%CONTOOLS_ROOT_NATIVE%"

goto :CLEAN_AND_RESET_ENV_AND_CALL1
exit /b 0

:CLEAN_AND_RESET_ENV_AND_CALL1
rem Read windows version
call "%%CONTOOLS_ROOT_NATIVE%%\winver.bat"

rem Reset environment
call "%%CONTOOLS_ROOT_NATIVE%%\setvarfromstd.bat" "%%CONTOOLS_ROOT%%\splitvars.bat" "%%WINVER_VALUE%%" "|" "-s"
if "%STDOUT_VALUE%" == "Windows2000" goto :CLEAN_AND_RESET_ENV_AND_CALL_WIN2K
if "%STDOUT_VALUE%" == "WindowsXP" goto :CLEAN_AND_RESET_ENV_AND_CALL_WINXP
if "%STDOUT_VALUE%" == "WindowsVista" goto :CLEAN_AND_RESET_ENV_AND_CALL_WINVISTA
if "%STDOUT_VALUE%" == "Windows7" goto :CLEAN_AND_RESET_ENV_AND_CALL_WIN7
if "%STDOUT_VALUE%" == "Windows8" goto :CLEAN_AND_RESET_ENV_AND_CALL_WIN8

call :cecho %%~nx0: {0E}warning{#}: {0E}Unsupported Windows version.>&2
goto :CLEAN_AND_RESET_ENV_AND_CALL_WINXP

:CLEAN_AND_RESET_ENV_AND_CALL_WIN2K
endlocal&& (
  set "CYGDRIVE_TEMP=%CYGDRIVE_TEMP%"
  set "CYGDRIVE_TMP=%CYGDRIVE_TMP%"
  set "CYGDRIVE_CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"
  set "CYGWIN_PATH=%CYGWIN_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win2k.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%CYGWIN_PATH%%" "%%CYGDRIVE_TEMP%%" "%%CYGDRIVE_TMP%%" "%%CYGDRIVE_CONTOOLS_ROOT%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WINXP
endlocal&& (
  set "CYGDRIVE_TEMP=%CYGDRIVE_TEMP%"
  set "CYGDRIVE_TMP=%CYGDRIVE_TMP%"
  set "CYGDRIVE_CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"
  set "CYGWIN_PATH=%CYGWIN_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_winxp.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%CYGWIN_PATH%%" "%%CYGDRIVE_TEMP%%" "%%CYGDRIVE_TMP%%" "%%CYGDRIVE_CONTOOLS_ROOT%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WINVISTA
endlocal&& (
  set "CYGDRIVE_TEMP=%CYGDRIVE_TEMP%"
  set "CYGDRIVE_TMP=%CYGDRIVE_TMP%"
  set "CYGDRIVE_CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"
  set "CYGWIN_PATH=%CYGWIN_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_vista.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%CYGWIN_PATH%%" "%%CYGDRIVE_TEMP%%" "%%CYGDRIVE_TMP%%" "%%CYGDRIVE_CONTOOLS_ROOT%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WIN7
endlocal&& (
  set "CYGDRIVE_TEMP=%CYGDRIVE_TEMP%"
  set "CYGDRIVE_TMP=%CYGDRIVE_TMP%"
  set "CYGDRIVE_CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"
  set "CYGWIN_PATH=%CYGWIN_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win7.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%CYGWIN_PATH%%" "%%CYGDRIVE_TEMP%%" "%%CYGDRIVE_TMP%%" "%%CYGDRIVE_CONTOOLS_ROOT%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WIN8
endlocal&& (
  set "CYGDRIVE_TEMP=%CYGDRIVE_TEMP%"
  set "CYGDRIVE_TMP=%CYGDRIVE_TMP%"
  set "CYGDRIVE_CONTOOLS_ROOT=%CYGDRIVE_CONTOOLS_ROOT%"
  set "CYGWIN_PATH=%CYGWIN_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win8.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%CYGWIN_PATH%%" "%%CYGDRIVE_TEMP%%" "%%CYGDRIVE_TMP%%" "%%CYGDRIVE_CONTOOLS_ROOT%%"
)
goto :EOF

:RESET_ENV_AND_CALL
rem Reset environment
echo %~nx0: Resetting environment to defaults...
call "%%CONTOOLS_ROOT_NATIVE%%\resetenv.bat" -p -e "%%~3\env\%%~1"

rem Return variables
set "OLDPATH=%PATH%"
set "CONTOOLS_ROOT_NATIVE=%~2"
set "TEMP=%~5"
set "TMP=%~6"
set "CONTOOLS_ROOT=%~7"

call :cecho %%~nx0: {0B}info{#}: "{0F}PATH=%%PATH%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}TEMP=%%TEMP%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}TMP=%%TMP%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}CONTOOLS_ROOT=%%CONTOOLS_ROOT%%{#}"
echo.

call :RUN_SHELL %%4
goto :EOF

:RUN_SHELL
rem Drop last error level before the last call
type nul>nul

echo.^
call "%%~1\cygwin.bat"

rem Environment will be restored automatically here
goto :EOF

:cecho
if exist "%CONTOOLS_ROOT_NATIVE%\cecho.exe" (
  "%CONTOOLS_ROOT_NATIVE%\cecho.exe" %*{#}{\n}
) else (
  echo.%*
)
goto :EOF
