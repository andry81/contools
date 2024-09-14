' Description:
'   Shell based script to be able to delete file by paths longer than 260+ characters.
'
' USAGE:
'   "%SystemRoot%\System32\cscript.exe" //NOLOGO delete_file.vbs "\\?\<absolute-canonical-file-path-to-file>"
'
'   , where (!) <absolute-canonical-file-path-to-file>: is an absolute file path separated with the backslash character ONLY - `\`
'

Dim objFS : Set objFS = CreateObject("Scripting.FileSystemObject")
objFS.DeleteFile WScript.Arguments(0)
