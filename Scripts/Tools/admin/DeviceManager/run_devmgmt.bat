@echo off

rem Script runs Device Manager in administrator mode with enabled show of
rem nonpresent devices.
rem The `hidden devices` must be enabled from the Device Manager menu to show
rem inactive Network Adapters to uninstall them.

setlocal

rem scripts must run in administrator mode
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo.%~nx0: error: run script in administrator mode!
  exit /b -255
) >&2

set DEVMGR_SHOW_NONPRESENT_DEVICES=1

devmgmt.msc
