@echo off

setlocal

rem Description:
rem   Wrapper to load configuration files directory using `load_config_dir.bat`
rem   script.

rem script flags
set __?FLAG_SHIFT=0
set __?FLAG_FLAGS_SCOPE=0
set "__?BARE_FLAGS="

:FLAGS_LOOP

rem flags always at first
set "__?FLAG=%~1"

if defined __?FLAG ^
if not "%__?FLAG:~0,1%" == "-" set "__?FLAG="

if defined __?FLAG if "%__?FLAG%" == "-+" set /A __?FLAG_FLAGS_SCOPE+=1
if defined __?FLAG if "%__?FLAG%" == "--" set /A __?FLAG_FLAGS_SCOPE-=1

if defined __?FLAG (
  if not "%__?FLAG%" == "-+" if not "%__?FLAG%" == "--" (
    set __?BARE_FLAGS=%__?BARE_FLAGS% %__?FLAG%
  )

  shift
  set /A __?FLAG_SHIFT+=1

  rem read until no flags
  if not "%__?FLAG%" == "--" goto FLAGS_LOOP

  if %__?FLAG_FLAGS_SCOPE% GTR 0 goto FLAGS_LOOP
)

if %__?FLAG_FLAGS_SCOPE% GTR 0 (
  echo;%?~%: error: not ended flags scope: %__?FLAG_FLAGS_SCOPE%
  exit /b -255
) >&2

set "EXPAND_PARAM0="
if %WINDOWS_MAJOR_VER% EQU 5 set "EXPAND_PARAM0=OSWINXP"

rem rem CAUTION:
rem rem   Specific case for Windows XP x64 SP2, where both PROCESSOR_ARCHITECTURE and PROCESSOR_ARCHITEW6432 are equal to AMD64 for 32-bit cmd.exe process!
rem rem
rem set "EXPAND_PARAM1=OS32"
rem if %COMSPEC_X64_VER%0 NEQ 0 set "EXPAND_PARAM1="

rem CAUTION: no execution after this line
endlocal & "%CONTOOLS_ROOT%/build/load_config_dir.bat" -+%__?BARE_FLAGS% -- %1 %2 "%EXPAND_PARAM0%"
