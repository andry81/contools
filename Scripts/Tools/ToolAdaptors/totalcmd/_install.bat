@echo off

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"
set "?~nx0=%~nx0"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

:EXIT_MAIN
exit /b %LASTERROR%

:MAIN
rem script flags
rem set FLAG_IGNORE_BUTTONBARS=0

:FLAGS_LOOP

rem flags always at first
set "FLAG=%~1"

if defined FLAG ^
if not "%FLAG:~0,1%" == "-" set "FLAG="

if defined FLAG (
  rem if "%FLAG%" == "-ignore_buttonbars" (
  rem   set FLAG_IGNORE_BUTTONBARS=1
  rem ) else
  (
    echo.%?~nx0%: error: invalid flag: %FLAG%
    exit /b -255
  ) >&2

  shift

  rem read until no flags
  goto FLAGS_LOOP
)

rem there to configure
set "CONFIGURE_TO_DIR=%~1"

if not defined CONFIGURE_TO_DIR (
  echo.%?~nx0%: error: CONFIGURE_TO_DIR must be defined
  exit /b 1
) >&2

set "CONFIGURE_TO_DIR=%CONFIGURE_TO_DIR:\=/%"
if "%CONFIGURE_TO_DIR:~-1%" == "/" set "CONFIGURE_TO_DIR=%CONFIGURE_TO_DIR:~0,-1%"

if not exist "%CONFIGURE_TO_DIR%\" (
  echo.%?~nx0%: error: CONFIGURE_TO_DIR is not a directory: "%CONFIGURE_TO_DIR%"
  exit /b 2
) >&2

set "CONFIGURE_FROM_DIR=%?~dp0%"
set "CONFIGURE_FROM_DIR=%CONFIGURE_FROM_DIR:\=/%"
if "%CONFIGURE_FROM_DIR:~-1%" == "/" set "CONFIGURE_FROM_DIR=%CONFIGURE_FROM_DIR:~0,-1%"

call :CANONICAL_PATH "%%?~dp0%%..\.."
set "CONTOOLS_ROOT=%RETURN_VALUE%"

:IGNORE_INNER_CONTOOLS_ROOT

if not defined CONTOOLS_ROOT goto CONTOOLS_ROOT_ERROR
if not exist "%CONTOOLS_ROOT%\__init__.bat" goto CONTOOLS_ROOT_ERROR

rem initialize "module" tools
call "%%CONTOOLS_ROOT%%/__init__.bat" || goto CONTOOLS_ROOT_ERROR

if not defined SVNCMD_TOOLS_ROOT goto SVNCMD_TOOLS_ROOT_ERROR
if not exist "%SVNCMD_TOOLS_ROOT%\__init__.bat" goto SVNCMD_TOOLS_ROOT_ERROR

set "COMMANDER_SCRIPTS_ROOT=%CONFIGURE_TO_DIR%"
set "CONTOOLS_ROOT_COPY=%CONFIGURE_TO_DIR%/tacklebar/Tools"

rem installing..

call :CMD "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/cmd_admin.lnk" /C @setx /M COMMANDER_SCRIPTS_ROOT "%%COMMANDER_SCRIPTS_ROOT:/=\%%"

if not exist "%CONFIGURE_TO_DIR%/tacklebar\" (
  call :CMD mkdir "%%CONFIGURE_TO_DIR%%/tacklebar"
)

rem call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/.saveload" "%%CONFIGURE_TO_DIR%%/.saveload" /E /Y /D || exit /b

call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/_config" "%%CONFIGURE_TO_DIR%%/tacklebar/_config" /E /Y /D || exit /b

call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/ButtonBars" "%%CONFIGURE_TO_DIR%%/tacklebar/ButtonBars" /S /Y /D || exit /b

