@echo off

rem script flags
set FLAG_SHIFT=0
set FLAG_FLAGS_SCOPE=0
set FLAG_SINGLE=0
set FLAG_IF_NOTEXIST=0
set FLAG_DETECT_EXPIRATION=1
set FLAG_SKIP_CHECKS=0
set "SED_BARE_FLAGS="
set "SED_REPLACE_FROM="
set "SED_REPLACE_TO="
set "SED_REMOVE_FROM="

:FLAGS_LOOP

if not defined SED_REPLACE_FROM goto SKIP_SED_REPLACE_FROM

set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$=$24%"
set "__STRING__=%SED_REPLACE_FROM:\=\\\%"

for %%i in ({ } [ ] ( ^) ^^ . +) do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:%%i=\%%i!") do endlocal & set "__STRING__=%%j"

call "%%CONTOOLS_ROOT%%/std/encode/encode_asterisk_char.bat"

rem standalone workarounds for the rest control characters
set "SED_REPLACE_FROM=%__STRING__:$2A=\*%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:?=\?%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:|=[|]%"

set "__STRING__=%SED_REPLACE_FROM:$24=$%"

rem we must replace `\xNN` sequence for the all control characters, except these characters: `.`
for %%i in (7B:{ 7D:} 5B:[ 5D:] 28:( 29:^) 5E:^^ 2B:+) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:$/\\\x%%j=\%%k!") do endlocal & set "__STRING__=%%j"

rem standalone workarounds for the rest control characters
set "SED_REPLACE_FROM=%__STRING__:$/\\\x2a=\*%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x2A=\*%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x3f=\?%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x3F=\?%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x7c=[|]%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x7C=[|]%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x24=$%"

set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x5c=\\\%"
set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\x5C=\\\%"

:SKIP_SED_REPLACE_FROM

if not defined SED_REPLACE_TO goto SKIP_SED_REPLACE_TO

set "SED_REPLACE_TO=%SED_REPLACE_TO:\=\\\%"
set "SED_REPLACE_TO=%SED_REPLACE_TO:|=\|%"

:SKIP_SED_REPLACE_TO

if not defined SED_REMOVE_FROM goto SKIP_SED_REMOVE_FROM

set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$=$24%"
set "__STRING__=%SED_REMOVE_FROM:\=\\\%"

for %%i in ({ } [ ] ( ^) ^^ . +) do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:%%i=\%%i!") do endlocal & set "__STRING__=%%j"

call "%%CONTOOLS_ROOT%%/std/encode/encode_asterisk_char.bat"

rem standalone workarounds for the rest control characters
set "SED_REMOVE_FROM=%__STRING__:$2A=\*%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:?=\?%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:|=[|]%"

set "__STRING__=%SED_REMOVE_FROM:$24=$%"

rem we must replace `\xNN` sequence for the all control characters, except these characters: `.`
for %%i in (7B:{ 7D:} 5B:[ 5D:] 28:( 29:^) 5E:^^ 2B:+) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:$/\\\x%%j=\%%k!") do endlocal & set "__STRING__=%%j"

rem standalone workarounds for the rest control characters
set "SED_REMOVE_FROM=%__STRING__:$/\\\x2a=\*%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x2A=\*%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x3f=\?%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x3F=\?%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x7c=[|]%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x7C=[|]%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x24=$%"

set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x5c=\\\%"
set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\x5C=\\\%"

:SKIP_SED_REMOVE_FROM

rem special `$/\` sequence to pass `\` character as is (ex: `$/\x22` translates into `\x22` - a quote character)
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$/\\\=\%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:$/\\\=\%"
if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$/\\\=\%"

rem escape $ character at the last
if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=%SED_REPLACE_FROM:$=\$%"
if defined SED_REPLACE_TO set "SED_REPLACE_TO=%SED_REPLACE_TO:$=\$%"
if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=%SED_REMOVE_FROM:$=\$%"

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
  if "%FLAG%" == "-s" (
    set FLAG_SINGLE=1
  ) else if "%FLAG%" == "-if_notexist" (
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
  echo;%?~%: error: not ended flags scope: %FLAG_FLAGS_SCOPE%
  exit /b -255
) >&2

exit /b 0
