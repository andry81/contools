@echo off

setlocal

rem there to configure
set "CONFIGURE_TO_DIR=%~1"
rem where take the Tools directory
set "CONTOOLS_FROM_DIR=%~2"

if not defined CONFIGURE_TO_DIR goto IGNORE_CONFIGURE_TO_DIR

set "CONFIGURE_TO_DIR=%CONFIGURE_TO_DIR:\=/%"
if "%CONFIGURE_TO_DIR:~-1%" == "/" set "CONFIGURE_TO_DIR=%CONFIGURE_TO_DIR:~0,-1%"

if not exist "%CONFIGURE_TO_DIR%\" (
  echo.%~nx0: error: CONFIGURE_TO_DIR is not a directory: "%CONFIGURE_TO_DIR%"
  exit /b 1
) >&2

:IGNORE_CONFIGURE_TO_DIR
set "CONFIGURE_FROM_DIR=%~dp0"
set "CONFIGURE_FROM_DIR=%CONFIGURE_FROM_DIR:\=/%"
if "%CONFIGURE_FROM_DIR:~-1%" == "/" set "CONFIGURE_FROM_DIR=%CONFIGURE_FROM_DIR:~0,-1%"

if not defined CONTOOLS_FROM_DIR goto IGNORE_CONTOOLS_FROM_DIR

set "CONTOOLS_FROM_DIR=%CONTOOLS_FROM_DIR:\=/%"
if "%CONTOOLS_FROM_DIR:~-1%" == "/" set "CONTOOLS_FROM_DIR=%CONTOOLS_FROM_DIR:~0,-1%"

if not exist "%CONTOOLS_FROM_DIR%\" (
  echo.%~nx0: error: CONTOOLS_FROM_DIR is not a directory: "%CONTOOLS_FROM_DIR%"
  exit /b 2
) >&2

rem relocate CONTOOLS_ROOT
set "CONTOOLS_ROOT=%CONTOOLS_FROM_DIR%"

goto IGNORE_INNER_CONTOOLS_ROOT

:IGNORE_CONTOOLS_FROM_DIR
call :CANONICAL_PATH "%%~dp0..\.."
set "CONTOOLS_ROOT=%RETURN_VALUE%"


:IGNORE_INNER_CONTOOLS_ROOT

if not defined CONTOOLS_ROOT goto CONTOOLS_ROOT_ERROR
if not exist "%CONTOOLS_ROOT%\__init__.bat" goto CONTOOLS_ROOT_ERROR

rem initialize "module" tools
call "%%CONTOOLS_ROOT%%/__init__.bat" || goto CONTOOLS_ROOT_ERROR

if not defined SVNCMD_TOOLS_ROOT goto SVNCMD_TOOLS_ROOT_ERROR
if not exist "%SVNCMD_TOOLS_ROOT%\__init__.bat" goto SVNCMD_TOOLS_ROOT_ERROR

if defined CONFIGURE_TO_DIR (
  set "TOTALCMD_ROOT=%CONFIGURE_TO_DIR%"
  set "CONTOOLS_ROOT_COPY=%CONFIGURE_TO_DIR%/Tools"
) else (
  set "TOTALCMD_ROOT=%CONFIGURE_FROM_DIR%"
  set "CONTOOLS_ROOT_COPY=%CONFIGURE_FROM_DIR%/Tools"
)

rem pre calls to configure in an outter directory
if defined CONFIGURE_TO_DIR (
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/Tools" "%%CONTOOLS_ROOT_COPY%%" /E /Y /D || exit /b
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/converters" "%%CONFIGURE_TO_DIR%%/converters" /S /Y /D || exit /b
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/scm" "%%CONFIGURE_TO_DIR%%/scm" /S /Y /D || exit /b
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/images" "%%CONFIGURE_TO_DIR%%/images" /S /Y /D || exit /b
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/ButtonBars" "%%CONFIGURE_TO_DIR%%/ButtonBars" /S /Y /D || exit /b
  call :XCOPY_DIR "%%CONFIGURE_FROM_DIR%%/.saveload" "%%CONFIGURE_TO_DIR%%/.saveload" /E /Y /D || exit /b

  call :XCOPY_FILE "%%CONFIGURE_FROM_DIR%%" "__init__.bat" "%%CONFIGURE_TO_DIR%%" /Y /D /H || exit /b
)

