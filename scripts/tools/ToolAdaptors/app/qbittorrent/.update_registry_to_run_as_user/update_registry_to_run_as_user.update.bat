@echo off

setlocal

rem prepare variables
set "QBITTORRENT_EXECUTABLE=%QBITTORRENT_EXECUTABLE:/=\%"
set "QBITTORRENT_EXECUTABLE=%QBITTORRENT_EXECUTABLE:\=\\%"

rem remove upon reboot if still exists
if defined TEMP_DIR if exist "%TEMP_DIR%\*" (
  call :CMD "%%CONTOOLS_SYSINTERNALS_ROOT%%/movefile.exe" "%%TEMP_DIR:/=\%%" ""
)

for %%i in (qBittorrent magnet) do (
  if defined FLAG_USE_CALLF_EXECUTABLE (
    call :CMD "%%SystemRoot%%\System32\reg.exe" add "HKLM\SOFTWARE\Classes\%%i\shell\open\command" /ve /t REG_SZ /d "\"%%FLAG_USE_CALLF_EXECUTABLE%%\" /ret-child-exit /no-subst-vars /pause-on-exit \"\" \"runas.exe /user:\\\"${QBITTORRENT_RUN_AS_USER}\\\" \\\"\\\\\\\"%%QBITTORRENT_EXECUTABLE%%\\\\\\\" \\\\\\\"%%%%1\\\\\\\"\\\"\"" /f || exit /b 255
  ) else call :CMD "%%SystemRoot%%\System32\reg.exe" add "HKLM\SOFTWARE\Classes\%%i\shell\open\command" /ve /t REG_EXPAND_SZ /d "runas.exe /user:\"%%%%QBITTORRENT_RUN_AS_USER%%%%\" \"\\\"%%QBITTORRENT_EXECUTABLE%%\\\" \\\"%%%%1\\\"\"" /f || exit /b 255
)

exit /b 0

:CMD
echo;^>%*
(
  %*
)
exit /b
