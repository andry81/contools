@call "%%~dp0..\..\__init__\script_init.bat" %%* || exit /b

@call "%%~dp0__init__.bat" || exit /b
