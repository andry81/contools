@echo off

if not "%PYTHON_INSTALL_PATH%" == "" set "PYTHON_EXEC_PATH=%PYTHON_INSTALL_PATH%\python.exe"
if "%PYTHON_EXEC_PATH%" == "" set "PYTHON_EXEC_PATH=python"

if exist "%~1" (
	"%PYTHON_EXEC_PATH%" "%~dp0/diff_perforce.py" %1 %2
	goto :EOF
)

rem use 3 arguments mode
if exist "%~1=%~2" (
	"%PYTHON_EXEC_PATH%" "%~dp0/diff_perforce.py" "%~1=%~2" %3
	goto :EOF
)

(
	echo %~nx0: error: Unknown arguments format
	echo "%%1 = %~1"
	echo "%%2 = %~2"
	echo "%%3 = %~3"
	echo "%%4 = %~4"
)>&2
pause

rem exit with non zero code
exit /b 254
