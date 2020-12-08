Dim objArgs, objFSO, objFile, objShell, objDIR, objCol, strFldr

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(WScript.ScriptFullName)

If WScript.Arguments.Count > 0 Then
     If objFSO.FolderExists(Wscript.arguments.Item(0)) Then
     strFldr = Wscript.arguments.Item(0)
     Else
          strFldr = Left(objFile.Path, InStrRev(objFile.Path, "\"))
     End If
Else
     strFldr = Left(objFile.Path, InStrRev(objFile.Path, "\"))
End If
Set objDIR = objFSO.GetFolder(strFldr)
Set objCol = objDIR.Files
For Each objItem In objCol
   If (not (objItem.Path = WScript.ScriptFullName)_
      and (strFldr = Left(objItem.Path, InStrRev(objItem.Path, "\")))) Then
       Call Move2Arch(objItem)
   End If 
Next

sub Move2Arch(file)
Dim NowDate, strYear, strMonth, strDay, Path, DFolder
  NowDate = file.DateLastModified
  strYear=CStr(year(NowDate))
  strMonth=Right("00"+CStr(Month(NowDate)), 2)
  strDay=Right("00"+CStr(Day(NowDate)), 2)

Path = strFldr & "\" & strYear & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
Path = Path & "\" & strMonth & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
Path = Path & "\" & strDay & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path

 objFSO.MoveFile file.path, Path

End Sub
WScript.Echo "OK"