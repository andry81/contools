@echo off & goto DOC_END

rem Description:
rem   Script creates `System64` directory additionally to the `Sysnative`,
rem   because:
rem     1. The `Sysnative/cmd.exe` can not be run under the Administrator user.
rem     2. The `Sysnative` directory visible ONLY from 64-bit applications.
rem     3. The `Sysnative` directory doesn't exist on the Windows XP x64 and
rem        lower.

rem Note:
rem   The `Sysnative` directory can be available only after Windows Vista x64,
rem   Windows Server 2008 x64 or after Windows Server 2003 x64 with installed
rem   "Microsoft hotfix 942589".
rem
rem   For those not server Windows systems or server Windows systems less than
rem   Windows Server 2003 you have to install at least
rem   "Windows Server 2003 Resource Kit Tools" to set the tool "linkd.exe"
rem   available otherwise the script won't work properly.
:DOC_END

setlocal

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

rem drop last error
call;

if not defined CONTOOLS_ROOT (
  echo;%?~%: error: CONTOOLS_ROOT variable is not defined.
  exit /b 1
) >&2

if not exist "%CONTOOLS_ROOT%\*" (
  echo;%?~%: error: CONTOOLS_ROOT directory does not exist: "%CONTOOLS_ROOT%".
  exit /b 2
) >&2

rem Because we have to attempt to create a directory in the system directory, then we have to do it with administrative permissions only.
rem Because the `System32` directory should not be redirected at the moment of creation (linkage), then we have to do it in the 64-bit mode only.

rem test mklink command existence
mklink /? >nul 2>nul
if %ERRORLEVEL% EQU 0 goto MKLINK
if exist "linkd.exe" goto LINKD

(
  echo;%?~%: error: can not create `%SYSTEMROOT%\System64` directory
  exit /b 255
) >&2


:MKLINK
if not exist "%SYSTEMROOT%\System64\*" (
  if /i "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    rem already in the 64-bit mode
    call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/cmd_admin.lnk" /C @mklink /D "%%SystemRoot%%\System64" "%%SystemRoot%%\System32" || exit /b
  ) else if defined PROCESSOR_ARCHITEW6432 (
    rem in WOW64 mode
    call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/cmd_wow64_admin.lnk" /C @mklink /D "%%SystemRoot%%\System64" "%%SystemRoot%%\System32" || exit /b
  )
)

exit /b 0

:LINKD
if not exist "%SYSTEMROOT%\System64\*" (
  if /i "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
    rem already in the 64-bit mode
    call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/cmd_admin.lnk" /C @linkd.exe "%%SystemRoot%%\System64" "%%SystemRoot%%\System32" || exit /b
  ) else if defined PROCESSOR_ARCHITEW6432 (
    rem in WOW64 mode
    call "%%CONTOOLS_ROOT%%/ToolAdaptors/lnk/cmd_wow64_admin.lnk" /C @linkd.exe "%%SystemRoot%%\System64" "%%SystemRoot%%\System32" || exit /b
  )
)

exit /b 0
