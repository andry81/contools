@echo off

rem NOTE: `for /F` is used to prevent the control characters early expansion, like `=`, `,` and `;`
setlocal ENABLEDELAYEDEXPANSION & for /F "usebackq tokens=* delims="eol^= %%i in ('"!TEST_CMDLINE!"') do endlocal & ^
call "%%CONTOOLS_ROOT%%/std/is_int.bat" %%~i

set TEST_IMPL_ERROR=%ERRORLEVEL%

exit /b 0
