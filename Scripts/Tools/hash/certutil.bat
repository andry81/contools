@"%SystemRoot%\System32\certutil.exe" -hashfile %*
@exit /b

rem USAGE:
rem   certutil.bat <file> [<algorithm>]

rem Description:
rem   Certutil wrapper script.

rem <algorithm>:
rem   MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
