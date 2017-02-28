import sys
from ProductKey import ProductKey

print ProductKey(sys.argv[1]).DecodeFromFile()
