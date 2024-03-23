@echo off

setlocal

set "BUILD_CONFIG_ROOT=%~1"
set "BUILD_SCRIPTS_ROOT=%~2"
set "BUILD_USER_VARS_ROOT=%~3"

if defined BUILD_CONFIG_ROOT (
  if "\" == "%BUILD_CONFIG_ROOT:~0,1%" exit /b 1
  if "\" == "%BUILD_CONFIG_ROOT:~-1%" set "BUILD_CONFIG_ROOT=%BUILD_CONFIG_ROOT:~0,-1%"
)

if not defined BUILD_CONFIG_ROOT (
  echo.%~nx0: error: BUILD_CONFIG_ROOT must be defined.
  exit /b 1
) >&2

if defined BUILD_SCRIPTS_ROOT (
  if "\" == "%BUILD_SCRIPTS_ROOT:~0,1%" exit /b 2
  if "\" == "%BUILD_SCRIPTS_ROOT:~-1%" set "BUILD_SCRIPTS_ROOT=%BUILD_SCRIPTS_ROOT:~0,-1%"
)

if not defined BUILD_SCRIPTS_ROOT (
  echo.%~nx0: error: BUILD_SCRIPTS_ROOT must be defined.
  exit /b 2
) >&2

if defined BUILD_USER_VARS_ROOT (
  if "\" == "%BUILD_USER_VARS_ROOT:~0,1%" exit /b 3
  if "\" == "%BUILD_USER_VARS_ROOT:~-1%" set "BUILD_USER_VARS_ROOT=%BUILD_USER_VARS_ROOT:~0,-1%"
)

if not defined APP_SETUP_FILE_NAME (
  echo.%~nx0: error: APP_SETUP_FILE_NAME must be defined.
  exit /b 4
) >&2

if not defined MAKENSIS_LOG_FILE_NAME (
  echo.%~nx0: error: MAKENSIS_LOG_FILE_NAME must be defined.
  exit /b 5
) >&2

if defined BUILD_NEST_LVL set /A BUILD_NEST_LVL+=1
if not defined BUILD_NEST_LVL set BUILD_NEST_LVL=1

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/set_project_build_time.bat"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/env_generators\makensis_cmd_line.bat" "%%BUILD_CONFIG_ROOT%%" || exit /b 10

if exist "%BUILD_SCRIPTS_ROOT%/pre_validate_vars.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/pre_validate_vars.bat" || exit /b 13
) else call "%%~dp0nsis_pre_validate_vars.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 || exit /b 13

if %F_DISABLE_PRE_BUILD%0 EQU 0 ( call "%%BUILD_SCRIPTS_ROOT%%/pre_build.bat" || exit /b 14 )

rem safe title call
setlocal DISABLEDELAYEDEXPANSION
for /F "eol= tokens=* delims=" %%i in ("build %PROJECT_NAME% %BUILD_SCM_BRANCH% %PROJECT_TYPE% %APP_TARGET_NAME% %TARGET_NAME%") do (
  endlocal
  title %%i
)

echo.Build started: %PROJECT_BUILD_DATE% - %PROJECT_BUILD_TIME%

call "%%BUILD_SCRIPTS_ROOT%%/post_validate_vars.bat" || exit /b 15

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/lock_mutex.bat" %PROJECT_LOCK_TOKEN%_build
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_build_start
)

if %FLAGS_REBUILD%0 EQU 10 (
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BUILD_DIR: "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.CACHE_DIR: "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.BIN_DIR: "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.PDB_DIR: "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.PDB_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.LIB_DIR: "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.LIB_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.GEN_DIR: "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%" >nul
  echo Deleting PROJECT_STAGE_BUILD_ROOT.VAR_DIR: "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%"
  rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%" >nul

  rem delete only if declared, because not all projects may has cmake as nested builder
  if defined PROJECT_CMAKE_BUILD_ROOT (
    echo Deleting PROJECT_CMAKE_BUILD_ROOT: "%PROJECT_CMAKE_BUILD_ROOT%"
    rmdir /S /Q "%PROJECT_CMAKE_BUILD_ROOT%" >nul
  )
  if defined PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR (
    echo Deleting PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR: "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%"
    rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.INSTALL_DIR%" >nul
  )
)

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.BUILD_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.CACHE_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%%" || exit /b

