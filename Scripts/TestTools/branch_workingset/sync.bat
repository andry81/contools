@echo off

rem Flags:
rem  -R - update root externals recursively.
rem  -r - checkout/relocate/switch/revert/update all branch directories (recursively or not) w/o flag --ignore-externals.
rem       If set then the script will synchronize a parent branch state with children branches through the svn.exe call only.
rem       If not set, then the script will sychronize parent-children databases itself by the wc.db direct access.
rem  -fresh - remove root branch directory content before checkout it.
rem  -ac - auto cleanup all branches before relocate/switch/revert/update to mainly remove all locks.
rem  -ar - auto revert any branch changes.
rem  -as - auto switch to URL from workingset if previous is different (relative path change).
rem  -fs - force switch from URL w/o common version control ancestry with the requested switch location (see error E195012 and --ignore-ancestry svn.exe flag)
rem  -arloc - auto relocate to URL from workingset if previous is different (absolute path change, overrides flag -as).

setlocal

if not exist "%~dp0configure.user.bat" ^
if exist "%~dp0configure.bat" ( call "%%~dp0configure.bat" || exit /b 65534 )
if exist "%~dp0configure.user.bat" ( call "%%~dp0configure.user.bat" || exit /b 65533 )

if "%TOOLS_PATH%" == "" set "TOOLS_PATH=%~dp0tools"
set "TOOLS_PATH=%TOOLS_PATH:\=/%"
if "%TOOLS_PATH:~-1%" == "/" set "TOOLS_PATH=%TOOLS_PATH:~0,-1%"

if "%~1" == "" exit /b 65532
if "%~2" == "" exit /b 65531

call "%%TOOLS_PATH%%/scm/svn/sync_branch_workingset.bat" %%3 %%4 %%5 %%6 %%7 %%8 %%9 "%%~1" "%%~2_root_info.txt" "%%~2_root_changeset.lst" "%%~2_root_diff.patch" "%%~2_workingset.lst" "%%~2_workingset"
