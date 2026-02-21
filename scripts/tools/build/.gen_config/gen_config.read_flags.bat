@echo off

rem script flags
set FLAG_SHIFT=0
set FLAG_FLAGS_SCOPE=0
set FLAG_SINGLE=0
set FLAG_IF_NOTEXIST=0
set FLAG_DETECT_EXPIRATION=1
set FLAG_SKIP_CHECKS=0
set FLAG_RE_DELAYED_EXPANSION=0
set FLAG_ESC_DBL_QUOTE=0

set "SED_BARE_FLAGS="
set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

:FLAGS_LOOP

call "%%?~dp0%%.gen_config/gen_config.escape_options.bat" || exit /b

set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-+" set /A FLAG_FLAGS_SCOPE+=1
if defined FLAG if "%FLAG%" == "--" set /A FLAG_FLAGS_SCOPE-=1

if defined FLAG (
  if "%FLAG%" == "-s" (
    set FLAG_SINGLE=1
  ) else if "%FLAG%" == "-if_notexist" (
    set FLAG_IF_NOTEXIST=1
  ) else if "%FLAG%" == "-noexpire" (
    set FLAG_DETECT_EXPIRATION=0
  ) else if "%FLAG%" == "-skip_checks" (
    set FLAG_SKIP_CHECKS=1
  ) else if "%FLAG%" == "-r!+" (
    set FLAG_RE_DELAYED_EXPANSION=1
  ) else if "%FLAG%" == "-r!-" (
    set FLAG_RE_DELAYED_EXPANSION=0
  ) else if "%FLAG%" == "-r" (
    if %FLAG_RE_DELAYED_EXPANSION% NEQ 0 setlocal ENABLEDELAYEDEXPANSION
    set "SED_REPLACE_FROM=%~2"
    set "SED_REPLACE_TO=%~3"
    if %FLAG_RE_DELAYED_EXPANSION% NEQ 0 (
      for /F "usebackq tokens=* delims="eol^= %%i in ('"!SED_REPLACE_FROM!"') do call; ^
      & for /F "usebackq tokens=* delims="eol^= %%j in ('"!SED_REPLACE_TO!"') do endlocal ^
      & set "SED_REPLACE_FROM=%%~i" ^
      & set "SED_REPLACE_TO=%%~j"
    )
    shift
    shift
    set /A FLAG_SHIFT+=2
  ) else if "%FLAG%" == "-rm" (
    if %FLAG_RE_DELAYED_EXPANSION% NEQ 0 setlocal ENABLEDELAYEDEXPANSION
    set "SED_REMOVE_FROM=%~2"
    if %FLAG_RE_DELAYED_EXPANSION% NEQ 0 (
      for /F "usebackq tokens=* delims="eol^= %%i in ('"!SED_REMOVE_FROM!"') do endlocal ^
      & set "SED_REMOVE_FROM=%%~i"
    )
    shift
    set /A FLAG_SHIFT+=1
  ) else if "%FLAG%" == "-esc_dbl_quote" (
    set FLAG_ESC_DBL_QUOTE=1
  ) else if not "%FLAG%" == "-+" if not "%FLAG%" == "--" (
    echo;%?~%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift
  set /A FLAG_SHIFT+=1

  rem read until no flags
  if not "%FLAG%" == "--" goto FLAGS_LOOP

  if %FLAG_FLAGS_SCOPE% GTR 0 goto FLAGS_LOOP
)

if %FLAG_FLAGS_SCOPE% GTR 0 (
  echo;%?~%: error: not ended flags scope: %FLAG_FLAGS_SCOPE%
  exit /b -255
) >&2

exit /b 0