call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/Tools" "%%CONFIGURE_TO_DIR%%/tacklebar/Tools" /E /Y /D || exit /b
call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/converters" "%%CONFIGURE_TO_DIR%%/tacklebar/converters" /S /Y /D || exit /b
call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/scm" "%%CONFIGURE_TO_DIR%%/tacklebar/scm" /S /Y /D || exit /b
call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/images" "%%CONFIGURE_TO_DIR%%/tacklebar/images" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "__init__.bat" "%%CONFIGURE_TO_DIR%%/tacklebar" /Y /D /H || exit /b


call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "__init__.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/std" "%%CONTOOLS_ROOT_COPY%%/std" /S /Y /D || exit /b
call :XCOPY_DIR "%%CONTOOLS_ROOT%%/xcopy" "%%CONTOOLS_ROOT_COPY%%/xcopy" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_filesize.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_shared_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "reduce_relative_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "subtract_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "subtract_relative_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "index_pathstr.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "split_pathstr.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "strlen.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/../../Utilities/bin" "wxFileDialog.exe" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/encoding" "%%CONTOOLS_ROOT_COPY%%/encoding" /S /Y /D || exit /b

call :XCOPY_DIR "%%GNUWIN32_ROOT%%" "%%CONTOOLS_ROOT_COPY%%/gnuwin32" /E /Y /D || exit /b

call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "__init__.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "svn_has_changes.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "extract_info_param.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "gen_externals_list_from_pget.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "svn_externals_list.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "make_url_absolute.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "make_url_canonical.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "extract_url_scheme.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%" "extract_url_root.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn" /Y /D /H || exit /b
call :XCOPY_FILE "%%SVNCMD_TOOLS_ROOT%%/impl" "svn_get_wc_db_user_ver.bat" "%%CONTOOLS_ROOT_COPY%%/scm/svn/impl" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/sqlite" "%%CONTOOLS_ROOT_COPY%%/sqlite" /S /Y /D || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/hash" "%%CONTOOLS_ROOT_COPY%%/hash" /S /Y /D || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/locks" "%%CONTOOLS_ROOT_COPY%%/locks" /S /Y /D || exit /b
call :XCOPY_DIR "%%CONTOOLS_ROOT%%/tasks" "%%CONTOOLS_ROOT_COPY%%/tasks" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "compare_paths.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "compare_paths_by_lists.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "compare_paths_from_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "compare_paths_from_stdin.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "copy_file_to_files_by_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "create_dirs_by_path_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "create_dirs_in_dirs_from_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "create_empty_files_by_path_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "create_empty_files_in_dirs_from_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "edit_file_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "notepad_edit_files.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "notepad_edit_files_by_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "notepad_new_session.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "save_file_list.bat" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/ToolAdaptors/ffmpeg" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar/converters/ffmpeg" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk" "cmd*.*" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/vbs" "call*.vbs" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b

call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "profile.vars.in" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar" /Y /D /H || exit /b

if not exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar\profile.vars" goto COPY_PROFILE

call :CMD "%%CONTOOLS_ROOT_COPY%%/check_config_version.bat" 1 ^
  "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars.in" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars" || exit /b

if /i "%%CONFIGURE_FROM_DIR%%\profile.vars" == "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars" goto IGNORE_PROFILE_WRITE
call :CMD fc "%%CONFIGURE_FROM_DIR%%\profile.vars.in" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars" > nul
if %ERRORLEVEL% EQU 0 goto IGNORE_PROFILE_WRITE

set PROFILE_VARS_INDEX_TO=3
set PROFILE_VARS_INDEX_FROM=%PROFILE_VARS_INDEX_TO%
:PROFILE_ROTATE_LOOP
set /A PROFILE_VARS_INDEX_FROM-=1
set /A PROFILE_VARS_INDEX_BEFORE=%PROFILE_VARS_INDEX_FROM%-1

if %PROFILE_VARS_INDEX_FROM% LSS 1 goto CONTINUE_PROFILE_WRITE

