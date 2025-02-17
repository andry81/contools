@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

rem Dik Coates
rem `These are some others I have in my batch file; I’m not sure what they do, but, have picked them up over the last year or so.`
rem

setlocal

call "%%~dp0..\__init__\__init__.bat"

if 0%IMPL_MODE% NEQ 0 goto IMPL
"%CONTOOLS_TOOL_ADAPTORS_ROOT%/hta/cmd_admin.bat" /c @set "IMPL_MODE=1" ^& "%~f0" %*
exit /b

:IMPL
call "%%CONTOOLS_ROOT%%/std/is_admin_elevated.bat" || (
  echo.%~nx0: error: process must be Administrator account elevated to continue.
  exit /b 255
) >&2

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /c %%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY (in administrative mode)!
  exit /b 255
) >&2

:X64
:X32

set "CMD_QUIET="
set /P "IS_QUIET=Quiet uninstall? [y/N] "
if "%IS_QUIET%" == "y" set "CMD_QUIET=/quiet"

echo Uninstalling KB915597
wusa /uninstall /kb:915597 %CMD_QUIET% /norestart
echo Uninstalling KB958830
wusa /uninstall /kb:958830 %CMD_QUIET% /norestart
echo Uninstalling KB2505438
wusa /uninstall /kb:2505438 %CMD_QUIET% /norestart
echo Uninstalling KB2670838 (Internet Explorer 10)
wusa /uninstall /kb:2670838 %CMD_QUIET% /norestart
echo Uninstalling KB2976978
wusa /uninstall /kb:2976978 %CMD_QUIET% /norestart
echo Uninstalling KB2977759
wusa /uninstall /kb:2977759 %CMD_QUIET% /norestart
echo Uninstalling KB3046480
wusa /uninstall /kb:3046480 %CMD_QUIET% /norestart
echo Uninstalling KB3050267
wusa /uninstall /kb:3050267 %CMD_QUIET% /norestart
echo Uninstalling KB3058168
wusa /uninstall /kb:3058168 %CMD_QUIET% /norestart
echo Uninstalling KB3064683
wusa /uninstall /kb:3064683 %CMD_QUIET% /norestart
echo Uninstalling KB3065988
wusa /uninstall /kb:3065988 %CMD_QUIET% /norestart
echo Uninstalling KB3072318
wusa /uninstall /kb:3072318 %CMD_QUIET% /norestart
echo Uninstalling KB3081424
wusa /uninstall /kb:3081424 %CMD_QUIET% /norestart
echo Uninstalling KB3083325
wusa /uninstall /kb:3083325 %CMD_QUIET% /norestart
echo Uninstalling KB3083711
wusa /uninstall /kb:3083711 %CMD_QUIET% /norestart
echo Uninstalling KB3102429 (Azerbaijani Manat and Georgian Lari currency symbols)
wusa /uninstall /kb:3102429 %CMD_QUIET% /norestart
echo Uninstalling KB3112343
wusa /uninstall /kb:3112343 %CMD_QUIET% /norestart
echo Uninstalling KB3115858
wusa /uninstall /kb:3115858 %CMD_QUIET% /norestart
echo Uninstalling KB3118401 (Visual Studio 2015 related)
wusa /uninstall /kb:3118401 %CMD_QUIET% /norestart
echo Uninstalling KB3121255
wusa /uninstall /kb:3121255 %CMD_QUIET% /norestart
echo Uninstalling KB3122648 (Security Update for .NET Framework to Address Denial of Service (3137893): Security Update for Microsoft .NET Framework 3.5.1 on Windows 7 Service Pack 1 and Windows Server 2008 R2 Service Pack 1 (KB3122648), MS16-019)
wusa /uninstall /kb:3122648 %CMD_QUIET% /norestart
echo Uninstalling KB3122656
wusa /uninstall /kb:3122656 %CMD_QUIET% /norestart
echo Uninstalling KB3123862
wusa /uninstall /kb:3123862 %CMD_QUIET% /norestart
echo Uninstalling KB3124280
wusa /uninstall /kb:3124280 %CMD_QUIET% /norestart
echo Uninstalling KB3126446
wusa /uninstall /kb:3126446 %CMD_QUIET% /norestart
echo Uninstalling KB3126593
wusa /uninstall /kb:3126593 %CMD_QUIET% /norestart
echo Uninstalling KB3127220 (Security Update for .NET Framework to Address Denial of Service (3137893): Security Update for Microsoft .NET Framework 3.5.1 on Windows 7 Service Pack 1 and Windows Server 2008 R2 Service Pack 1 (KB3127220), MS16-019)
wusa /uninstall /kb:3127220 %CMD_QUIET% /norestart
echo Uninstalling KB3127229
wusa /uninstall /kb:3127229 %CMD_QUIET% /norestart
echo Uninstalling KB3134214
wusa /uninstall /kb:3134214 %CMD_QUIET% /norestart
echo Uninstalling KB3134814
wusa /uninstall /kb:3134814 %CMD_QUIET% /norestart
echo Uninstalling KB3150513
wusa /uninstall /kb:3150513 %CMD_QUIET% /norestart
echo Uninstalling KB3161102 (Update for Windows Journal component removal)
wusa /uninstall /kb:3161102 %CMD_QUIET% /norestart
echo Uninstalling KB3163245
wusa /uninstall /kb:3163245 %CMD_QUIET% /norestart
echo Uninstalling KB3168965
wusa /uninstall /kb:3168965 %CMD_QUIET% /norestart
echo Uninstalling KB3170106
wusa /uninstall /kb:3170106 %CMD_QUIET% /norestart
echo Uninstalling KB3170735
wusa /uninstall /kb:3170735 %CMD_QUIET% /norestart
echo Uninstalling KB3170455
wusa /uninstall /kb:3170455 %CMD_QUIET% /norestart
echo Uninstalling KB3172605
wusa /uninstall /kb:3172605 %CMD_QUIET% /norestart
