@echo off

setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_ROOT%%/std/assert_if_def.bat" __CTRL_SETLOCAL "error: cmd.exe is broken, please restart it!" && set "__CTRL_SETLOCAL=1"
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call :TEST config.bin "_common/00_ascii" "00_ascii_00_FF" ^
  -s ^
  -r "$/\x00$/\x01$/\x02$/\x03$/\x04$/\x05$/\x06$/\x07$/\x08$/\x09$/\x0A$/\x0B$/\x0C$/\x0D$/\x0E$/\x0F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x10$/\x11$/\x12$/\x13$/\x14$/\x15$/\x16$/\x17$/\x18$/\x19$/\x1A$/\x1B$/\x1C$/\x1D$/\x1E$/\x1F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x20$/\x21$/\x22$/\x23$/\x24$/\x25$/\x26$/\x27$/\x28$/\x29$/\x2A$/\x2B$/\x2C$/\x2D$/\x2E$/\x2F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x30$/\x31$/\x32$/\x33$/\x34$/\x35$/\x36$/\x37$/\x38$/\x39$/\x3A$/\x3B$/\x3C$/\x3D$/\x3E$/\x3F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x40$/\x41$/\x42$/\x43$/\x44$/\x45$/\x46$/\x47$/\x48$/\x49$/\x4A$/\x4B$/\x4C$/\x4D$/\x4E$/\x4F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x50$/\x51$/\x52$/\x53$/\x54$/\x55$/\x56$/\x57$/\x58$/\x59$/\x5A$/\x5B$/\x5C$/\x5D$/\x5E$/\x5F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x60$/\x61$/\x62$/\x63$/\x64$/\x65$/\x66$/\x67$/\x68$/\x69$/\x6A$/\x6B$/\x6C$/\x6D$/\x6E$/\x6F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x70$/\x71$/\x72$/\x73$/\x74$/\x75$/\x76$/\x77$/\x78$/\x79$/\x7A$/\x7B$/\x7C$/\x7D$/\x7E$/\x7F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x80$/\x81$/\x82$/\x83$/\x84$/\x85$/\x86$/\x87$/\x88$/\x89$/\x8A$/\x8B$/\x8C$/\x8D$/\x8E$/\x8F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x90$/\x91$/\x92$/\x93$/\x94$/\x95$/\x96$/\x97$/\x98$/\x99$/\x9A$/\x9B$/\x9C$/\x9D$/\x9E$/\x9F" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xA0$/\xA1$/\xA2$/\xA3$/\xA4$/\xA5$/\xA6$/\xA7$/\xA8$/\xA9$/\xAA$/\xAB$/\xAC$/\xAD$/\xAE$/\xAF" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xB0$/\xB1$/\xB2$/\xB3$/\xB4$/\xB5$/\xB6$/\xB7$/\xB8$/\xB9$/\xBA$/\xBB$/\xBC$/\xBD$/\xBE$/\xBF" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xC0$/\xC1$/\xC2$/\xC3$/\xC4$/\xC5$/\xC6$/\xC7$/\xC8$/\xC9$/\xCA$/\xCB$/\xCC$/\xCD$/\xCE$/\xCF" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xD0$/\xD1$/\xD2$/\xD3$/\xD4$/\xD5$/\xD6$/\xD7$/\xD8$/\xD9$/\xDA$/\xDB$/\xDC$/\xDD$/\xDE$/\xDF" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xE0$/\xE1$/\xE2$/\xE3$/\xE4$/\xE5$/\xE6$/\xE7$/\xE8$/\xE9$/\xEA$/\xEB$/\xEC$/\xED$/\xEE$/\xEF" "XXXXXXXXXXXXXXXX" ^
  -r "$/\xF0$/\xF1$/\xF2$/\xF3$/\xF4$/\xF5$/\xF6$/\xF7$/\xF8$/\xF9$/\xFA$/\xFB$/\xFC$/\xFD$/\xFE$/\xFF" "XXXXXXXXXXXXXXXX"

setlocal DISABLEDELAYEDEXPANSION

rem CAUTION:
rem   NUL (00) and SUB (1A) characters can not be quote-escaped

call :TEST config.bin "_common/00_ascii" "01_ascii_00_7F" ^
  -s ^
  -r "$/\x00	$/\x0A$/\x0D" "XXXXXXXXXXXXXXXX" ^
  -r "$/\x1A"    "XXXXXXXXXXXXXXXX" ^
  -r ""                    "XXXXXXXXXXXXXXXX" ^
  -r " !$/\x22#$%%%%&'()*+,-./" "XXXXXXXXXXXXXXXX" ^
  -r "0123456789:;<=>?"         "XXXXXXXXXXXXXXXX" ^
  -r "@ABCDEFGHIJKLMNO"         "XXXXXXXXXXXXXXXX" ^
  -r "PQRSTUVWXYZ[\]$/\x5E_"    "XXXXXXXXXXXXXXXX" ^
  -r "`abcdefghijklmno"         "XXXXXXXXXXXXXXXX" ^
  -r "pqrstuvwxyz{|}~"       "XXXXXXXXXXXXXXXX"

endlocal

echo;

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

:TEST
call "%%CONTOOLS_ROOT%%/std/setshift.bat" -num 3 0 TEST_TITLE %*
echo;%TEST_TITLE%...
call "%%CONTOOLS_TESTLIB_ROOT%%/test.bat" %%*
exit /b
