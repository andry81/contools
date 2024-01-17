@echo off

rem USAGE
rem   winsxs_cleanup.bat <output-archive-file>

rem Description
rem   Script to cleanup windows `WinSxS` directory by extracting potentially
rem   not used previous versions of subdirectories using `*_<version>_*`
rem   pattern. And using 7zip to archive and remove them.
rem
rem   The script is based on:
rem     https://gist.github.com/neremin/9c6905a0faedc98c6170153d56ee07b1
rem     https://woshub.com/how-to-clean-up-and-compress-winsxs-folder-in-windows-8/
rem
rem   It is useful where the `DISM` utility is limited or ineffective to
rem   cleanup `WinSxS` directory under Windows 7.
rem
rem   PROs:
rem     * Can reduce the size of `WinSxS` even more than the original script.
rem       Original script with compress (Windows 7):
rem         10Gb -> ~7Gb (~x1.4 ratio)
rem       Method with `clearmgr` (Windows 8):
rem         16Gb -> ~7Gb (~x2.3 ratio)
rem       This script (Windows 7):
rem         10Gb -> ~3GB (~x3 ratio)
rem     * If some programs is broken after the script, then you can use
rem       `winsxs_enter.bat` and `winsxs_leave.bat` to manually stop/start
rem       services and grant/revoke permissions. This may help to restore
rem       archived directories back and test broken software.
rem     * Much more faster than the legal method with the `cleanmgr` and the
rem       `DISM` because does not check anything and removes directories
rem       directly.
rem
rem   CONs:
rem     * Nevertheless the functionality of some programs may be broken after
rem       that if an application is rely on previous versions of a component.
rem     * To grant the access to the WinSxS the original script does consume
rem       much time to change the permissions and revert them back at the end.
rem     * You have to allocate some space for the archive with extracted
rem       content.
rem

rem   SCRIPT ISSUES:
rem     * Does not remove files or other content, only subdirectories of
rem       `WinSxS` directory by archiving them somethere outside. So the
rem       Windows component database might be left desynchronized with the
rem       `WinSxS` directory.
rem     * `winsxs_enter.bat` and `winsxs_leave.bat` scripts does not fix
rem       directory permissions of restored directories (extracted back).
rem       You must issue respective commands manually to restore these
rem       permissions using the ACL list file from the `.log` subdirectory in
rem       the output archive.

rem <output-archive-file>:
rem  Output archive file path.
rem

setlocal

if %IMPL_MODE%0 NEQ 0 goto IMPL

call "%%~dp0__init__/__init__.bat" || exit /b

call "%%CONTOOLS_PROJECT_ROOT%%/__init__/declare_builtins.bat" %%0 %%* || exit /b

call "%%CONTOOLS_ROOT%%/build/init_project_log.bat" "%%?~n0%%" || exit /b

call "%%CONTOOLS_ROOT%%/build/init_vars_file.bat" || exit /b

call "%%CONTOOLS_ROOT%%/exec/exec_callf_prefix.bat" -Y /pause-on-exit -elevate winsxs_cleanup -- %%*
exit /b

:IMPL
rem CAUTION: We must to reinit the builtin variables in case if `IMPL_MODE` was already setup outside.
call "%%CONTOOLS_ROOT%%/std/declare_builtins.bat" %%0 %%* || exit /b

rem check for true elevated environment
"%SystemRoot%\System32\net.exe" session >nul 2>nul || (
  echo.%?~nx0%: error: the script process is not properly elevated up to Administrator privileges.
  exit /b 255
) >&2

rem load initialization environment variables
if defined INIT_VARS_FILE call "%%CONTOOLS_ROOT%%/std/set_vars_from_file.bat" "%%INIT_VARS_FILE%%"

rem Under WOW64 (32-bit process in 64-bit Windows) restart script in 64-bit mode
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto X64
if not defined PROCESSOR_ARCHITEW6432 goto X32

rem restart in x64
if exist "%SystemRoot%\Sysnative\*" (
  call :CMD "%%SystemRoot%%\Sysnative\cmd.exe" /C @%%0 %%*
  exit /b
)

(
  echo.%~nx0: error: run script in 64-bit console ONLY!
  exit /b 255
) >&2

:X64
:X32

set "OUTPUT_ARCHIVE_FILE=%~1"

if not defined OUTPUT_ARCHIVE_FILE (
  echo.%~nx0: error: OUTPUT_ARCHIVE_FILE is not defined.
  exit /b 255
) >&2

