@echo off

setlocal

rem script flags
set FLAG_WAIT_EXIT=0
set FLAG_NOTEPADPLUSPLUS=0
set "BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if not "%FLAG%" == "" ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if not "%FLAG%" == "" (
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

call "%%~dp0loadvars.bat" "%%~dp0profile.vars"

set "PWD=%~1"
shift

set "FILES_LIST="
set NUM_FILES=0

if "%PWD%" == "" goto NOPWD
( %PWD:~0,2% && cd "%PWD%" ) || exit /b 1

:NOPWD

rem read selected file names into variable
:CURDIR_FILTER_LOOP
if "%~1" == "" goto CURDIR_FILTER_LOOP_END
rem ignore a sub directory open, files in a sub directory must be selected explicitly in a panel!
if exist "%~1\" goto IGNORE
set FILES_LIST=%FILES_LIST% %1
set /A NUM_FILES+=1

:IGNORE

shift

goto CURDIR_FILTER_LOOP

:CURDIR_FILTER_LOOP_END

if %NUM_FILES% EQU 0 exit /b 0

if %FLAG_WAIT_EXIT% NEQ 0 (
  if %FLAG_NOTEPADPLUSPLUS% NEQ 0 (
    call :CMD start /B /WAIT "" "%%EDITOR%%" -multiInst%%BARE_FLAGS%% %%FILES_LIST%%
  ) else (
    for %%i in (%FILES_LIST%) do (
      call :CMD start /B /WAIT "" "%%EDITOR%%"%%BARE_FLAGS%% %%i
    )
  )
) else (
  if %FLAG_NOTEPADPLUSPLUS% NEQ 0 (
    call :CMD start /B "" "%%EDITOR%%" -multiInst%%BARE_FLAGS%% %%FILES_LIST%%
  ) else (
    for %%i in (%FILES_LIST%) do (
      call :CMD start /B "" "%%EDITOR%%"%%BARE_FLAGS%% %%i
    )
  )
)

exit /b 0

:CMD
echo.^>%*
(%*)
