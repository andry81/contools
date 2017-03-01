@echo off

rem Flags:
rem  -offline - scan Working Copy in offline mode (for example, "svn ls" calls will be replaced by the SVN wc.db direct access).
rem  -relfpaths - truncate any absolute paths in nested info files (the root does not touch) into relative (to avoid comparison issues with different absolute paths).
rem  -R - parse root externals recursively.
rem  -diff_ra - get each branch difference state after Last Changed Rev from server (experimental, slow and can generate wrong difference file in case if commit made w/o update).
rem  -ad - auto detect SVN version control directories recursively.
rem  -ls - save file-directory list of SVN branch into file and hash it.
rem  -stat - save status of SVN branch in a working copy into file.
rem  -stat-exclude-? - exclude status lines for unversionned files (? prefixed) from "svn status" output.

setlocal

if not exist "%~dp0configure.user.bat" ^
if exist "%~dp0configure.bat" ( call "%%~dp0configure.bat" || exit /b 65534 )
if exist "%~dp0configure.user.bat" ( call "%%~dp0configure.user.bat" || exit /b 65533 )

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0tools"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

if "%~1" == "" exit /b 65532
if "%~2" == "" exit /b 65531

call "%%TOOLS_PATH%%/scm/svn/gen_branch_workingset.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 "%%~1" "%%~2_root_info.txt" "%%~2_root_changeset.lst" "%%~2_root_diff.patch" "%%~2_root_externals.lst" "%%~2_workingset.lst" "%%~2_workingset" "%%~2_root_files.lst" "%%~2_all_files.lst" "%%~2_all_files_hash.lst" "%%~2_root_status.txt" "%%~2_all_status.txt"
