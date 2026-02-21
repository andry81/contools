@echo off

if not defined SED_REPLACE_FROM goto SKIP_SED_REPLACE_FROM

rem replace double quotes at first
if %FLAG_ESC_DBL_QUOTE% EQU 0 goto SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:"=$/\x22!"
for /F "tokens=* delims="eol^= %%i in ("!SED_REPLACE_FROM!") do ^
endlocal ^
  & set "SED_REPLACE_FROM=%%i"

:SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$=$24!" ^
  & set "__STRING__=!SED_REPLACE_FROM:\=\\\!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do ^
endlocal ^
  & set "__STRING__=%%i"

for %%i in ({ } [ ] ( ^) ^^ . +) do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:%%i=\%%i!") do endlocal & set "__STRING__=%%j"

call "%%CONTOOLS_ROOT%%/std/encode/encode_asterisk_char.bat"

rem standalone workarounds for the rest control characters
setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_FROM=!__STRING__:$2A=\*!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:?=\?!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:|=[|]!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:&=[&]!" ^
  & set "__STRING__=!SED_REPLACE_FROM:$24=$!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do ^
endlocal ^
  & set "__STRING__=%%i"

rem we must replace `\xNN` sequence for the all control characters, except these characters: `.`
for %%i in (7B:{ 7D:} 5B:[ 5D:] 28:( 29:^) 5E:^^ 2B:+) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:$/\\\x%%j=\%%k!") do endlocal & set "__STRING__=%%j"

rem standalone workarounds for the rest control characters
setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_FROM=!__STRING__:$/\\\x2a=\*!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x2A=\*!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x3f=\?!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x3F=\?!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x7c=[|]!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x7C=[|]!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x26=[&]!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x24=$!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x5c=\\\!" ^
  & set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\x5C=\\\!" & ^
for /F "tokens=* delims="eol^= %%i in ("!SED_REPLACE_FROM!") do ^
endlocal ^
  & set "SED_REPLACE_FROM=%%i"

:SKIP_SED_REPLACE_FROM

if not defined SED_REPLACE_TO goto SKIP_SED_REPLACE_TO

rem replace double quotes at first
if %FLAG_ESC_DBL_QUOTE% EQU 0 goto SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_TO=!SED_REPLACE_TO:"=$/\x22!"
for /F "tokens=* delims="eol^= %%i in ("!SED_REPLACE_TO!") do ^
endlocal ^
  & set "SED_REPLACE_TO=%%i"

:SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REPLACE_TO=!SED_REPLACE_TO:\=\\\!" ^
  & set "SED_REPLACE_TO=!SED_REPLACE_TO:|=\|!" ^
  & set "SED_REPLACE_TO=!SED_REPLACE_TO:&=\&!" & ^
for /F "tokens=* delims="eol^= %%i in ("!SED_REPLACE_TO!") do ^
endlocal ^
  & set "SED_REPLACE_TO=%%i"

:SKIP_SED_REPLACE_TO

if not defined SED_REMOVE_FROM goto SKIP_SED_REMOVE_FROM

rem replace double quotes at first
if %FLAG_ESC_DBL_QUOTE% EQU 0 goto SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:"=$/\x22!"
for /F "tokens=* delims="eol^= %%i in ("!SED_REMOVE_FROM!") do ^
endlocal ^
  & set "SED_REMOVE_FROM=%%i"

:SKIP_ESC_DBL_QUOTE

setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$=$24!" ^
  & set "__STRING__=!SED_REMOVE_FROM:\=\\\!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do ^
endlocal ^
  & set "__STRING__=%%i"

for %%i in ({ } [ ] ( ^) ^^ . +) do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:%%i=\%%i!") do endlocal & set "__STRING__=%%j"

call "%%CONTOOLS_ROOT%%/std/encode/encode_asterisk_char.bat"

rem standalone workarounds for the rest control characters
setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REMOVE_FROM=!__STRING__:$2A=\*!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:?=\?!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:|=[|]!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:&=[&]!" 
  & set "__STRING__=!SED_REMOVE_FROM:$24=$!" & ^
for /F "tokens=* delims="eol^= %%i in ("!__STRING__!") do ^
endlocal ^
  & set "__STRING__=%%i"

rem we must replace `\xNN` sequence for the all control characters, except these characters: `.`
for %%i in (7B:{ 7D:} 5B:[ 5D:] 28:( 29:^) 5E:^^ 2B:+) do ^
for /F "tokens=1,* delims=:"eol^= %%j in ("%%i") do ^
setlocal ENABLEDELAYEDEXPANSION & for /F "tokens=* delims="eol^= %%j in ("!__STRING__:$/\\\x%%j=\%%k!") do endlocal & set "__STRING__=%%j"

rem standalone workarounds for the rest control characters
setlocal ENABLEDELAYEDEXPANSION ^
  & set "SED_REMOVE_FROM=!__STRING__:$/\\\x2a=\*!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x2A=\*!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x3f=\?!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x3F=\?!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x7c=[|]!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x7C=[|]!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x26=[&]!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x24=$!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x5c=\\\!" ^
  & set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\x5C=\\\!" & ^
for /F "tokens=* delims="eol^= %%i in ("!SED_REMOVE_FROM!") do
endlocal ^
  & set "SED_REMOVE_FROM=%%i"

:SKIP_SED_REMOVE_FROM

setlocal ENABLEDELAYEDEXPANSION & (
  rem special `$/\` sequence to pass `\` character as is (ex: `$/\x22` translates into `\x22` - a quote character)
  if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$/\\\=\!"
  if defined SED_REPLACE_TO set "SED_REPLACE_TO=!SED_REPLACE_TO:$/\\\=\!"
  if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$/\\\=\!"

  rem escape $ character at the last
  if defined SED_REPLACE_FROM set "SED_REPLACE_FROM=!SED_REPLACE_FROM:$=\$!"
  if defined SED_REPLACE_TO set "SED_REPLACE_TO=!SED_REPLACE_TO:$=\$!"
  if defined SED_REMOVE_FROM set "SED_REMOVE_FROM=!SED_REMOVE_FROM:$=\$!"

  if defined SED_REPLACE_FROM if defined SED_REPLACE_TO set SED_BARE_FLAGS=!SED_BARE_FLAGS! -e "s|!SED_REPLACE_FROM!|!SED_REPLACE_TO!|mg"
  if defined SED_REMOVE_FROM set SED_BARE_FLAGS=!SED_BARE_FLAGS! -e "s|!SED_REMOVE_FROM!||mg"
)

for /F "usebackq tokens=* delims="eol^= %%i in ('"!SED_BARE_FLAGS!"') do ^
endlocal ^
  & set "SED_BARE_FLAGS=%%~i"

exit /b 0
