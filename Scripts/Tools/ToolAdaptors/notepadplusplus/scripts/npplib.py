from __future__ import print_function

def toggle_readonly_flag_for_all_tabs():
  print('toggle_readonly_flag_for_all_tabs:')

  all_files = notepad.getFiles()
  active_file = notepad.getCurrentFilename()

  num_toggled = 0

  for f in reversed(all_files):
    print("  - {}".format(f))
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_SETREADONLY)
    num_toggled += 1

  notepad.activateFile(active_file)

  print()
  print('* Number of toggled paths: '+ str(num_toggled))
  print()

def clear_readonly_flag_from_all_files():
  print('clear_readonly_flag_from_all_files:')

  all_files = notepad.getFiles()
  active_file = notepad.getCurrentFilename()

  num_cleared = 0

  for f in reversed(all_files):
    print("  - {}".format(f))
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_CLEARREADONLY)
    num_cleared += 1

  notepad.activateFile(active_file)

  print()
  print('* Number of cleared paths: ' + str(num_cleared))
  print()

def reopen_all_files():
  print('reopen_all_files:')

  all_files = list(notepad.getFiles())
  active_file = notepad.getCurrentFilename()

  notepad.saveAllFiles()
  notepad.closeAll()

  num_reopened = 0

  for f in all_files:
    print("  - {}".format(f[0]))
    notepad.open(f[0])
    num_reopened += 1

  # reactive in reverse order
  for f in reversed(all_files):
    notepad.activateFile(f[0])

  notepad.activateFile(active_file)

  print()
  print('* Number of reopened paths: ' + str(num_reopened))
  print()

def process_extra_command_line(open_file_list_from_command_line = True):
  import io, shlex

  print('process_extra_command_line:')

  cmdline_list = shlex.split(notepad.getCommandLine())

  from_utf8 = False
  from_utf16 = False
  from_utf16le = False
  from_utf16Be = False

  open_from_file_list_path = ''
  next_arg_is_file_list_path = False

  do_reopen_all_files = False

  for arg in cmdline_list:
    if arg == '-z':
      continue

    if not next_arg_is_file_list_path:
      if arg == '-from_utf8':
        from_utf8 = True
      elif arg == '-from_utf16':
        from_utf16 = True
      elif arg == '-from_utf16le':
        from_utf16le = True
      elif arg == '-from_utf16be':
        from_utf16be = True
      elif arg == '--open_from_file_list':
        next_arg_is_file_list_path = True
      elif arg == '-reopen_all_files':
        do_reopen_all_files = True
    else:
      open_from_file_list_path = str(arg)
      next_arg_is_file_list_path = False

  num_opened = 0

  if open_from_file_list_path:
    print('--open_from_file_list:')

    with open(open_from_file_list_path, 'rb') as file_list: # CAUTION: binary mode is required to correctly decode string into `utf-8` below
      file_content = file_list.read()

    # CAUTION:
    #   Do decode with explicitly stated encoding to avoid the error:
    #   `UnicodeDecodeError: 'charmap' codec can't decode byte ... in position ...: character maps to <undefined>`
    #   (see details: https://stackoverflow.com/questions/27453879/unicode-decode-error-how-to-skip-invalid-characters/27454001#27454001 )
    #
    recode_to_utf8 = False
    if from_utf8:
      file_content_decoded = file_content.decode('utf-8', errors='ignore')
    elif from_utf16:
      file_content_decoded = file_content.decode('utf-16', errors='ignore')
      recode_to_utf8 = True
    elif from_utf16le:
      file_content_decoded = file_content.decode('utf-16-le', errors='ignore')
      recode_to_utf8 = True
    elif from_utf16be:
      file_content_decoded = file_content.decode('utf-16-be', errors='ignore')
      recode_to_utf8 = True
    else:
      file_content_decoded = file_content

    # To iterate over lines instead chars.
    # (see details: https://stackoverflow.com/questions/3054604/iterate-over-the-lines-of-a-string/3054898#3054898 )
    file_strings = io.StringIO(file_content_decoded)

    for line in file_strings:
      file_path = line.strip()
      if file_path:
        if recode_to_utf8:
          file_path = file_path.encode('utf-8', errors='ignore')
        print("  - {}".format(file_path))
        notepad.open(file_path)
        num_opened += 1

  else:
    if open_file_list_from_command_line:
      print('* error: file list path is not defined')

  print()
  print('* Number of opened paths: ' + str(num_opened))
  print()

  if do_reopen_all_files:
    reopen_all_files()

def open_from_file_list(file_list):
  print('open_from_file_list:')

  num_opened = 0

  for file in file_list:
    print("  - {}".format(file))
    notepad.open(file)
    num_opened += 1

  print()
  print('* Number of opened paths: ' + str(num_opened))
  print()