if %PROFILE_VARS_INDEX_FROM% GTR 1 (
  if %PROFILE_VARS_INDEX_BEFORE% GTR 1 (
    set "PROFILE_VARS_FILE_NAME_BEFORE=profile.old.%PROFILE_VARS_INDEX_BEFORE%.vars"
  ) else (
    set "PROFILE_VARS_FILE_NAME_BEFORE=profile.old.vars"
  )
  set "PROFILE_VARS_FILE_NAME_FROM=profile.old.%PROFILE_VARS_INDEX_FROM%.vars"
) else (
  set "PROFILE_VARS_FILE_NAME_BEFORE=profile.vars"
  set "PROFILE_VARS_FILE_NAME_FROM=profile.old.vars"
)

if exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar/%PROFILE_VARS_FILE_NAME_BEFORE%" (
  if exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar/%PROFILE_VARS_FILE_NAME_FROM%" (
    if exist "%COMMANDER_SCRIPTS_ROOT%/tacklebar/profile.old.%PROFILE_VARS_INDEX_TO%.vars" (
      call :CMD del /F /Q /A:-D "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.old.%%PROFILE_VARS_INDEX_TO%%.vars"
    )
    call :CMD rename "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\%%PROFILE_VARS_FILE_NAME_FROM%%" "profile.old.%%PROFILE_VARS_INDEX_TO%%.vars" || exit /b
  )
)

set "PROFILE_VARS_INDEX_TO=%PROFILE_VARS_INDEX_FROM%"

goto PROFILE_ROTATE_LOOP

:CONTINUE_PROFILE_WRITE
call :CMD rename "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars" "profile.old.vars" || exit /b

:COPY_PROFILE
call :COPY_FILE "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars.in" "%%COMMANDER_SCRIPTS_ROOT%%/tacklebar\profile.vars" || exit /b

:IGNORE_PROFILE_WRITE
if not exist "%SYSTEMROOT%\System64\" (
  call :CMD "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/mklink_system64.bat"
  if exist "%SYSTEMROOT%\System64\" (
    echo."%SYSTEMROOT%\System64" -^> "%SYSTEMROOT%\System32"
  ) else (
    echo.%?~nx0%: error: could not create directory link: "%SYSTEMROOT%\System64" -^> "%SYSTEMROOT%\System32"
    exit /b 255
  ) >&2
)

pause

exit /b

:XCOPY_FILE
if not exist "%CONTOOLS_ROOT%/std/xcopy_file.bat" (
  echo.%?~nx0%: error: xcopy_file.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_file.bat".
  exit /b 5
) >&2
if not exist "%~3" mkdir "%~3"
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%* || exit /b
exit /b 0

:XCOPY_DIR
if not exist "%CONTOOLS_ROOT%/std/xcopy_dir.bat" (
  echo.%?~nx0%: error: xcopy_dir.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_dir.bat".
  exit /b 6
) >&2
if not exist "%~2" mkdir "%~2"
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%* || exit /b
exit /b 0

:COPY_FILE
echo."%~1" -^> "%~2"
copy "%~1" "%~2" /B /Y || exit /b
exit /b 0

:CMD
echo.^>%*
(%*)
exit /b

:CANONICAL_PATH
setlocal DISABLEDELAYEDEXPANSION
set "RETURN_VALUE=%~dpf2"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
if "%RETURN_VALUE:~-1%" == "/" set "RETURN_VALUE=%RETURN_VALUE:~0,-1%"
(
  endlocal
  set "%~1=%RETURN_VALUE%"
)
exit /b 0

:CONTOOLS_ROOT_ERROR
(
  echo.%?~nx0%: error: CONTOOLS_ROOT path is invalid or does not have the required set of utilities: "%CONTOOLS_ROOT%".
  echo.%?~nx0%: info: execute the `*_configure.bat` from the contools WC root to update modules.
  exit /b 10
) >&2

:SVNCMD_TOOLS_ROOT_ERROR
(
  echo.%?~nx0%: error: SVNCMD_TOOLS_ROOT path is invalid or does not have the required set of utilities: "%SVNCMD_TOOLS_ROOT%".
  echo.%?~nx0%: info: execute the `*_configure.bat` from the contools WC root to update modules.
  exit /b 20
) >&2
