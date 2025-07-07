@echo off

rem script flags
set FLAG_SHIFT=0
set FLAG_FLAGS_SCOPE=0
set FLAG_IF_NOTEXIST=0
set FLAG_DETECT_EXPIRATION=1
set FLAG_SKIP_CHECKS=0
set "SED_BARE_FLAGS="
set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

:FLAGS_LOOP

if not defined SED_REPLACE_FROM goto SKIP_SED_REPLACE_FROM

rem TODO: escape *
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:\=\\\%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:/=\/%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:|=\|%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:{=\{%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:}=\}%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:[=\[%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:]=\]%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:(=\(%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:)=\)%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:^=\^%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$=\$%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:.=\.%"

:SKIP_SED_REPLACE_FROM

if not defined SED_REPLACE_TO goto SKIP_SED_REPLACE_TO

set "SED_REPLACE_TO=%SED_REPLACE_TO:\=\\\%"
set "SED_REPLACE_TO=%SED_REPLACE_TO:|=\|%"

:SKIP_SED_REPLACE_TO

if not defined SED_REMOVE_FROM goto SKIP_SED_REMOVE_FROM

set "SED_REMOVE_FROM=%SED_REMOVE_FROM:\=\\\%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:/=\/%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:|=\|%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:{=\{%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:}=\}%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:[=\[%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:]=\]%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:(=\(%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:)=\)%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:^=\^%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$=\$%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:.=\.%"

:SKIP_SED_REMOVE_FROM

rem special `$/<char>` sequence to pass `<char>` character as is (ex: `$/\x22` translates into `\x22` - a quote character)
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$\/\\\=\%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:$/\\\=\%"
if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$\/\\\=\%"

if defined SED_REPLACE_FROM if defined SED_REPLACE_TO set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REPLACE_FROM%|%SED_REPLACE_TO%|mg"
if defined SED_REMOVE_FROM set SED_BARE_FLAGS=%SED_BARE_FLAGS% -e "s|%SED_REMOVE_FROM%||mg"

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
  if "%FLAG%" == "-if_notexist" (
    set FLAG_IF_NOTEXIST=1
  ) else if "%FLAG%" == "-noexpire" (
    set FLAG_DETECT_EXPIRATION=0
  ) else if "%FLAG%" == "-skip_checks" (
    set FLAG_SKIP_CHECKS=1
  ) else if "%FLAG%" == "-r" (
    set "SED_REPLACE_FROM=%~2"
    set "SED_REPLACE_TO=%~3"
    shift
    shift
    set /A FLAG_SHIFT+=2
  ) else if "%FLAG%" == "-rm" (
    set "SED_REMOVE_FROM=%~2"
    shift
    set /A FLAG_SHIFT+=1
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
  echo;%?~%: error: not ended flags scope: [%FLAG_FLAGS_SCOPE%]: %FLAG%
  exit /b -255
) >&2

exit /b 0
