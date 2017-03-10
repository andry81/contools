''' Updates the Windows shortcut file with assigned command line and working
''' directory.

set objWSHShell = CreateObject("WScript.Shell")

sShortcut = WScript.Arguments.Item(0)

Set objSC = objWSHShell.CreateShortcut(sShortcut)

''' Must reset quotes back
sTargetPath = objSC.TargetPath
If sTargetPath <> "" Then
  sTargetPath = """" & sTargetPath & """"
End If
objSC.TargetPath = sTargetPath

objSC.Save
