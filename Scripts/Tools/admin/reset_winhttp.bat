@echo off

setlocal

echo.CAUTION: PROXY RESET WILL REMOVE PROXY AND WINDOWS UPDATE BITS SERVICE WILL DOWNLOAD WITHOUT PROXY!!!
echo.         YOU MUST SET PROXY CONFIGURATION ^(INCLUDING AUTHETIFICATION^) IMMEDIATELY AFTER PROXY RESET IF YOU HAVE A PROXY.
echo.         OTHERWISE INTERNET EXPLORER PROXY SETTINGS WON'T BE USED BY THE WINDOWS UPDATE BITS SERVICE EVEN IF SET!!!

call "%%~dp0reg_ie_proxy.bat"

call :CMD netsh winhttp reset proxy
call :CMD netsh winhttp import proxy source=ie

exit /b

:CMD
echo.^>%*
(
  %*
)
