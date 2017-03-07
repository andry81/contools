import sys, os, platform, errno

from WinReg import WinRegStatics, WinReg
from ProductKey import ProductKey

WinReg.static_init()

def GetKeyFromRegLoc(key, wow64 = False, value = "DigitalProductId"):
  hkey = None # must be defined if *CALL1* is failed because of: UnboundLocalError: local variable 'hkey' referenced before assignment
  try:
    hkey = WinReg.OpenKey(WinRegStatics.winreg.HKEY_LOCAL_MACHINE, key, 0, wow64, WinRegStatics.winreg.KEY_QUERY_VALUE)
    value, type = WinReg.QueryValueEx(hkey, value)
    return ProductKey().Decode(value)
  finally:
    if hkey is not None:
      hkey.Close() # close immediately
      hkey = None

# try request as is at first
try:
  print("1: {0}".format(GetKeyFromRegLoc("SOFTWARE\Microsoft\Windows NT\CurrentVersion"))) # *CALL1*
except IOError as e: # portabale on Python 2 x64 + Python 3 x86 + Python 3 x64, but NOT on Python 2 x86!
  if e.errno == errno.ENOENT: # file (key) is not found
    pass
except EnvironmentError as e: # cover the Python 2 x86 portability case
  if e.errno == errno.ENOENT: # file (key) is not found
    pass

if WinRegStatics.platform_architecture[0] == '32bit' and WinRegStatics.platform_machine.endswith('64'):
  # disable Wow64 redirection on 32-bit python in 64-bit OS
  print("2: {0}".format(GetKeyFromRegLoc("SOFTWARE\Microsoft\Windows NT\CurrentVersion", True)))
