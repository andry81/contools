@echo off

rem script flags
set FLAG_SHIFT=0
set FLAG_FLAGS_SCOPE=0
set HAS_SED_FLAGS=0
set "GEN_CONFIG_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG if "%FLAG%" == "-+" set /A FLAG_FLAGS_SCOPE+=1
if defined FLAG if "%FLAG%" == "--" set /A FLAG_FLAGS_SCOPE-=1

if defined FLAG (
  if "%FLAG%" == "-if_notexist" (
    set GEN_CONFIG_FLAGS=%GEN_CONFIG_FLAGS% %1
  ) else if "%FLAG%" == "-noexpire" (
    set GEN_CONFIG_FLAGS=%GEN_CONFIG_FLAGS% %1
  ) else if "%FLAG%" == "-r" (
    set GEN_CONFIG_FLAGS=%GEN_CONFIG_FLAGS% -r %2 %3
    set HAS_SED_FLAGS=1
    shift
    shift
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
