@echo off

setlocal

rem related to this article:
rem   `Telemetry and Data Collection are coming to Windows 7 and Windows 8 too`,
rem   https://winaero.com/blog/telemetry-and-data-collection-are-coming-to-windows-7-and-windows-8-too/
rem

set "CMD_QUIET="
set /P "IS_QUIET=Quiet uninstall? [y/N] "
if "%IS_QUIET%" == "y" set "CMD_QUIET=/quiet"

wusa /uninstall /kb:915597 %CMD_QUIET% /norestart
wusa /uninstall /kb:958830 %CMD_QUIET% /norestart
wusa /uninstall /kb:2505438 %CMD_QUIET% /norestart
wusa /uninstall /kb:2670838 %CMD_QUIET% /norestart
wusa /uninstall /kb:2976978 %CMD_QUIET% /norestart
wusa /uninstall /kb:2977759 %CMD_QUIET% /norestart
wusa /uninstall /kb:3046480 %CMD_QUIET% /norestart
wusa /uninstall /kb:3050267 %CMD_QUIET% /norestart
wusa /uninstall /kb:3058168 %CMD_QUIET% /norestart
wusa /uninstall /kb:3064683 %CMD_QUIET% /norestart
wusa /uninstall /kb:3065988 %CMD_QUIET% /norestart
wusa /uninstall /kb:3072318 %CMD_QUIET% /norestart
wusa /uninstall /kb:3081424 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083325 %CMD_QUIET% /norestart
wusa /uninstall /kb:3083711 %CMD_QUIET% /norestart
wusa /uninstall /kb:3102429 %CMD_QUIET% /norestart
wusa /uninstall /kb:3112343 %CMD_QUIET% /norestart
wusa /uninstall /kb:3115858 %CMD_QUIET% /norestart
wusa /uninstall /kb:3118401 %CMD_QUIET% /norestart
wusa /uninstall /kb:3121255 %CMD_QUIET% /norestart
wusa /uninstall /kb:3122648 %CMD_QUIET% /norestart
wusa /uninstall /kb:3122656 %CMD_QUIET% /norestart
wusa /uninstall /kb:3123862 %CMD_QUIET% /norestart
wusa /uninstall /kb:3124280 %CMD_QUIET% /norestart
wusa /uninstall /kb:3126446 %CMD_QUIET% /norestart
wusa /uninstall /kb:3126593 %CMD_QUIET% /norestart
wusa /uninstall /kb:3127220 %CMD_QUIET% /norestart
wusa /uninstall /kb:3127229 %CMD_QUIET% /norestart
wusa /uninstall /kb:3134214 %CMD_QUIET% /norestart
wusa /uninstall /kb:3134814 %CMD_QUIET% /norestart
wusa /uninstall /kb:3150513 %CMD_QUIET% /norestart
wusa /uninstall /kb:3161102 %CMD_QUIET% /norestart
wusa /uninstall /kb:3163245 %CMD_QUIET% /norestart
wusa /uninstall /kb:3168965 %CMD_QUIET% /norestart
wusa /uninstall /kb:3170106 %CMD_QUIET% /norestart
wusa /uninstall /kb:3170735 %CMD_QUIET% /norestart
wusa /uninstall /kb:3170455 %CMD_QUIET% /norestart
wusa /uninstall /kb:3172605 %CMD_QUIET% /norestart