echo.

rem read parent product version
if exist "%BUILD_SCRIPTS_ROOT%/read_parent_product_ver.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/read_parent_product_ver.bat" || exit /b 30
)

rem read product version
if exist "%BUILD_SCRIPTS_ROOT%/read_product_ver.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/read_product_ver.bat" || exit /b 31
)

echo.Generating NSIS defines...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/nsis_defines.nsi"

call "%%CONTOOLS_ROOT%%/nsis/gen_nsis_defines.bat" 1251 "%%BUILD_CONFIG_ROOT%%\nsis_defines.lst" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/nsis_defines.nsi"
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 32
)

echo.Generating NSIS search paths...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/nsis_search_paths.nsi"

call "%%CONTOOLS_ROOT%%/nsis/gen_nsis_search_paths.bat" "%%BUILD_CONFIG_ROOT%%\nsis_search_paths.lst" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/nsis_search_paths.nsi"
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 33
)

if %F_DISABLE_APP_DIR_INSTALL%0 NEQ 0 (
  type nul > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"
  goto IGNORE_APP_DIR_INSTALL
)

echo.Generating install file list...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"

if %F_ENABLE_APP_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/gen_dir_files_list_from_archive.bat" 1251 ^
    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%/*.7z" "*.*" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"
) else (
  call "%%CONTOOLS_ROOT%%/gen_dir_files_list.bat" 1251 ^
    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 34
)

echo.Generating install instructions...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install.nsi"

if %F_ENABLE_APP_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/nsis/gen_install_files_section_from_archive.bat" 1251 $EXEDIR "" "" "*.7z" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" ^
    0 "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install.nsi"
) else (
  call "%%CONTOOLS_ROOT%%/nsis/gen_install_files_section.bat" 1251 APP_ROOT "" "" ^
    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install.nsi"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 35
)

echo.Generating uninstall instructions...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall.nsi"

if %F_ENABLE_APP_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/nsis/gen_uninstall_files_section_from_archive.bat" 1251 $INSTDIR "" "*.7z" ^
    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall.nsi"
) else (
  call "%%CONTOOLS_ROOT%%/nsis/gen_uninstall_files_section.bat" 1251 $INSTDIR "" "" ^
    "%%STAGE_IN.PROJECT_STAGE_POSTBUILD_ROOT.BIN_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall.nsi"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 36
)

if exist "%BUILD_SCRIPTS_ROOT%/gen_install_list.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_install_list.bat" || exit /b 37
)

if exist "%BUILD_SCRIPTS_ROOT%/gen_uninstall_list.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_uninstall_list.bat" || exit /b 38
)

:IGNORE_APP_DIR_INSTALL

if %F_DISABLE_APP_INTEGRATION_DIR_INSTALL%0 NEQ 0 (
  goto IGNORE_APP_INTEGRATION_DIR_INSTALL
)

if not defined APP_INTEGRATION_ROOT goto IGNORE_GEN_INTEGRATION_FILE_LIST
if not defined APP_INTEGRATION_DIR goto IGNORE_GEN_INTEGRATION_FILE_LIST

echo.Generating integration install file list...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install_integration.nsi"

if %F_ENABLE_APP_INTEGRATION_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/gen_dir_files_list_from_archive.bat" 1251 ^
    "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" >> "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"
) else (
  call "%%CONTOOLS_ROOT%%/gen_dir_files_list.bat" 1251 ^
    "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" >> "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 40
)

echo.Generating integration install instructions...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install_integration.nsi"

if %F_ENABLE_APP_INTEGRATION_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/nsis/gen_install_files_section_from_archive.bat" 1251 $EXEDIR "" "" "*.7z" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" ^
    0 "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install_integration.nsi"
) else (
  call "%%CONTOOLS_ROOT%%/nsis/gen_install_files_section.bat" 1251 APP_INTEGRATION_ROOT "" "" ^
    "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/install_integration.nsi"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 41
)

echo.Generating integration uninstall instructions...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall_integration.nsi"

if %F_ENABLE_APP_INTEGRATION_DIR_INSTALL_FROM_ARCHIVE%0 NEQ 0 (
  call "%%CONTOOLS_ROOT%%/nsis/gen_uninstall_files_section_from_archive.bat" 1251 $INSTDIR "" "*.7z" ^
    "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall_integration.nsi"
) else (
  call "%%CONTOOLS_ROOT%%/nsis/gen_uninstall_files_section.bat" 1251 $INSTDIR "" "" ^
    "%%APP_INTEGRATION_ROOT%%/%%APP_INTEGRATION_DIR%%" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/uninstall_integration.nsi"
)
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 42
)

:IGNORE_GEN_INTEGRATION_FILE_LIST

if exist "%BUILD_SCRIPTS_ROOT%/gen_integration_install_list.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_integration_install_list.bat" || exit /b 43
)

if exist "%BUILD_SCRIPTS_ROOT%/gen_integration_uninstall_list.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_integration_uninstall_list.bat" || exit /b 44
)

:IGNORE_APP_INTEGRATION_DIR_INSTALL

echo.Generating scripts file list...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_scripts_list_res.nsi"

call "%%CONTOOLS_ROOT%%/nsis/gen_files_pp_command_from_list.bat" 1251 SCRIPT ".bat|.cmd" ^
  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_scripts_list_res.nsi"
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 50
)

echo.Generating executables file list...
echo.  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_exec_list_res.nsi"

call "%%CONTOOLS_ROOT%%/nsis/gen_files_pp_command_from_list.bat" 1251 PROC ".exe" ^
  "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_install_file_list.lst" > "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/product_exec_list_res.nsi"
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 51
)

if exist "%BUILD_SCRIPTS_ROOT%/gen_resources.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_resources.bat" || exit /b 52
)

rem SCM branch workingset
if %F_DISABLE_GEN_BRANCH_INFO%0 EQU 0 ^
if exist "%BUILD_SCRIPTS_ROOT%\gen_scm_branch_workingset.bat" (
  call "%%BUILD_SCRIPTS_ROOT%%/gen_scm_branch_workingset.bat" || exit /b 60
)

echo.Building setup executable...
echo.  "%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%/%APP_SETUP_FILE_NAME%.exe"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir_if_notexist.bat" "%%PROJECT_STAGE_BUILD_ROOT.BIN_DIR%%" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/callln.bat" "%%NSIS_ROOT%%/bin/makensis.exe" %%MAKENSIS_CMD_LINE.COMPILE%%
set LAST_ERROR=%ERRORLEVEL%
echo.Return code: %LAST_ERROR%

echo.

if %LAST_ERROR% NEQ 0 (
  call "%%CONTOOLS_ROOT%%/nsis/find_errors_nsis_log.bat" "%%MAKENSIS_LOG_FILE_NAME%%"
  echo.
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 70
)

call "%%CONTOOLS_ROOT%%/nsis/find_errors_nsis_log.bat" "%%MAKENSIS_LOG_FILE_NAME%%"
set LAST_ERROR=%ERRORLEVEL%

echo.

if %LAST_ERROR% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 71
)

rem copy makensis detailed log file into /gen directory
echo.Copying setup log files...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/xcopy_file.bat" . "%%MAKENSIS_LOG_FILE_NAME%%" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%" /Y /D
set LAST_ERROR=%ERRORLEVEL%

echo.

if %LAST_ERROR% NEQ 0 (
  echo.%~nx0: error: Build stopped because of previous errors.>&2
  exit /b 72
)

(
  echo."APP_BUILD_DATE=%APP_BUILD_DATE%"
  echo."APP_BUILD_TIME=%APP_BUILD_TIME%"
  echo."PROJECT_BUILD_DATE=%PROJECT_BUILD_DATE%"
  echo."PROJECT_BUILD_TIME=%PROJECT_BUILD_TIME%"
) > "%PROJECT_STAGE_BUILD_ROOT.VAR_DIR%\build.vars"

if defined PROJECT_LOCK_TOKEN (
  rem call "%%CONTOOLS_ROOT%%/locks/unlock_mutex.bat" %PROJECT_LOCK_TOKEN%_build
)

if %F_DISABLE_POST_BUILD%0 EQU 0 ( call "%%BUILD_SCRIPTS_ROOT%%/post_build.bat" || exit /b )

exit /b 0
