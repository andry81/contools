@echo off

rem Description:
rem   Script to free active of the Windows 8/8.1 using `MSGuides.com` site.

rem Windows 8 Core
rem Windows 8 Core Single Language
rem Windows 8 Professional
rem Windows 8 Professional N
rem Windows 8 Professional WMC
rem Windows 8 Enterprise
rem Windows 8 Enterprise N
rem Windows 8.1 Core
rem Windows 8.1 Core N
rem Windows 8.1 Core Single Language
rem Windows 8.1 Professional
rem Windows 8.1 Professional N
rem Windows 8.1 Professional WMC
rem Windows 8.1 Enterprise
rem Windows 8.1 Enterprise N
rem

setlocal

rem scripts must run in administrator mode
call :IS_ADMIN_ELEVATED || (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

goto MAIN

:IS_ADMIN_ELEVATED
if exist "%SystemRoot%\System32\whoami.exe" "%SystemRoot%\System32\whoami.exe" /groups | "%SystemRoot%\System32\find.exe" "S-1-16-12288" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\fltmc.exe" "%SystemRoot%\System32\fltmc.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System64\openfiles.exe" "%SystemRoot%\System64\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\System32\openfiles.exe" "%SystemRoot%\System32\openfiles.exe" >nul 2>nul && exit /b
if exist "%SystemRoot%\system32\config\system" exit /b 0
exit /b 255

:MAIN
echo.Windows 8/8.1 key will be reinstalled.
echo.

timeout /T 10

call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /upk
call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /cpky
wmic os | findstr /I "enterprise" >nul
if %ERRORLEVEL% EQU 0 (
  rem Windows 8.1 Enterprise
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk MHF9N-XY6XB-WVXMC-BTDCT-MKKG7
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk TT4HM-HN7YT-62K67-RGRQJ-JFFXW
  rem Windows 8 Enterprise
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk 32JNW-9KQ84-P47T8-D8GGY-CWCK7
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk JMNMF-RHW7P-DMY6X-RF3DR-X2BQT
) else (
  rem Windows 8.1 Pro
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk GCRJD-8NW9H-F2CDX-CCM8D-9D6T9
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk HMCNV-VVBFX-7HMBH-CTY9B-B4FXY
  rem Windows 8 Pro
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk NG4HW-VH26C-733KW-K6F98-J8CK4
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk XCVCF-2NXM9-723PB-MHCB7-2RYQQ
  rem Windows 8 Core
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk BN3D2-R7TKB-3YPBD-8DRP2-27GG4
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk 2WN2H-YGCQR-KFX6K-CD6TF-84YXQ
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk GNBB8-YVD74-QJHX6-27H4K-8QHDG
  rem Windows 8.1 Core
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk M9Q9P-WNJJT-6PXPY-DWX8H-6XWKK
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk 7B9N3-D94CG-YTVHR-QBPX3-RJP64
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk BB6NG-PQ82V-VRDPW-8XVD2-V8P66
  call :CMD cscript //nologo "C:\Windows\System32\slmgr.vbs" /ipk 789NJ-TQK6T-6XTH8-J39CJ-J8D3P
)

exit /b 0

:CMD
echo.^>%*
(
  %*
)
