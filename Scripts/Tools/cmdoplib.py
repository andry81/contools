# pure python module for commands w/o extension modules usage (xonsh, cmdix and others)

import os, sys, re

# error print
def print_err(*args, **kwargs):
  print(*args, file=sys.stderr, **kwargs)

def extract_urls(str):
  urls = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', str.lower())
  urls_arr = []
  for url in urls:
    lastChar = url[-1] # get the last character
    # if the last character is not (^ - not) an alphabet, or a number,
    # or a '/' (some websites may have that. you can add your own ones), then enter IF condition
    if (bool(re.match(r'[^a-zA-Z0-9/]', lastChar))): 
      urls_arr.append(url[:-1]) # stripping last character, no matter what
    else:
      urls_arr.append(url) # else, simply append to new list
  return urls_arr
