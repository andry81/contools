import sys, os, platform, errno

# WARNING:
#   Explicit statics init because of errors inside the WinReg class:
#   * AttributeError: type object 'WinReg' has no attribute 'winreg'
#   * NameError: name 'winreg' is not defined
# SOLUTION:
#   winreg reference have to be initialized statically before the WinReg class declaration.
class WinRegStatics:
  @staticmethod
  def static_init():
    if sys.version_info[0] >= 3:
      import winreg
      WinRegStatics.winreg = winreg
    else:
      import _winreg
      # create reference immediately, otherwise any local assignment can overlap a global winreg with the error: UnboundLocalError: local variable 'winreg' referenced before assignment
      WinRegStatics.winreg = _winreg
    WinRegStatics.platform_architecture = platform.architecture()
    WinRegStatics.platform_machine = platform.machine()

  @staticmethod
  def static_uninit():
    if sys.version_info[0] < 3:
      # invalidate reference
      WinRegStatics.winreg = None
    WinRegStatics.platform_architecture = None
    WinRegStatics.platform_machine = None

# The winreg fails to query the "SOFTWARE\Microsoft\Windows NT\CurrentVersion" in Python 2/3 32 bit on 64 bit OS directly, but not through a class methods.
# This class exists to workaround it, and use _winreg on Python 2 and winreg on Python 3 transparently!
class WinReg:
  @staticmethod
  def static_init():
    return WinRegStatics.static_init();

  @staticmethod
  def static_uninit():
    return WinRegStatics.static_uninit();

  def __init__(self):
    pass

  def __enter__(self):
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    pass

  # use wow64=True explicitly to access 64 bit registry key from the 32 bit Python process!
  @staticmethod
  def OpenKey(key, sub_key, res = None, wow64 = False, sam = None):
    # WARNING:
    #  Python 32 bit should use registry redirection on 64 bit OS.
    #  Python 64 bit should use 64 bit registry on 64 bit .
    #  Explicitly use wow64 flag to override behaviour for Pythin 32 bit.
    #  Explicitly use sam flags to override behaviour for Pythin 64 bit.
    if wow64:
      if sam is None:
        sam = WinRegStatics.winreg.KEY_WOW64_64KEY
      else:
        sam &= ~WinRegStatics.winreg.KEY_WOW64_32KEY
        sam |= WinRegStatics.winreg.KEY_WOW64_64KEY
    elif WinRegStatics.platform_machine.endswith('64'):
      if WinRegStatics.platform_architecture[0] != '32bit':
        if sam is None:
          sam = WinRegStatics.winreg.KEY_WOW64_64KEY
        elif not (sam & WinRegStatics.winreg.KEY_WOW64_32KEY):
          sam |= WinRegStatics.winreg.KEY_WOW64_64KEY
      else:
        if sam is None:
          sam = WinRegStatics.winreg.KEY_WOW64_32KEY
        elif not (sam & WinRegStatics.winreg.KEY_WOW64_64KEY):
          sam |= WinRegStatics.winreg.KEY_WOW64_32KEY
    else:
      if sam is None:
        sam = WinRegStatics.winreg.KEY_WOW64_64KEY
      elif not (sam & (WinRegStatics.winreg.KEY_WOW64_32KEY | WinRegStatics.winreg.KEY_WOW64_64KEY)):
        sam |= WinRegStatics.winreg.KEY_WOW64_64KEY
    return WinRegStatics.winreg.OpenKey(key, sub_key, res, sam)

  @staticmethod
  def QueryValueEx(key, sub_key):
    return WinRegStatics.winreg.QueryValueEx(key, sub_key)
