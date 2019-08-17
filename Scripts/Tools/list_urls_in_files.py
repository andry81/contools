import os, sys, re, inspect

SOURCE_FILE = os.path.abspath(inspect.getsourcefile(lambda:0)).replace('\\','/')
SOURCE_DIR = os.path.dirname(SOURCE_FILE)
SOURCE_FILE_NAME = os.path.split(SOURCE_FILE)[1]

sys.path.insert(0, SOURCE_DIR)

import cmdoplib

CHECKED_URLS = []

def parse_dir(dir_path):
  for dirpath, dirs, files in os.walk(dir_path):
    for dir in dirs:
      # ignore directories beginning by '.'
      if str(dir)[0:1] == '.':
        continue
      parse_dir(os.path.join(dirpath, dir))
    dirs.clear() # not recursively

    for file_name in files:
      file_path = os.path.join(dirpath, file_name).replace('\\','/')
      with open(file_path) as file:
        is_file_path_printed = False
        unique_file_urls = []

        for line in file:
          urls = cmdoplib.extract_urls(line)
          for url in urls:
            if not is_file_path_printed:
              print('{0}:'.format(file_path))
              is_file_path_printed = True

            if not url in CHECKED_URLS:
              # check url here...
              CHECKED_URLS.append(url)

            if not url in unique_file_urls:
              unique_file_urls.append(url)

        unique_file_urls.sort()

        for url in unique_file_urls:
          print('  * {0}'.format(url))

if __name__ == '__main__':
  DIR_PATH = sys.argv[1].replace('\\', '/') if len(sys.argv) >= 2 else ''

  if not os.path.isdir(DIR_PATH):
    cmdoplib.print_err("{0}: error: argv[1] directory does not exist: `{1}`.".format(SOURCE_FILE_NAME, DIR_PATH))
    sys.exit(1)

  parse_dir(DIR_PATH)

  sys.exit(0)
