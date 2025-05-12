@echo off

setlocal

call "%%~dp0__init__/script_init.bat" %%0 %%* || exit /b
if %IMPL_MODE%0 EQU 0 exit /b

rem allocate system original temporary directory to bypass TEMP variable access pointing a potential Network Drive directory
set "TEMP_DIR=%LOCALAPPDATA%/Temp/%PROJECT_LOG_FILE_NAME_DATE_TIME%.%?~n0%"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%TEMP_DIR%%" >nul || exit /b 255

call :MAIN %%*
set LAST_ERROR=%ERRORLEVEL%

:FREE_TEMP_DIR
rem CAUTION:
rem   We can not completely remove directory from not elevated user if it does
rem   contain an executable has been run at least once from an elevated user.
rem   The system does protection on executable been run as elevated from
rem   removement by not elevated processes.
rem   We have to remove what we can and postpone the rest upon reboot.
rem
rem   NOTE:
rem     To postpone the removement you still must access the registry keys
rem     under an elevated user.
rem
if defined TEMP_DIR rmdir /S /Q "%TEMP_DIR%"

exit /b %LAST_ERROR%

:MAIN
rem script flags
set "FLAG_USE_CALLF_EXECUTABLE="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-use_callf_exe" (
    set "FLAG_USE_CALLF_EXECUTABLE=%~2"
    shift
  ) else (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "CONTOOLS_DIR_TMP=%TEMP_DIR%\contools"

rem copy `callf.exe` into temporary directory to be able to run elevated from a Network Drive
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" "%%CONTOOLS_UTILS_BIN_ROOT%%/contools" callf.exe "%%CONTOOLS_DIR_TMP%%" || exit /b 255

rem NOTE: In the `callf.exe` the backslash character escaping requires only in case of conjunction with the double quote character escaping: `\\\"`.
rem

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%CONTOOLS_DIR_TMP%%/callf.exe" ^
  /elevate{ /no-window }{ /attach-parent-console } ^
  /ret-child-exit /no-subst-pos-vars /no-esc ^
  /ra "%%%%" "%%%%?25%%%%" /v "?25" "%%%%" ^
  /v FLAG_USE_CALLF_EXECUTABLE "%%FLAG_USE_CALLF_EXECUTABLE%%" ^
  /v CONTOOLS_UTILS_BIN_ROOT "%%CONTOOLS_UTILS_BIN_ROOT%%" ^
  /v TEMP_DIR "%%TEMP_DIR%%" ^
  /v QBITTORRENT_EXECUTABLE "%%QBITTORRENT_EXECUTABLE%%" ^
  "${COMSPEC}" "/c \"@\"${?~dp0}.${?~n0}\${?~n0}.update.bat\" {*}\"" %%* || exit /b

rem ...

exit /b 0