for /F "eol= tokens=* delims=" %%i in ("%OUTPUT_ARCHIVE_FILE%\.") do ( set "OUTPUT_ARCHIVE_DIR=%%~dpi" & set "OUTPUT_ARCHIVE_FILE=%%~fi" )

set "OUTPUT_ARCHIVE_DIR=%OUTPUT_ARCHIVE_DIR:~0,-1%"

if not exist "%OUTPUT_ARCHIVE_DIR%\*" (
  echo.%~nx0: error: OUTPUT_ARCHIVE_DIR directory path does not exist: "%OUTPUT_ARCHIVE_DIR%".
  exit /b 255
) >&2

if exist "%OUTPUT_ARCHIVE_FILE%" (
  echo.%~nx0: error: OUTPUT_ARCHIVE_FILE file path must not exist: "%OUTPUT_ARCHIVE_FILE%".
  exit /b 255
) >&2

echo 1. Scanning WinSxS directory...

dir /A:D /B /O:N "%SystemRoot%\WinSxS\*" | findstr /R /C:".*_[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*_.*" > "%PROJECT_LOG_DIR%\winsxs_1_dirs.lst"

echo 2. Extracting WinSxS directory components...

"%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -r -b -e "s|^(.+)_([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*)_(.+)_([^\r\n]+)|\2\|\3\|\4\|\1|mg" "%PROJECT_LOG_DIR%\winsxs_1_dirs.lst" > "%PROJECT_LOG_DIR%\winsxs_2_comps.lst" || exit /b

echo 3. Generating WinSxS remove candidates...

setlocal ENABLEDELAYEDEXPANSION

set "PREV_VER="

(
  for /F "usebackq eol=# tokens=1,2,3,* delims=|" %%a in ("%PROJECT_LOG_DIR%\winsxs_2_comps.lst") do for /F "eol= tokens=1,2,3,* delims=." %%i in ("%%a") do (
    if defined PREV_VER (
      if "!PREV_COMPONENT!|!PREV_LANG!" == "%%d|%%b" (
        if "!PREV_MAJOR_VER!" == "%%i" (
          if "!PREV_MINOR_VER!" == "%%j" (
            if "!PREV_BUILD_NUM!" == "%%k" (
              if %%l LSS PREV_REV_NUM (
                echo.-^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
              ) else echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
            ) else if %%k LSS PREV_BUILD_NUM (
              echo.-^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
            ) else echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
          ) else if %%j LSS PREV_MINOR_VER (
            echo.-^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
          ) else echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
        ) else if %%i LSS PREV_MAJOR_VER (
          echo.-^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
        ) else echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
      ) else echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
    )
    set "PREV_VER=%%a"
    set "PREV_MAJOR_VER=%%i"
    set "PREV_MINOR_VER=%%j"
    set "PREV_BUILD_NUM=%%k"
    set "PREV_REV_NUM=%%l"
    set "PREV_LANG=%%b"
    set "PREV_SUFFIX=%%c
    set "PREV_COMPONENT=%%d
  )
) >> "%PROJECT_LOG_DIR%\winsxs_3_filter.lst"

rem last component
(
  echo. ^|!PREV_VER!^|!PREV_LANG!^|!PREV_SUFFIX!^|!PREV_COMPONENT!
) >> "%PROJECT_LOG_DIR%\winsxs_3_filter.lst"

echo 4. Generating WinSxS includes list...

findstr /B /L /C:"-|" "%PROJECT_LOG_DIR%\winsxs_3_filter.lst" | "%CONTOOLS_GNUWIN32_ROOT%/bin/sed.exe" -r -e "s|^-[|](.+)[|](.+)[|](.+)[|]([^\r\n]+)|\4_\1_\2_\3\*|mg" > "%PROJECT_LOG_DIR%\winsxs_4_files.lst"

echo 5. Copy WinSxS manifest files...

mkdir "%PROJECT_LOG_DIR%\Manifests"

for /F "usebackq eol=# tokens=* delims=" %%i in ("%PROJECT_LOG_DIR%\winsxs_4_files.lst") do (
  copy /Y /B "%SystemRoot%\WinSxS\Manifests\%%i" "%PROJECT_LOG_DIR%\Manifests\*.*"
)

exit /b

:CMD
echo.^>%*
(
  %*
)
exit /b
