@echo off & goto DOC_END

rem Description:
rem   Installation script to create `System64` directory through the
rem   `mklink` command or `junction.exe` (for Windows XP only) utility.
rem
rem   Script creates `System64` directory additionally to the `Sysnative`,
rem   because:
rem     1. The `Sysnative` directory visible ONLY from 32-bit applications on
rem        64-bit OS and ONLY if accessed as a directory
rem        (`\` or `\*` at the end):
rem           >
rem           if exist "%SystemRoot%\Sysnative\*" ...
rem     2. The `Sysnative` directory doesn't exist on the Windows XP x64 and
rem        lower.
rem     3. If the directory is visible the `Sysnative/cmd.exe` can not be run
rem        under the Administrator user.
rem
rem   For above reasons we should create another directory additionally to the
rem   `Sysnative` one which is:
rem
rem   1. Visible from any application bitness mode and the Windows version.
rem   2. Has no specific privilege rights restriction by the system and
rem      `cmd.exe` executable can be run under administrator user w/o any
rem      additional manipulations.

rem NOTE:
rem   In case of a standalone usage in the Windows XP the `junction.exe`
rem   utility must be available on the PATH for the Administrator otherwise the
rem   script won't work.

rem NOTE:
rem   Because we have to attempt to create a directory in the system directory,
rem   then we have to do it with administrative permissions only.
rem   Because the `System32` directory should not be redirected at the moment
rem   of creation (linkage), then we have to do it in the 64-bit mode only.
:DOC_END

rem call "%%~dp0script_init.bat" %%0 %%* || exit /b
rem if %IMPL_MODE%0 EQU 0 exit /b
rem goto IMPL

call "%%~dp0__init__.bat" || exit /b

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%USERBIN_SCRIPTS_BAT_ROOT%/runas/hta/cmd-admin.bat" /k @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
rem script names call stack, disabled due to self call and partial inheritance (process elevation does not inherit a parent process variables by default)
rem if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"
set "?~=%~nx0"

call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo;%?~%: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64

if not defined PROCESSOR_ARCHITEW6432 (
  echo;%?~%: error: script must be run only for Windows x64.
  exit /b 255
) >&2

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  "%SystemRoot%\Sysnative\cmd.exe" /c @"%~f0" %*
  exit /b
)

rem x64 is a requirement to continue
(
  echo;%?~%: error: run script in 64-bit console ONLY ^(in administrative mode^)!
  exit /b 255
) >&2

:X64

if not exist "\\?\%SystemRoot%\System64\*" goto DIR_UNEXIST

dir "%SystemRoot%\System64>" /A:DL 2>nul | "%SystemRoot%\System32\findstr.exe" /R /C:"[^ ][^ ]*  *[^ ][^ ]*  *\<JUNCTION\>" >nul || (
  echo;%?~%: error: directory exist and is not a junction point: "%SystemRoot%\System64"
  exit /b 100
) >&2

:DIR_UNEXIST
if %WINDOWS_MAJOR_VER% GTR 5 ( call :MAKE_LINK_DEFAULT ) else call :MAKE_LINK_WINXP

:SKIP_LINK
if not exist "\\?\%SystemRoot%\System64\*" (
  echo;%?~%: error: could not create directory link: "%SystemRoot%\System64" -^> "%SystemRoot%\System32"
  exit /b 255
) >&2

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%~n0.%RANDOM%-%RANDOM%"
) else set "TEMP_DIR=%TEMP%\%~n0.%RANDOM%-%RANDOM%"

mkdir "%TEMP_DIR%" >nul || exit /b 255

call :COPY_RESET_PERMISSIONS
set LAST_ERROR=%ERRORLEVEL%

if exist "%TEMP_DIR%\*" rmdir /S /Q "%TEMP_DIR%" >nul 2>nul

exit /b %LAST_ERROR%

rem copy permissions with reset
:COPY_RESET_PERMISSIONS
set "ACL_OLD_FILE=%TEMP_DIR%\system32.acl"
set "ACL_NEW_FILE=%TEMP_DIR%\system64.acl"

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\icacls.exe" "%%SystemRoot%%\System32" /save "%%ACL_OLD_FILE%%" || exit /b

call "%%CONTOOLS_ADMIN_PROJECT_ROOT%%/scripts/Windows/Perm/patch_acl_file.bat" -+ -replace-path System32 System64 -- "%%ACL_OLD_FILE%%" "%%ACL_NEW_FILE%%" || exit /b

rem CAUTION: the owner reset to `*S-1-5-32-544` is required before the `/reset`, otherwise error: `C:\WINDOWS\System64: Access is denied.`
rem call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%USERBIN_SCRIPTS_BAT_ROOT%%/runas/hta/runas-admin-system.bat" "%%SystemRoot%%\System32\icacls.exe" "%%SystemRoot%%\System64" /setowner "*S-1-5-32-544" || exit /b
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%CONTOOLS_UTILS_BIN_ROOT%%/contools/retakeowner.exe" "%%SystemRoot%%\System64" "*S-1-5-32-544" || exit /b

rem CAUTION: the `/reset` is required before the `/restore` in case if the junction point is already existed
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\icacls.exe" "%%SystemRoot%%\System64" /reset /c || exit /b

rem CAUTION: the `/setowner` is required before the `/restore`, otherwise error: `C:\WINDOWS\System64: Access is denied.`
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\icacls.exe" "%%SystemRoot%%\System64" /setowner "NT SERVICE\TrustedInstaller" || exit /b

call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%SystemRoot%%\System32\icacls.exe" "%%SystemRoot%%" /restore "%%ACL_NEW_FILE%%" || exit /b

exit /b 0

:MAKE_LINK_DEFAULT
rem test mklink command existence
call; & mklink /? >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" mklink /J "%%SystemRoot%%\System64" "%%SystemRoot%%\System32" || exit /b
) else exit /b 255

exit /b 0

:MAKE_LINK_WINXP
call "%%CONTOOLS_BUILD_TOOLS_ROOT%%/call.bat" "%%CONTOOLS_SYSINTERNALS_ROOT%%/junction.exe" -nobanner -accepteula "%%SystemRoot%%\System64" "%%SystemRoot%%\System32"
exit /b
