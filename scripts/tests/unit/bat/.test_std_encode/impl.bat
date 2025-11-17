@echo off

setlocal DISABLEDELAYEDEXPANSION

set "STRING_INPUT="
set "STRING_ENCODED="
set "STRING_OUTPUT="

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!__STRING__!"') do endlocal & set "STRING_INPUT=%%~i"

call "%%CONTOOLS_ROOT%%/std/encode/encode_%%TEST_FUNC%%.bat" || ( set "LAST_IMPL_ERROR=10" & goto EXIT )

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!__STRING__!"') do endlocal & set "STRING_ENCODED=%%~i"

call "%%CONTOOLS_ROOT%%/std/encode/decode_%%TEST_FUNC%%.bat" || ( set "LAST_IMPL_ERROR=20" & goto EXIT )

setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!__STRING__!"') do endlocal & set "STRING_OUTPUT=%%~i"

:EXIT
setlocal ENABLEDELAYEDEXPANSION & ^
for /F "usebackq tokens=* delims="eol^= %%i in ('"!STRING_INPUT!"') do ^
for /F "usebackq tokens=* delims="eol^= %%j in ('"!STRING_ENCODED!"') do ^
for /F "usebackq tokens=* delims="eol^= %%k in ('"!STRING_OUTPUT!"') do ^
endlocal & endlocal & set "STRING_INPUT=%%~i" & set "STRING_ENDCODED=%%~j" & set "STRING_OUTPUT=%%~k"
exit /b 0
