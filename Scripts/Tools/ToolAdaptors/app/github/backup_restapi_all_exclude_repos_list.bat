@echo off

setlocal

call "%%~dp0__init__\__init__.bat" || exit /b

call "%%CONTOOLS_TOOL_ADAPTORS_ROOT%%/app/github/backup_restapi_all.bat" -skip-auth-repo-list -skip-account-lists %%*
