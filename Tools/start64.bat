@echo off

rem Author:   Andrey Dibrov (andry at inbox dot ru)

rem Description:
rem   Script tryes to call x64 cmd interpreter under x32 process mode if it is
rem   in the Windows x64 environment otherwise it calls a cmd interpreter
rem   under the same process mode (x32 under x32 or x64 under x64).

rem   The "%SystemRoot%\Sysnative" directory doesn't exist on the Windows XP x64
rem   and lower. It can be available only after Windows Vista x64,
rem   Windows Server 2008 x64 or after Windows Server 2003 x64 with installed
rem   "Microsoft hotfix 942589".

rem   For those not server Windows systems or server Windows systems less than
rem   Windows Server 2003 you have to install at least
rem   "Windows Server 2003 Resource Kit Tools" to set the tool "linkd.exe"
rem   available otherwise the script won't work properly.
rem   In the depth the script tryes to map the "%SystemRoot%\Sysnative" path if
rem   doesn't exist yet to the "%SystemRoot%\system32" directory and calls
rem   cmd.exe through the mapped "%SystemRoot%\system32" directory, then that
rem   involves call to the 64bit cmd.exe under the Windows x64 environment or
rem   to the 32bit cmd.exe under the Windows x32 environment (for the datails
rem   search for the article
rem   "Jailed 32-Bit Processes on Windows x64" on the internet).

if "%~1" == "" exit /b -1

if not "%PROCESSOR_ARCHITECTURE%" == "AMD64" goto NOTX64
rem in case of wrong PROCESSOR_ARCHITECTURE value
if not "%PROCESSOR_ARCHITEW6432%" == "" goto NOTX64

call %%*
rem Exit with current error level.
goto :EOF

:NOTX64
rem Workaround:
rem   Last slash character in the path is required otherwise the command
rem   "if not exist" will fail under Windows 7 x64 in the x32 cmd shell!
if not exist "%SystemRoot%\Sysnative\" (
  linkd.exe "%SystemRoot%\Sysnative" "%SystemRoot%\System32"
  "%SystemRoot%\Sysnative\cmd.exe" /c %*
  linkd.exe "%SystemRoot%\Sysnative" /d
) else (
  "%SystemRoot%\Sysnative\cmd.exe" /c %*
)
