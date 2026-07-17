<!-- : bat in wsf skip

@echo off & goto DOC_END

rem USAGE:
rem   touch_file.bat <path>...

rem Description:
rem   The `touch` command analog for files, with echo and some conditions check
rem   before call.
rem
rem   Does support long paths.
rem
rem   NOTE:
rem     All input paths must be without `\\?\` prefix because:
rem       1. Can be directly used in commands which does not support long paths
rem          like builtin `dir` command.
rem       2. Can be checked on absence of globbing characters which includes
rem          `?` character.
rem       3. The `%%~f` builtin variables extension and other extensions does
rem          remove the prefix and then a path can be prefixed internally by
rem          the script.
rem
rem   Partially based on this:
rem     https://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764725#764725

rem CAUTION:
rem   The `copy`, `move` and `rename` commands does not process files with the
rem   hidden attribute.
rem   The `attrib.exe -r` does not reset the Read-Only attribute from hidden
rem   files.

rem CAUTION:
rem   The `... >> \\?\...` nor `copy \\?\...` does not support long file paths to an existed file.
rem   So we test on a long file path existence and if a long path, then move the file to a temporary directory,
rem   touch it and move back.

rem CAUTION:
rem   If the file were deleted before, then the creation date will be set by `... >> ...` from the previously deleted file!

rem CAUTION:
rem   The `... >> ...` does not work as expected on Windows XP.

rem TODO: Windows XP `robocopy` workaround

rem <path>...
rem   File path list.
:DOC_END

if %CONTOOLS_VERBOSE%0 NEQ 0 echo;^>%~nx0 %*

setlocal

set "?~dp0=%~dp0"
set "?~n0=%~n0"

rem script names call stack
if defined ?~ ( set "?~=%?~%-^>%~nx0" ) else if defined ?~nx0 ( set "?~=%?~nx0%-^>%~nx0" ) else set "?~=%~nx0"

set "?~f0=%~f0%"

set "FILE_PATH=%~1"
set FILE_COUNT=1

if not defined FILE_PATH (
  echo;%?~%: error: at least one file path argument must be defined.
  exit /b -255
) >&2

call "%%?~dp0%%__init__.bat" || exit /b

:TOUCH_FILE_LOOP

set "FILE_PATH=%FILE_PATH:/=\%"

if "%FILE_PATH:~0,4%" == "\\?\" set "FILE_PATH=%FILE_PATH:~4%"

rem check on missed components...

rem ...forwarding `\` character
if "\" == "%FILE_PATH:~0,1%" goto FILE_PATH_ERROR

rem ...double `\\` character
if not "%FILE_PATH%" == "%FILE_PATH:\\=\%" goto FILE_PATH_ERROR

rem ...trailing `\` character
if "\" == "%FILE_PATH:~-1%" goto FILE_PATH_ERROR

rem check on invalid characters in path
if not "%FILE_PATH%" == "%FILE_PATH:**=%" goto FILE_PATH_ERROR
if not "%FILE_PATH%" == "%FILE_PATH:?=%" goto FILE_PATH_ERROR
if not "%FILE_PATH%" == "%FILE_PATH:<=%" goto FILE_PATH_ERROR
if not "%FILE_PATH%" == "%FILE_PATH:>=%" goto FILE_PATH_ERROR

goto FILE_PATH_OK

:FILE_PATH_ERROR
(
  echo;%?~%: error: file path is invalid: ARG=%FILE_COUNT% FILE_PATH="%FILE_PATH%".
  exit /b -254
) >&2

:FILE_PATH_OK

for /F "tokens=* delims="eol^= %%i in ("%FILE_PATH%\.") do ^
for /F "tokens=* delims="eol^= %%j in ("%%~dpi.") do set "FILE_PATH=%%~fi" & set "FILE_DIR=%%~fj" & set "FILE_NAME=%%~nxi"

if exist "\\?\%FILE_PATH%\*" (
  echo;%?~%: error: file path is a directory: "%FILE_PATH%".
  goto CONTINUE
) >&2

if not exist "\\?\%FILE_DIR%\*" (
  echo;%?~%: error: directory does not exist: "%FILE_DIR%".
  goto CONTINUE
) >&2

set "FILE_ATTR=."

if not exist "\\?\%FILE_PATH%" call;> "\\?\%FILE_PATH%" & goto CONTINUE

for /F "tokens=* delims="eol^= %%i in ("\\?\%FILE_PATH%") do set "FILE_ATTR=%%~ai"

if not defined FILE_ATTR set "FILE_ATTR=."

rem check on long file path
set FILE_PATH_LONG=1
if exist "%FILE_PATH%" call "%%CONTOOLS_ROOT%%/std/is_str_shorter_than.bat" 259 "%%FILE_PATH%%" && set FILE_PATH_LONG=0

if %FILE_PATH_LONG% NEQ 0 if exist "%SystemRoot%\System32\robocopy.exe" goto MOVE_TO_TMP

if %FILE_PATH_LONG% EQU 0 (
  if "%FILE_ATTR%" == "%FILE_ATTR:h=%" (
    if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
      copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul
    ) else (
      "%SystemRoot%\System32\attrib.exe" -r "%FILE_PATH%" >nul & copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul & "%SystemRoot%\System32\attrib.exe" +r "%FILE_PATH%" >nul
    )
  ) else (
    if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
      "%SystemRoot%\System32\attrib.exe" -h "%FILE_PATH%" >nul & copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul & "%SystemRoot%\System32\attrib.exe" +h "%FILE_PATH%" >nul
    ) else (
      "%SystemRoot%\System32\attrib.exe" -r -h "%FILE_PATH%" >nul & copy /B "%FILE_PATH%"+,, "%FILE_PATH%" >nul & "%SystemRoot%\System32\attrib.exe" +r +h "%FILE_PATH%" >nul
    )
  )
) else "%SystemRoot%\System32\cscript.exe" //NOLOGO //JOB:TOUCH_FILE "%?~f0%?.wsf" "\\?\%FILE_PATH%"

goto CONTINUE

:MOVE_TO_TMP

if defined SCRIPT_TEMP_CURRENT_DIR (
  set "FILE_PATH_TEMP_DIR=%SCRIPT_TEMP_CURRENT_DIR%\%?~n0%.%RANDOM%-%RANDOM%"
) else set "FILE_PATH_TEMP_DIR=%TEMP%\%?~n0%.%RANDOM%-%RANDOM%"

"%SystemRoot%\System32\robocopy.exe" "%FILE_DIR%" "%FILE_PATH_TEMP_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

if "%FILE_ATTR%" == "%FILE_ATTR:h=%" (
  if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
    copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
  ) else (
    "%SystemRoot%\System32\attrib.exe" -r "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & "%SystemRoot%\System32\attrib.exe" +r "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
  )
) else (
  if "%FILE_ATTR%" == "%FILE_ATTR:r=%" (
    "%SystemRoot%\System32\attrib.exe" -h "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & "%SystemRoot%\System32\attrib.exe" +h "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
  ) else (
    "%SystemRoot%\System32\attrib.exe" -r -h "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & copy /B "%FILE_PATH_TEMP_DIR%\%FILE_NAME%"+,, "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul & "%SystemRoot%\System32\attrib.exe" +r +h "%FILE_PATH_TEMP_DIR%\%FILE_NAME%" >nul
  )
)

"%SystemRoot%\System32\robocopy.exe" "%FILE_PATH_TEMP_DIR%" "%FILE_DIR%" "%FILE_NAME%" /R:0 /W:0 /NP /NJH /NS /NC /XX /XO /XC /XN /MOV >nul

rmdir /S /Q "%FILE_PATH_TEMP_DIR%" >nul 2>nul

:CONTINUE

shift

set "FILE_PATH=%~1"

if "%FILE_PATH%" == "" exit /b 0

set /A FILE_COUNT+=1

goto TOUCH_FILE_LOOP

rem end of bat -->

<package>
  <job id="TOUCH_FILE">
    <script language="VBScript">
      ' Description:
      '   Shell based script to be able to touch file by paths longer than 260+ characters.
      '
      ' USAGE:
      '   ... "\\?\<absolute-canonical-file-path-to-file>"
      '
      '   , where (!) <absolute-canonical-file-path-to-file>: is an absolute file path separated with the backslash character ONLY - `\`
      '

      Function GetFile(PathAbs)
        ' WORKAROUND:
        '   We use `\\?\` to bypass `GetFile` error: `File not found`.
        If Not Left(PathAbs, 2) = "\\" Then
          Set GetFile = objFS.GetFile("\\?\" & PathAbs)
        Else
          Set GetFile = objFS.GetFile(PathAbs)
        End If
      End Function

      Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")
      Dim PathAbs : PathAbs = objFS.GetAbsolutePathName(WScript.Arguments(0))

      ' remove Read-Only and Hidden file attributes

      Dim RestoreFileAttr : RestoreFileAttr = 0

      Dim objFile : Set objFile = GetFile(PathAbs)
      Dim fileAttr : fileAttr = objFile.Attributes

      Const ReadOnly = 1
      Const Hidden = 2

      If objFile.Attributes And (ReadOnly Or Hidden) Then
        RestoreFileAttr = 1
        objFile.Attributes = objFile.Attributes And Not(ReadOnly Or Hidden)
        On Error Resume Next ' continue on error
      End If

      Set objTextFile = objFS.OpenTextFile(WScript.Arguments(0), 2)

      ' restore
      If RestoreFileAttr Then
        objFile.Attributes = objFile.Attributes Or fileAttr
      End If

      objTextFile.Close
    </script>
  </job>
</package>
