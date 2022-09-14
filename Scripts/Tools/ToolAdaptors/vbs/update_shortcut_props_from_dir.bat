@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%*

for %%i in (CONTOOLS_ROOT CONTOOLS_UTILITIES_BIN_ROOT) do (
  if not defined %%i (
    echo.%~nx0: error: `%%i` variable is not defined.
    exit /b 255
  ) >&2
)

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

set "INIT_VARS_FILE=%PROJECT_LOG_DIR%\init.vars"

rem register all environment variables
set 2>nul > "%INIT_VARS_FILE%"

rem variables escaping
set "?~f0=%?~f0:{=\{%"
set "COMSPECLNK=%COMSPEC:{=\{%"

"%CONTOOLS_UTILITIES_BIN_ROOT%/contools/callf.exe" ^
  /ret-child-exit /pause-on-exit /tee-stdout "%PROJECT_LOG_FILE%" /tee-stderr-dup 1 ^
  /no-subst-pos-vars ^
  /v IMPL_MODE 1 /v INIT_VARS_FILE "%INIT_VARS_FILE%" ^
  /ra "%%" "%%?01%%" /v "?01" "%%" ^
  "${COMSPECLNK}" "/c \"@\"${?~f0}\" {*}\"" %* || exit /b

exit /b 0

:IMPL
rem script flags
set RESTORE_LOCALE=0
set "FLAG_CHCP="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-chcp" (
    set "FLAG_CHCP=%~2"
    shift
  ) else (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

rem load initialization environment variables
if defined INIT_VARS_FILE for /F "usebackq eol=# tokens=1,* delims==" %%i in ("%INIT_VARS_FILE%") do set "%%i=%%j"

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%" || (
  echo.%?~nx0%: error: could not allocate temporary directory: "%SCRIPT_TEMP_CURRENT_DIR%"
  set LASTERROR=255
  goto FREE_TEMP_DIR
) >&2

if defined FLAG_CHCP (
  call "%%CONTOOLS_ROOT%%/std/chcp.bat" "%%FLAG_CHCP%%"
  set RESTORE_LOCALE=1
)

call :MAIN %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9
set LASTERROR=%ERRORLEVEL%

rem restore locale
if %RESTORE_LOCALE% NEQ 0 call "%%CONTOOLS_ROOT%%/std/restorecp.bat"

:FREE_TEMP_DIR
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

exit /b %LASTERROR%

:MAIN
rem ex: "TargetPath|Arguments|WorkingDirectory"
set "PROPS_LIST=%~1"
set "LINKS_DIR=%~2"
set "REPLACE_FROM=%~3"
set "REPLACE_TO=%~4"

if not defined PROPS_LIST (
  echo.%~nx0: error: PROPS_LIST is not defined.
  exit /b 255
) >&2

if defined LINKS_DIR if exist "%LINKS_DIR%\" goto LINKS_DIR_EXIST

(
  echo.%~nx0: error: LINKS_DIR does not exist: `%LINKS_DIR%`.
  exit /b 255
) >&2

:LINKS_DIR_EXIST

if not defined REPLACE_FROM (
  echo.%~nx0: error: REPLACE_FROM is not defined.
  exit /b 255
) >&2

if not defined REPLACE_TO (
  echo.%~nx0: error: REPLACE_TO is not defined.
  exit /b 255
) >&2

if "%REPLACE_FROM%" == "%REPLACE_TO%" (
  echo.%~nx0: error: REPLACE_FROM is equal to REPLACE_TO: REPLACE_FROM="%REPLACE_FROM%".
  exit /b 255
) >&2

rem reread CURRENT_CP variable from current code page value
call "%%CONTOOLS_ROOT%%/std/getcp.bat"

rem default props list
if "%PROPS_LIST%" == "." set "PROPS_LIST=TargetPath|WorkingDirectory"

for /F "eol= tokens=* delims=" %%i in ("%LINKS_DIR%\.") do set "LINKS_DIR=%%~fi"

if not "%LINKS_DIR:~-1%" == "\" set "LINKS_DIR=%LINKS_DIR%\"

for /F "usebackq eol= tokens=* delims=" %%i in (`dir /A:-D /B /S /O:N "%LINKS_DIR%*.lnk" 2^>nul`) do (
  set "LINK_FILE_PATH=%%i"
  call :UPDATE_LINK
)

exit /b 0

:UPDATE_LINK
echo."%LINK_FILE_PATH%"

if "%CURRENT_CP%" == "65001" (
  type "%CONTOOLS_ROOT:/=\%\encoding\boms\efbbbf.bin" > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"
) else type nul > "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"

"%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/read_shortcut.vbs" -p "%PROPS_LIST%" -- "%LINK_FILE_PATH%" >> "%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst"

for /F "usebackq eol= tokens=1,* delims==" %%i in ("%SCRIPT_TEMP_CURRENT_DIR%/shortcut_props.lst") do (
  set "PROP_NAME=%%i"
  set "PROP_VALUE=%%j"
  call :UPDATE_SHORTCUT
)

echo.

exit /b

:UPDATE_SHORTCUT
rem skip empty
if not defined PROP_VALUE exit /b 0

rem remove quotes at first
set "PROP_PREV_VALUE=%PROP_VALUE:"=%"

rem remove BOM prefix (CAUTION: byte sequence might be not visible in an editor and not copyable in a text merger)
set "PROP_NAME=%PROP_NAME:﻿=%"

call set "PROP_NEXT_VALUE=%%PROP_PREV_VALUE:%REPLACE_FROM%=%REPLACE_TO%%%"

rem skip on empty change
if "%PROP_NEXT_VALUE%" == "%PROP_PREV_VALUE%" exit /b 0

set "PROP_LINE=%PROP_NAME%=%PROP_NEXT_VALUE%"

call "%%CONTOOLS_ROOT%%/std/echo_var.bat" PROP_LINE

if /i "%PROP_NAME%" == "TargetPath" (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs" -t "%PROP_NEXT_VALUE%" -- "%LINK_FILE_PATH%"
) else if /i "%PROP_NAME%" == "WorkingDirectory" (
  "%SystemRoot%\System32\cscript.exe" //Nologo "%CONTOOLS_TOOL_ADAPTORS_ROOT%/vbs/update_shortcut.vbs" -WD "%PROP_NEXT_VALUE%" -- "%LINK_FILE_PATH%"
)
