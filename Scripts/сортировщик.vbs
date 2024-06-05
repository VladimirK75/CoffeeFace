' сортировщик
dim objArgs, objFso, objFile, objShell, strFldr, objDir, objCol
set objFso=CreateObject("Scripting.FileSystemObject")
set objFile=objFso.GetFile(Wscript.scriptFulName)
set objShell=CreateObject("Shell.Application")
If not objFso.FolderExists(Wscript.Arguments.Item(0)) Then
strFldr=Left(objFile.Path, InStrRev(objFile.Path, "\")
Else strFldr=Wscript.Arguments.Item(0)
End If
set ObjDir =objFso.GetFolder(strFldr)
set objCol=objDir.Files
For Each objItem in objCol
If not (objItem.Name = Wscript.scriptFulName) _
and (strFldr=Left(objItem.Path, InStrRev(objItem.Path, "\"))
Then
call Move2Arch(objItem)
End If
Next

sub Move2Arch(File)
Dim startDate, strYear, strMonth, strDay, Path, dFolder
  NowDate = file.DateCreated
  strYear=CStr(year(NowDate))
  strMonth=Right("00"+CStr(Month(NowDate)), 2)
  strDay=Right("00"+CStr(Day(NowDate)), 2)
  
 Path=StrFldr & "\" & strYear & "\"
 If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
 Path=Path & "\" & strMonth & "\"
 If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
 Path=Path & "\" & strDay & "\"
 If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
set dFolder=objShell.NameSpace(Path)
If (not dFolder is nothing) Then
dFolder.MoveHere File.Name, 16
End If
end sub
Wscript.Echo "OK"