@echo off

setlocal

"%SystemRoot%\System64\cmd.exe" /D /c echo %%PROCESSOR_ARCHITECTURE%% ^& ( if defined PROCESSOR_ARCHITECTURE if not "%%PROCESSOR_ARCHITECTURE:64=%%" == "%%PROCESSOR_ARCHITECTURE%%" exit /b 0 ) ^& exit /b 255 && echo 1 || echo 0
