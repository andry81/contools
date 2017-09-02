* README_EN.txt
* 2017.09.02
* DigitalProductId decoder

1. DESCRIPTION
2. USAGE
2.1. Execution from Windows System Recovery Console boot option
3. AUTHOR

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
Set of scritps to decode Windows Product Key from the registry and from
raw bytes file.

-------------------------------------------------------------------------------
2. USAGE
-------------------------------------------------------------------------------
PrintProductKeyFromFile <RawBytesFileName>
PrintProductKeyFromReg [<KeyPath> [<KeyName>]]

-------------------------------------------------------------------------------
2.1. Execution from Windows System Recovery Console boot option
-------------------------------------------------------------------------------
To recover and decode key from another windows registry need to execute set of
commands:

1. reg load "hklm\winext" "<WindowsDrive>:\windows\system32\config\software"
2. PrintProductKeyFromReg.vbs "hklm\winext\Microsoft\Windows NT\CurrentVersion"

Where, <WindowsDrive> - Drive letter where being recovered Windows has been
                        installed.

-------------------------------------------------------------------------------
3. AUTHOR
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
