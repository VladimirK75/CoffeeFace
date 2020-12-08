Option Explicit 
private const FOF_NOCONFIRMATION = 16
Dim strFldr, objFSO, objDIR, objCol, objShell, objItem
    strFldr =Wscript.arguments.Item(0)
Set objFSO = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("WScript.Shell")
Set objDIR = objFSO.GetFolder(strFldr)
Set objCol = objDIR.Files
For Each objItem In objCol
   If not (   LCase(Right(objItem.Name, 4)) = ".zip"_
           or LCase(Right(objItem.Name, 4)) = ".bat"_ 
           or LCase(Right(objItem.Name, 4)) = ".cmd" ) Then 
       Call MakeZIP(objItem)
       if objFSO.FileExists(objItem) Then  objFSO.DeleteFile objItem
   End If 
Next
Sub MakeZIP(file) 
Dim fso, wShell, Shell, n, IE, ZIPFile, folder, folderItem, dFolder, NowDate, sFile, Path,pfile,gfile
Dim ZIPHeader : ZIPHeader = "PK" & Chr(5) & Chr(6) & String(18, Chr(0)) 
Dim startDate, strYear, strMonth, strDay, strCopyFile
Set fso = CreateObject("Scripting.FileSystemObject") 
Set wShell = CreateObject("WScript.Shell") 
Set Shell = CreateObject("Shell.Application")

  NowDate = file.DateLastModified
  strYear=CStr(year(NowDate))
  strMonth=Right("00"+CStr(Month(NowDate)), 2)
  strDay=Right("00"+CStr(Day(NowDate)), 2)

sFile = objFSO.GetFileName(strMonth & ".zip")
Path = strFldr & "\" & strYear & "\"
If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
pfile = objFSO.BuildPath(Path, sFile)
ZIPFile = objFSO.GetAbsolutePathName(pfile)
'WScript.Echo ZIPFile
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
 strCopyFile = file.Name
For Each ZIPItem in dFolder.Items
if ZIPItem.Path = file.Name Then 
    strCopyFile = file.Name&"."&fso.GetTempName
    fso.MoveFile fso.GetAbsolutePathName(file) , strCopyFile
    WScript.Sleep 50
    file = fso.GetAbsolutePathName(strCopyFile)
End If
Next
 gfile = fso.GetAbsolutePathName(strCopyFile) 
'WScript.Echo file
  Set folder = Shell.NameSpace(fso.GetParentFolderName(gfile)) 
  Set folderItem = folder.ParseName(fso.GetFileName(gfile)) 
  If folderItem Is Nothing Then 
  WScript.Quit 
  End If
 stop
  dFolder.MoveHere gfile, FOF_NOCONFIRMATION
WScript.Sleep 50
End Sub

WScript.Echo "DONE"