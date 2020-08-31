from __future__ import print_function

def clear_readonly_flag_from_all_tabs():
  print('clear_readonly_flag_from_all_tabs:')
  for f in notepad.getFiles():
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_CLEARREADONLY)
    print(" - {}".format(f))
  print()

def set_readonly_flag_to_all_tabs():
  print('set_readonly_flag_to_all_tabs:')
  for f in notepad.getFiles():
    print(notepad.getMenuHandle(MENUCOMMAND.EDIT_SETREADONLY))
    print(notepad.getMenuHandle(MENUCOMMAND.EDIT_CLEARREADONLY))
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_SETREADONLY)
    print("  - {}".format(f))
  print()

def clear_readonly_flag_from_all_files():
  print('clear_readonly_flag_from_all_files:')
  for f in notepad.getFiles():
    notepad.activateFile(f[0])
    notepad.menuCommand(MENUCOMMAND.EDIT_SETREADONLY)
    print("  - {}".format(f))
  print()

def reopen_all_files():
  print('reopen_all_files:')
  notepad.saveAllFiles()
  all_files = notepad.getFiles()
  notepad.closeAll()

  for f in all_files:
    notepad.open(f[0])
    print("  - {}".format(f[0]))
  print()
