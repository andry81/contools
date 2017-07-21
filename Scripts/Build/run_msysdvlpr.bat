@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Script checks and prepare Msys environment to run Msys login in it.
rem Msys parameters reads from "msysdvlpr.vars".

rem Mingw doesn't need to install, so we doesn't need to check it correctness.

rem Restart shell if x64 mode
if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem To avoid potential recursion in case of wrong PROCESSOR_ARCHITECTURE value
if not "%PROCESSOR_ARCHITEW6432%" == "" goto NOTX64
"%SystemRoot%\Syswow64\cmd.exe" /C ^(%0 %*^)
goto :EOF

:NOTX64

rem Drop last error level
cd .

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
if not %ERRORLEVEL% GEQ 0 goto CHECK_MSYS_VARS

call "%%CONTOOLS_ROOT_NATIVE%%\stresc.bat" /v __STRING__ STRING_ESCAPED __CHARS__ {EC} {#}
call :cecho %%~nx0: {0C}error{#}: {0C}Path to the script has incorrect characters{#}: ^^^"%%STRING_ESCAPED%%^".>&2
exit /b 2

:CHECK_MSYS_VARS
rem Load variables from msysdvlpr.vars
if not exist "%CONFIG_PATH%\msysdvlpr.vars" (
  call :cecho %%~nx0: {0C}error{#}: {0C}"msysdvlpr.vars" not found.>&2
  exit /b 3
)

call "%%CONTOOLS_ROOT%%\setvarsfromfile.bat" "%%CONFIG_PATH%%\msysdvlpr.vars"
rem Replace all "/" characters to "\" characters
set "MSYS_PATH=%MSYS_PATH:/=\%"
rem remove back slash
if "%MSYS_PATH:~-1%" == "\" set "MSYS_PATH=%MSYS_PATH:~0,-1%"


if not exist "%MSYS_PATH%\bin\msys-?.?.dll" (
  call :cecho %%~nx0: {0F}MSYS_PATH{#}: "{0F}%%MSYS_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}Msys installation directory doesn't exist or incorrect.>&2
  exit /b 4
)

if not exist "%MINGW_PATH%\bin\mingwm??.dll" (
  call :cecho %%~nx0: {0F}MINGW_PATH{#}: "{0F}%%MINGW_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}Mingw installation directory doesn't exist or incorrect.>&2
  exit /b 5
)

if not exist "%MSYS_PATH%\msys.bat" (
  call :cecho %%~nx0: {0F}MSYS_PATH{#}: "{0F}%%MSYS_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: {0C}startup batch file doesn't exist or incorrect.>&2
  exit /b 6
)

rem Check main msys dll version.
call "%%CONTOOLS_ROOT%%\msysver.bat" msys "%%MSYS_PATH%%"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Failed to run uname utility to detect msys dll version.>&2
  exit /b 7
)

title Msysdvlpr v%MSYS_VER_STR% - %MSYS_PATH%

call :cecho %%~nx0: {0B}info{#}: {0B}Msys dll version{#}: {0F}%%MSYS_VER_STR%%{#}.

if /i not "%MSYS_PATH:~0,1%:" == "%~d0" (
  call :cecho %%~nx0: {0B}info{#}: {0B}Msys running from different drive{#}: "{0F}%%MSYS_PATH%%{#}", current drive: "{0F}%%~d0{#}".
)

:PREPARE_MSYS_ENV
if not exist "%TEMP%" mkdir "%TEMP%"

echo %~nx0: Unmounting backend directories...

rem Unmount mount points that can potentially interfere with the backend
"%MSYS_PATH%\bin\bash" "%CONTOOLS_ROOT%/unmountdir.sh" "/usr/local"
if %ERRORLEVEL% EQU 0 echo /usr/local

"%MSYS_PATH%\bin\bash" "%CONTOOLS_ROOT%/unmountdir.sh" "/usr"
if %ERRORLEVEL% EQU 0 echo /usr

echo.

echo %~nx0: Mounting local directories...

"%MSYS_PATH%\bin\bash" "%CONTOOLS_ROOT%/mountdir.sh" "%TMP%" "/tmp"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Couldn't mount /tmp directory.>&2
  call :cecho %%~nx0: {0F}/tmp{#}: "{0F}%%TMP%%{#}">&2
  exit /b 14
)
echo "%TMP%" "/tmp"

"%MSYS_PATH%\bin\bash" "%CONTOOLS_ROOT%/mountdir.sh" "%MINGW_PATH%" "/mingw"
if %ERRORLEVEL% NEQ 0 (
  call :cecho %%~nx0: {0F}MINGW_PATH{#}: "{0F}%%MINGW_PATH%%{#}">&2
  call :cecho %%~nx0: {0C}error{#}: ^^^(%%ERRORLEVEL%%^^^) {0C}Couldn't mount /mingw directory.>&2
  exit /b 15
)
echo "%MINGW_PATH%" "/mingw"

echo.

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
  set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"
  set "MSYS_PATH=%MSYS_PATH%"
  set "MINGW_PATH=%MINGW_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win2k.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%MSYS_PATH%%" "%%MINGW_PATH%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WINXP
endlocal&& (
  set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"
  set "MSYS_PATH=%MSYS_PATH%"
  set "MINGW_PATH=%MINGW_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_winxp.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%MSYS_PATH%%" "%%MINGW_PATH%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WINVISTA
endlocal&& (
  set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"
  set "MSYS_PATH=%MSYS_PATH%"
  set "MINGW_PATH=%MINGW_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_vista.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%MSYS_PATH%%" "%%MINGW_PATH%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WIN7
endlocal&& (
  set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"
  set "MSYS_PATH=%MSYS_PATH%"
  set "MINGW_PATH=%MINGW_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win7.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%MSYS_PATH%%" "%%MINGW_PATH%%"
)
goto :EOF

:CLEAN_AND_RESET_ENV_AND_CALL_WIN8
endlocal&& (
  set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"
  set "MSYS_PATH=%MSYS_PATH%"
  set "MINGW_PATH=%MINGW_PATH%"
  set "CONFIG_PATH=%CONFIG_PATH%"

  call :RESET_ENV_AND_CALL vars_win8.lst "%%CONTOOLS_ROOT_NATIVE%%" "%%CONFIG_PATH%%" "%%MSYS_PATH%%" "%%MINGW_PATH%%"
)
goto :EOF

:RESET_ENV_AND_CALL
rem Reset environment
echo %~nx0: Resetting environment to defaults...
call "%%CONTOOLS_ROOT_NATIVE%%\resetenv.bat" -p -e "%%~3\env\%%~1"

rem Return variables
set "OLDPATH=%PATH%"
set "CONTOOLS_ROOT_NATIVE=%~2"
set "TEMP=%TEMP%"
set "TMP=%TMP%"
set "CONTOOLS_ROOT=%CONTOOLS_ROOT%"

call :cecho %%~nx0: {0B}info{#}: "{0F}PATH=%%PATH%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}TEMP=%%TEMP%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}TMP=%%TMP%%{#}"
call :cecho %%~nx0: {0B}info{#}: "{0F}CONTOOLS_ROOT=%%CONTOOLS_ROOT%%{#}"
echo.

call :RUN_SHELL %%4
goto :EOF

:RUN_SHELL
rem Drop last error level before the last call
cd .

echo.^
call "%%~1\msys.bat" --norxvt MSYS

rem Environment will be restored automatically here
goto :EOF

:cecho
if exist "%CONTOOLS_ROOT_NATIVE%\cecho.exe" (
  "%CONTOOLS_ROOT_NATIVE%\cecho.exe" %*{#}{\n}
) else (
  echo.%*
)
goto :EOF
