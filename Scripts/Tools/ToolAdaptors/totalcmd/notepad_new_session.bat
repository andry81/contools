@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

call "%%?~dp0%%loadvars.bat" "%%?~dp0%%profile.vars" || goto :EOF

rem script flags
set FLAG_WAIT_EXIT=0
set FLAG_NOTEPADPLUSPLUS=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  if "%FLAG%" == "-wait" (
    set FLAG_WAIT_EXIT=1
  ) else if "%FLAG%" == "-npp" (
    set FLAG_NOTEPADPLUSPLUS=1
  ) else (
    set BARE_FLAGS=%BARE_FLAGS% %1
  )

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

set "PWD=%~1"
shift

if not defined PWD goto NOPWD
cd /d "%PWD%" || exit /b 1

:NOPWD

if %FLAG_WAIT_EXIT% NEQ 0 (
  if %FLAG_NOTEPADPLUSPLUS% NEQ 0 (
    call :CMD start /B /WAIT "" "%%NPP_EDITOR%%"%%BARE_FLAGS%%
  ) else (
    call :CMD start /B /WAIT "" "%%BASIC_TEXT_EDITOR%%"%%BARE_FLAGS%%
  )
) else (
  if %FLAG_NOTEPADPLUSPLUS% NEQ 0 (
    call :CMD start /B "" "%%NPP_EDITOR%%"%%BARE_FLAGS%%
  ) else (
    call :CMD start /B "" "%%BASIC_TEXT_EDITOR%%"%%BARE_FLAGS%%
  )
)

exit /b 0

:CMD
echo.^>%*
(%*)