class ProductKey:
  def __init__(self, fileName = None):
    self.keyFile = None
    if (fileName is not None):
      self.Open(fileName)

  def __enter__(self):
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    self.Close()

  def Open(self, fileName):
    if (self.keyFile is not None):
      raise Exception("File already opened")
    self.keyFile = open(fileName, mode='rb')

  def Close(self):
    if (self.keyFile is not None):
      self.keyFile.close()

  def Decode(self, bytes):
      rpk = list(bytes)
      rpkOffset = 52
      i = 28
      szPossibleChars = "BCDFGHJKMPQRTVWXY2346789"
      szProductKey = ""
      
      while i >= 0:
          dwAccumulator = 0
          j = 14
          while j >= 0:
              dwAccumulator = dwAccumulator * 256
              d = rpk[j+rpkOffset]
              if isinstance(d, str):
                  d = ord(d)
              dwAccumulator = d + dwAccumulator
              rpk[j+rpkOffset] =  (dwAccumulator / 24) if (dwAccumulator / 24) <= 255 else 255 
              dwAccumulator = dwAccumulator % 24
              j = j - 1
          i = i - 1
          szProductKey = szPossibleChars[dwAccumulator] + szProductKey
          
          if ((29 - i) % 6) == 0 and i != -1:
              i = i - 1
              szProductKey = "-" + szProductKey
              
      return szProductKey

  def DecodeFromFile(self):
    return self.Decode(self.keyFile.read())