call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "__init__.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/std" "%%CONTOOLS_ROOT_COPY%%/std" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_datetime.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_filesize.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "get_shared_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "reduce_relative_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "subtract_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "subtract_relative_path.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "index_pathstr.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "split_pathstr.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%" "strlen.bat" "%%CONTOOLS_ROOT_COPY%%" /Y /D /H || exit /b

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

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/tasks" "%%CONTOOLS_ROOT_COPY%%/tasks" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "compare_files.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "compare_files_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "compare_sorted_files.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "compare_sorted_files_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "create_dirs_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "create_empty_files_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "loadvars.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "notepad_edit_files.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "notepad_edit_files_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "notepad_new_session.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "save_file_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "load_file_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b
call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "copy_file_to_files_by_list.bat" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b

call :XCOPY_DIR "%%CONTOOLS_ROOT%%/ToolAdaptors/ffmpeg" "%%TOTALCMD_ROOT%%/converters/ffmpeg" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk" "*.*" "%%TOTALCMD_ROOT%%" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/vbs" "call*.vbs" "%%TOTALCMD_ROOT%%" /S /Y /D || exit /b

call :XCOPY_FILE "%%CONTOOLS_ROOT%%/ToolAdaptors/totalcmd" "profile.vars" "%%TOTALCMD_ROOT%%" /Y /D /H || exit /b

if not exist "%SYSTEMROOT%\System64\" (
  call :CMD "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/mklink_system64.bat"
  if exist "%SYSTEMROOT%\System64\" (
    echo."%SYSTEMROOT%\System64" -^> "%SYSTEMROOT%\System32"
  ) else (
    echo.%~nx0: error: could not create directory link: "%SYSTEMROOT%\System64" -^> "%SYSTEMROOT%\System32"
    exit /b 255
  ) >&2
)

pause

exit /b

:XCOPY_FILE
if not exist "%CONTOOLS_ROOT%/std/xcopy_file.bat" (
  echo.%~nx0: error: xcopy_file.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_file.bat".
  exit /b 5
) >&2
if not exist "%~3" mkdir "%~3"
call "%%CONTOOLS_ROOT%%/std/xcopy_file.bat" %%* || exit /b
exit /b 0

:XCOPY_DIR
if not exist "%CONTOOLS_ROOT%/std/xcopy_dir.bat" (
  echo.%~nx0: error: xcopy_dir.bat is not found: "%CONTOOLS_ROOT%/std/xcopy_dir.bat".
  exit /b 6
) >&2
if not exist "%~2" mkdir "%~2"
call "%%CONTOOLS_ROOT%%/std/xcopy_dir.bat" %%* || exit /b
exit /b 0

:CMD
echo.^>%*
(%*)
exit /b

:CANONICAL_PATH
set "RETURN_VALUE=%~dpf1"
set "RETURN_VALUE=%RETURN_VALUE:\=/%"
exit /b 0

:CONTOOLS_ROOT_ERROR
(
  echo.%~nx0: error: CONTOOLS_ROOT path is invalid or does not have the required set of utilities: "%CONTOOLS_ROOT%".
  echo.%~nx0: info: execute the configure.bat from the contools WC root to update modules.
  exit /b 10
) >&2

:SVNCMD_TOOLS_ROOT_ERROR
(
  echo.%~nx0: error: SVNCMD_TOOLS_ROOT path is invalid or does not have the required set of utilities: "%SVNCMD_TOOLS_ROOT%".
  echo.%~nx0: info: execute the configure.bat from the contools WC root to update modules.
  exit /b 20
) >&2
