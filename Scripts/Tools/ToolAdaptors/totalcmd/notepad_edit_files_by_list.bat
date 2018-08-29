@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call "%%?~dp0%%__init__.bat" || goto :EOF

call "%%?~dp0%%loadvars.bat" "%%?~dp0%%profile.vars" || goto :EOF

call "%%CONTOOLS_ROOT%%/std/allocate_temp_dir.bat" . "%%?~n0%%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
rem cleanup temporary files
call "%%CONTOOLS_ROOT%%/std/free_temp_dir.bat"

rem pause

exit /b %LASTERROR%

:MAIN
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

if "%~1" == "" exit /b 0

if %FLAG_NOTEPADPLUSPLUS% EQU 0 goto USE_BASIC_NOTEPAD

set "EDIT_FROM_LIST_FILE_TMP=%SCRIPT_TEMP_CURRENT_DIR%\edit_from_file_list.xml"

rem recreate empty lists
type nul > "%EDIT_FROM_LIST_FILE_TMP%"

rem create Notepad++ only session file
(
  echo.^<NotepadPlus^>
  echo.    ^<Session^>
  echo.        ^<mainView^>

  rem read selected file paths from file
  for /F "usebackq eol=	 tokens=* delims=" %%i in ("%~1") do (
    rem ignore a sub directory open, files in a sub directory must be selected explicitly in a panel!
    if not exist "%%i\" (
      echo.            ^<File filename="%%i"/^>
    )
  )

  echo.        ^</mainView^>
  echo.    ^</Session^>
  echo.^</NotepadPlus^>

) >> "%EDIT_FROM_LIST_FILE_TMP%"

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%EDITOR%%"%%BARE_FLAGS%% -openSession "%%EDIT_FROM_LIST_FILE_TMP%%"
) else (
  call :CMD start /B "" "%%EDITOR%%"%%BARE_FLAGS%% -openSession "%%EDIT_FROM_LIST_FILE_TMP%%"
)

exit /b 0

:USE_BASIC_NOTEPAD

rem CAUTION: no limit to open files!
for /F "usebackq eol=	 tokens=* delims=" %%i in ("%~1") do (
  set "FILE_TO_EDIT=%%i"
  call :OPEN_BASIC_EDITOR
)

exit /b 0

:OPEN_BASIC_EDITOR
if not defined FILE_TO_EDIT exit /b 0

rem ignore a sub directory open, files in a sub directory must be selected explicitly in a panel!
if exist "%FILE_TO_EDIT%\" goto ENDLOCAL_END_EXIT

if %FLAG_WAIT_EXIT% NEQ 0 (
  call :CMD start /B /WAIT "" "%%EDITOR%%"%%BARE_FLAGS%% "%%FILE_TO_EDIT%%"
) else (
  call :CMD start /B "" "%%EDITOR%%"%%BARE_FLAGS%% "%%FILE_TO_EDIT%%"
)

exit /b 0

:CMD
echo.^>%*
(%*)
