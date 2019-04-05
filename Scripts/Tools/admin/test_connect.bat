@echo off

setlocal

set "DOMAIN=%~1"
set "PORT=%~2"

if not defined DOMAIN (
  echo.%~nx0: error: DOMAIN is not defined.
  exit /b 127
) >&2

if not defined PORT (
  echo.%~nx0: error: PORT is not defined.
  exit /b 128
) >&2

echo.$connection = (New-Object Net.Sockets.TcpClient).Connect("%DOMAIN%", %PORT%); If ($connection.Connected) { $connection.Close(); } | powershell -Command -
