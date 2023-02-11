@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/app/github/backup_bare_all_auth_repos.bat" -checkout %%*
