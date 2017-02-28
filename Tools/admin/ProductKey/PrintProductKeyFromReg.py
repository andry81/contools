import _winreg
from ProductKey import ProductKey

def GetKeyFromRegLoc(key, value="DigitalProductID"):
    key = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE,key)
    value, type = _winreg.QueryValueEx(key, value)
    return ProductKey().Decode(value)

print GetKeyFromRegLoc("SOFTWARE\Microsoft\Windows NT\CurrentVersion")
