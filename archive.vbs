Option Explicit 

Const MoveMode = &H0&

Dim strFldr, objFSO, objDIR, objCol, objShell, objItem
    strFldr =Wscript.arguments.Item(0)
'wscript.echo strFldr
Set objFSO = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("WScript.Shell")

Set objDIR = objFSO.GetFolder(strFldr)
Set objCol = objDIR.Files
For Each objItem In objCol
   If not (   LCase(Right(objItem.Name, 4)) = ".zip"_
           or LCase(Right(objItem.Name, 4)) = ".bat"_ 
           or LCase(Right(objItem.Name, 4)) = ".cmd" ) Then 
       Call ZipApp(objItem)
       'Call MakeZIP(objItem)
   End If 
Next

sub ZipApp(file)
Dim NowDate, strYear, strMonth, strDay, sFile, gFile, Path, ZipStr


  NowDate = file.DateLastModified
  strYear=CStr(year(NowDate))
  strMonth=Right("00"+CStr(Month(NowDate)), 2)
  strDay=Right("00"+CStr(Day(NowDate)), 2)

Path = strFldr & "\" & strYear & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
sFile = Path & objFSO.GetFileName(strMonth & ".zip")
gfile = objFSO.GetAbsolutePathName(file) 
ZipStr = "u:\deal68\util\7z.exe a -tzip -mx9 -r -x!*.zip -w -y ""{0}"" ""{1}"""
ZipStr = Replace(ZipStr, "{0}", sFile)
ZipStr = Replace(ZipStr, "{1}", gfile)
'wscript.echo ZipStr
objShell.Run ZipStr, 0, true
if objFSO.FileExists(gfile) Then  objFSO.DeleteFile gfile
end sub

Sub MakeZIP(file) 
Dim fso, wShell, Shell, n, IE, ZIPFile, folder, folderItem, dFolder, NowDate, sFile, Path,pfile,gfile
Dim ZIPHeader : ZIPHeader = "PK" & Chr(5) & Chr(6) & String(18, Chr(0)) 

Dim startDate, strYear, strMonth, strDay
  NowDate = file.DateLastModified
  strYear=CStr(year(NowDate))
  strMonth=Right("00"+CStr(Month(NowDate)), 2)
  strDay=Right("00"+CStr(Day(NowDate)), 2)

sFile = objFSO.GetFileName(strMonth & ".zip")
Path = strFldr & "\" & strYear & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
pfile = objFSO.BuildPath(Path, sFile)

ZIPFile = objFSO.GetAbsolutePathName(pfile)
 
Set fso = CreateObject("Scripting.FileSystemObject") 
Set wShell = CreateObject("WScript.Shell") 
Set Shell = CreateObject("Shell.Application")
if not (fso.FileExists(ZIPFile)) Then fso.CreateTextFile(ZIPFile, false).Write ZIPHeader 

For n = 0 to 9 
  For Each IE in Shell.Windows 
    If Not IE.Busy Then 
      If IE.ReadyState = 4 Then 
        If InStr(TypeName(IE.Document), "IShellFolderViewDual") = 1 Then 
          Exit For 
        End If 
      End If 
    End If 
  Next 
  If Not IsEmpty(IE) Then Exit For 
  If n = 0 Then CreateObject("WScript.Shell").Run "explorer.exe", 0, true 
Next 

If IsEmpty(IE) Then 
  WScript.Quit 
End If 

Set Shell = IE.Document.Application
Dim ZIPItem
Set dFolder = Shell.NameSpace(ZIPFile)
For Each ZIPItem in dFolder.Items
if ZIPItem.Path = file.Name Then 
   WScript.Echo "¡À»»»»Õ!!!!"
'   WScript.Echo ZIPFile
   ZIPItem.Delete
   'WScript.Echo ZIPItem
End If
Next

 gfile = fso.GetAbsolutePathName(file) 
  Set folder = Shell.NameSpace(fso.GetParentFolderName(gfile)) 
  Set folderItem = folder.ParseName(fso.GetFileName(gfile)) 

  If folderItem Is Nothing Then 
  WScript.Quit 
  End If
 stop
  
'  dFolder.CopyHere folderItem
  dFolder.CopyHere gfile, 20
  'if fso.FileExists(gfile) Then  fso.DeleteFile gfile
  
End Sub
'WScript.Echo "”Ô‡ÍÓ‚‡ÌÓ"