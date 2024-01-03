@echo off

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -X /pause-on-exit -- %%* || exit /b

exit /b 0

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

rem allocate system original temporary directory to bypass TEMP variable access pointing a potential Network Drive directory
set "TEMP_DIR=%LOCALAPPDATA%/Temp/%PROJECT_LOG_FILE_NAME_SUFFIX%.%?~n0%"

mkdir "%TEMP_DIR%" || exit /b 255

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

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

rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

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
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "EMPTY_DIR_TMP=%TEMP_DIR%\emptydir"
set "CONTOOLS_DIR_TMP=%TEMP_DIR%\contools"

mkdir "%EMPTY_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%EMPTY_DIR_TMP%".
  exit /b 255
) >&2

mkdir "%CONTOOLS_DIR_TMP%" || (
  echo.%?~n0%: error: could not create a directory: "%CONTOOLS_DIR_TMP%".
  exit /b 255
) >&2

rem copy `callf.exe` into temporary directory to be able to run elevated from a Network Drive
call :XCOPY_FILE "%%CONTOOLS_UTILITIES_BIN_ROOT%%/contools" callf.exe "%%CONTOOLS_DIR_TMP%%" || exit /b 255

rem NOTE: In the `callf.exe` the backslash character escaping requires only in case of conjunction with the double quote character escaping: `\\\"`.
rem

call :CMD "%%CONTOOLS_DIR_TMP%%/callf.exe" ^
  /elevate{ /no-window }{ /attach-parent-console } ^
  /ret-child-exit /no-subst-pos-vars /no-esc ^
  /ra "%%%%" "%%%%?01%%%%" /v "?01" "%%%%" ^
  /v FLAG_USE_CALLF_EXECUTABLE "%%FLAG_USE_CALLF_EXECUTABLE%%" ^
  /v CONTOOLS_UTILITIES_BIN_ROOT "%%CONTOOLS_UTILITIES_BIN_ROOT%%" ^
  /v TEMP_DIR "%%TEMP_DIR%%" ^
  /v QBITTORRENT_EXECUTABLE "%%QBITTORRENT_EXECUTABLE%%" ^
  "${COMSPEC}" "/c \"@\"${?~dp0}.${?~n0}\${?~n0}.update.bat\" {*}\"" %%* || exit /b

rem ...

exit /b 0

:CMD
echo.^>%*
(
  %*
)
exit /b

:XCOPY_FILE
if not exist "\\?\%~f3" (
  echo.^>mkdir "%~3"
  call :MAKE_DIR "%%~3" || (
    echo.%?~nx0%: error: could not create a target file directory: "%~3".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%*
exit /b

:XCOPY_DIR
if not exist "\\?\%~f2" (
  echo.^>mkdir "%~2"
  call :MAKE_DIR "%%~2" || (
    echo.%?~nx0%: error: could not create a target directory: "%~2".
    exit /b 255
  ) >&2
  echo.
)
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%*
exit /b

:MAKE_DIR
for /F "eol= tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"

mkdir "%FILE_PATH%" 2>nul || if exist "%SystemRoot%\System32\robocopy.exe" ( "%SystemRoot%\System32\robocopy.exe" /CREATE "%EMPTY_DIR_TMP%" "%FILE_PATH%" >nul ) else type 2>nul || (
  echo.%?~nx0%: error: could not create a target file directory: "%FILE_PATH%".
  exit /b 1
) >&2
exit /b
