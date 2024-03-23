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

rem SVN
rmdir /S /Q "%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%/scm/svn"
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/mkdir.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn" || exit /b

call "%%SVNCMD_TOOLS_ROOT%%/gen_branch_workingset_time.bat" -offline -relfpaths -R -ad -ls -stat "%%PROJECT_BRANCH_ROOT%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_info.txt" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_changeset.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_diff.patch" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_externals.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_workingset.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_workingset" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_files.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_all_files.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_all_files_hash.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_root_status.txt" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_all_status.txt" || ( call "%%CONTOOLS_ROOT%%/std/if_.bat" %%ERRORLEVEL%% GTR 0 && exit /b 2 )

echo.Archiving project branch workingset...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn" "svn_project_branch*" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_project_branch_workingset.7z" -sdel || exit /b 14
echo.

if not defined SOLUTION_BRANCH_ROOT goto IGNORE_SOLUTION_BRANCH
if "%SOLUTION_BRANCH_ROOT%" == "%PROJECT_BRANCH_ROOT%" goto IGNORE_SOLUTION_BRANCH

call "%%SVNCMD_TOOLS_ROOT%%/gen_branch_workingset_time.bat" -offline -relfpaths -R -ad -ls -stat "%%SOLUTION_BRANCH_ROOT%%" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_info.txt" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_changeset.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_diff.patch" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_externals.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_workingset.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_workingset" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_files.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_all_files.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_all_files_hash.lst" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_root_status.txt" ^
  "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_all_status.txt" || ( call "%%CONTOOLS_ROOT%%/std/if_.bat" %%ERRORLEVEL%% GTR 0 && exit /b 3 )

echo.Archiving solution branch workingset...
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/add_files_to_archive.bat" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn" "svn_solution_branch*" "%%PROJECT_STAGE_BUILD_ROOT.GEN_DIR%%/scm/svn/svn_solution_branch_workingset.7z" -sdel || exit /b 16
echo.

:IGNORE_SOLUTION_BRANCH
