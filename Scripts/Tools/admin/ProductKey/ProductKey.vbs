Function DecodeFromBytes(bytes)
    Dim KeyChars
    ReDim KeyChars(Len(bytes) - 1)
    For i = 1 To Len(bytes)
        KeyChars(i - 1) = Mid(bytes, i, 1)
    Next

    Const KeyOffset = 52
    i = 28
    CharWhitelist = "BCDFGHJKMPQRTVWXY2346789"
    Do
        Accum = 0
        j = 14
        Do
            Accum = Accum * 256
            d = KeyChars(j + KeyOffset)
            If TypeName(d) = "String" Then
              d = Asc(d)
            End If
            Accum = d + Accum
            If (Accum \ 24) <= 255 Then
              KeyChars(j + KeyOffset) = Accum \ 24
            Else
              KeyChars(j + KeyOffset) = 255
            End If
            Accum = Accum Mod 24
            j = j - 1
        Loop While j >= 0
        i = i - 1
        KeyOutput = Mid(CharWhitelist, Accum + 1, 1) & KeyOutput
        If (((29 - i) Mod 6) = 0) And (i <> -1) Then
            i = i - 1
            KeyOutput = "-" & KeyOutput
        End If
    Loop While i >= 0
    DecodeFromBytes = KeyOutput
End Function

Function ReadBinaryFile(path)
    Dim oFSO: Set oFSO = CreateObject("Scripting.FileSystemObject")
    Dim oFile: Set oFile = oFSO.GetFile(path)

    'If IsNull(oFile) Then Exit Function

    Set ts = oFile.OpenAsTextStream()
    ReadBinaryFile = ts.Read(oFile.Size)
    ts.Close
End Function
