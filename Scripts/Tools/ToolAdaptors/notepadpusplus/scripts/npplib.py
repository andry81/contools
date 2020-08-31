from __future__ import print_function

def toggle_readonly_flag_for_all_tabs():
  print('toggle_readonly_flag_for_all_tabs:')

  active_file = notepad.getCurrentFilename()
 
  for f in notepad.getFiles():
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_SETREADONLY)
    print("  - {}".format(f))

  notepad.activateFile(active_file)

  print()

def clear_readonly_flag_from_all_files():
  print('clear_readonly_flag_from_all_files:')

  active_file = notepad.getCurrentFilename()

  for f in notepad.getFiles():
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_CLEARREADONLY)
    print("  - {}".format(f))

  notepad.activateFile(active_file)

  print()

def reopen_all_files():
  print('reopen_all_files:')

  active_file = notepad.getCurrentFilename()

  notepad.saveAllFiles()
  all_files = notepad.getFiles()
  notepad.closeAll()

  for f in all_files:
    notepad.open(f[0])
    print("  - {}".format(f[0]))

  notepad.activateFile(active_file)

  print()
