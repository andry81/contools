<!-- : bat in wsf skip

@echo off & goto DOC_END

rem USAGE:
rem   wait_dir_write_access.bat <dir-path> [<wait-timeout-msec>|-1]

rem Description:
rem   Awaits a directory for a write access permission excluding
rem   subdirectories.
rem   Minimum wait timeout can not be less than 20 msec to reduce CPU
rem   consumption.

rem Pros:
rem   * Awaits on a directory write access privilege.
rem   * Awaits on deny write access privilege change like
rem     `Everyone Deny Access` removement.
rem   * Awaits on a parent directory write access privilege in case of
rem     privileges inheritance.
rem   * Does not wait a parent directory write access privilege if a directory
rem     already has an exclusive not inherited write access privilege.
rem   * Does not wait on a path if has permissions to read a path as a
rem     file.
rem   * Does support long paths.
rem   * Can busy wait on a specified timeout in milliseconds between checks.

rem Cons:
rem   * Does not support directories in nested directories including
rem     subdirectories in `<dir-path>` directory.
:DOC_END

setlocal

if "%~1" == "" exit /b 0

for /F "tokens=* delims=" %%i in ("%~1\.") do set "FILE_PATH=%%~fi"
for /F "tokens=* delims=" %%i in ("\\?\%FILE_PATH%") do set "FILE_PATH_ATTR=%%~ai"

if not defined FILE_PATH_ATTR exit /b 255
if /i not "%FILE_PATH_ATTR:~0,1%" == "d" exit /b 255

set "FILE_NAME_TMP=.%~n0.%RANDOM%-%RANDOM%.tmp"

if not "%~2" == "" if %~20 LSS 0 (
  ( call;> "\\?\%FILE_PATH%\%FILE_NAME_TMP%" ) 2>nul || exit /b 1
  "%SystemRoot%\System32\cscript.exe" //NOLOGO //JOB:DELETE_FILE "%~f0?.wsf" "\\?\%FILE_PATH%\%FILE_NAME_TMP%"
  exit /b 0
)

:FILE_WRITE_LOOP
( call;> "\\?\%FILE_PATH%\%FILE_NAME_TMP%" ) 2>nul || ( call "%%~dp0busy_wait.bat" %%2 & goto FILE_WRITE_LOOP )
"%SystemRoot%\System32\cscript.exe" //NOLOGO //JOB:DELETE_FILE "%~f0?.wsf" "\\?\%FILE_PATH%\%FILE_NAME_TMP%"
exit /b 0

rem end of bat -->

<package>
  <job id="DELETE_FILE">
    <script language="VBScript">
      ' Description:
      '   Shell based script to be able to delete file by paths longer than 260+ characters.
      '
      ' USAGE:
      '   ... "\\?\<absolute-canonical-file-path-to-file>"
      '
      '   , where (!) <absolute-canonical-file-path-to-file>: is an absolute file path separated with the backslash character ONLY - `\`
      '

      Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")
      objFS.DeleteFile WScript.Arguments(0)
    </script>
  </job>
</package>
