# basen on: http://www.swarley.me.uk/blog/2014/04/23/python-pip-and-windows-registry-corruption/
#

import sys
if sys.version_info[0] >= 3:
  import winreg
else:
  import _winreg as winreg

i = 0
while True:
  try:
    subkeyname = winreg.EnumKey(winreg.HKEY_CLASSES_ROOT, i)
    try:
      if '\0' in subkeyname: # new
        print("bad key: %s" % subkeyname)
    except:
      print("exception on key `%s`: sys.exc_info()[0]" % subkeyname)
    i += 1
  except WindowsError:
    break
