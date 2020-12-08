' 1) WScript.Arguments(0) - путь к ini файлу
'    WScript.Arguments(0) - список рассылки, тогда базовый ini брать \\IRON2\secur$\deal68\Util\MailTo\Default.ini
' 2) WScript.Arguments(1) - путь к аттачу
' 3) WScript.Arguments(2) - переименовывать файл 
'    1 - YYYY-MM-DD
'    2 - HH-MI-SS
'    3 - YYYY-MM-DD_HH-MI-SS
' допустимые замены:
' %CurrentDateEng% - 10/31/2011
' %CurrentDateRUS% - 31.10.2011
' %CurrentTime% - 10:23:44
' %AttachName% - FileName.FileExt
' %ArchiveFolder% - U:\DiasoftReportArchive\SMTH (из ini файла)
Const DefINIfile   = "\\IRON2\secur$\deal68\Util\MailTo\Default.ini"
Const DefIniDir    = "\\IRON2\secur$\deal68\Util\MailTo\"

If WScript.Arguments.Count < 1 Then
 WScript.Quit 1
End If

Dim objShell, colFiles, objFSO, srcINIfile
Dim strYear, strMonth, strDay, strHour, strMinu, strSecu  
Dim strRecipients, strTextSubject, strTextBody, strFilePath, ArchiveFolder
Dim intType

strYear  =            CStr(  year(Date))
strMonth = Right("00"+CStr( Month(Date)), 2)
strDay   = Right("00"+CStr(   Day(Date)), 2)
strHour  = Right("00"+CStr(  Hour(Time)), 2)
strMinu  = Right("00"+CStr(Minute(Time)), 2)
strSecu  = Right("00"+CStr(Second(Time)), 2)

Set objFSO   = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("WScript.Shell")

If  WScript.Arguments.Count > 1 Then
	strFilePath = WScript.Arguments(1)
Else
	strFilePath = " "
End If

If  WScript.Arguments.Count > 2 Then
	intType = CInt(WScript.Arguments(2))
Else
	intType = -1
End If

If	InStr(WScript.Arguments(0), "@") > 0 Then
	srcINIfile    = DefINIfile
Else
	srcINIfile    = WScript.Arguments(0)
End If

If	objFSO.FileExists(DefIniDir & srcINIfile) Then 
	srcINIfile = DefIniDir & srcINIfile
Else
	If Not objFSO.FileExists(srcINIfile) Then  WScript.Quit 2
End If

If	InStr(WScript.Arguments(0), "@") > 0 Then
	strRecipients = WScript.Arguments(0)
Else
	strRecipients = ReadIni(srcINIfile, "Message", "Recipients")
End If

ArchiveFolder  = ReadIni(srcINIfile, "Message", "ArchiveFolder")
strTextSubject = ReadIni(srcINIfile, "Message", "Subject")
strTextBody    = ReadIni(srcINIfile, "Message", "Body")

 If strRecipients <> " "  Then call SendEmail( strRecipients, strTextSubject, strTextBody, strFilePath )
 If strFilePath <> " "  and intType >0 Then call RenameFile(strFilePath, intType)
 If strFilePath <> " "  and intType >0 Then call ZipApp(strFilePath, ArchiveFolder)

Function ReadIni( myFilePath, mySection, myKey )
	Const ForReading   = 1
	Const ForWriting   = 2
	Const ForAppending = 8
	Dim intEqualPos, objFSO, objIniFile
	Dim strFilePath, AttachName, strKey, strLeftString, strLine, strSection

	Set objFSO = CreateObject( "Scripting.FileSystemObject" )

	If WScript.Arguments.Count > 1 Then
		strFilePath = WScript.Arguments(1)
	Else
		strFilePath = ""
	End If

    If	objFSO.FileExists(strFilePath) Then
		AttachName = objFSO.GetFile(strFilePath).Name
	Else
		AttachName = " "
	End If

	CurrentDateEng = strMonth & "/" & strDay   & "/" & strYear
	CurrentDateRUS = strDay   & "." & strMonth & "." & strYear
	CurrentTime    = strHour  & ":" & strMinu  & ":" & strSecu

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )
                Do While Left( strLine, 1 ) <> "["
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            If ReadIni = "" Then
                               ReadIni = " "
                            End If
'Замена условных на безусловные
							ReadIni = Replace(ReadIni, "<br>"            , vbCrLf)
							ReadIni = Replace(ReadIni, "%CurrentDateEng%", CurrentDateEng)
							ReadIni = Replace(ReadIni, "%CurrentDateRUS%", CurrentDateRUS)
							ReadIni = Replace(ReadIni, "%CurrentTime%"   , CurrentTime)
							ReadIni = Replace(ReadIni, "%AttachName%"    , AttachName)
							ReadIni = Replace(ReadIni, "%ArchiveFolder%" , ArchiveFolder & strYear & "\" & strMonth & ".zip")
							ReadIni = Replace(ReadIni, "%YYYY%"          , strYear)
							ReadIni = Replace(ReadIni, "%MM%"            , strMonth)
							ReadIni = Replace(ReadIni, "%DD%"            , strDay)
							ReadIni = Replace(ReadIni, "%HH%"            , strHour)
							ReadIni = Replace(ReadIni, "%MI%"            , strMinu)
							ReadIni = Replace(ReadIni, "%SS%"            , strSecu)
							'
                            Exit Do
                        End If
                    End If
                    If objIniFile.AtEndOfStream Then Exit Do
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        ' WScript.Echo strFilePath & " doesn't exists. Exiting..."
        Wscript.Quit 3
    End If
End Function

sub SendEmail( strRecipients, strTextSubject, strTextBody, strFilePath )
  Dim omail, StrSign, srtMessage, strLogFile
  Const strSMTPServer = "smtphub.eur.mail.db.com"
  Const StrSender     = "diasoft-support@db.com"
  Set omail = CreateObject("CDO.Message")
  StrSign       = vbCrLf & "-- " & vbCrLf & "from diasoft-support@db.com" & vbCrLf & Now
 On Error resume next
  with omail
    .From = StrSender
    .To = strRecipients
    .Subject = strTextSubject
    .Textbody = strTextBody & StrSign
	with .Configuration.Fields
		.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
		.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = strSMTPServer
		.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
		.Item ("http://schemas.microsoft.com/cdo/configuration/languagecode") = 1049
		.Item ("http://schemas.microsoft.com/cdo/configuration/usemessageresponsetext") = true
		'.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = true
     .Update
	End With
	With .BodyPart
	.CharSet = "koi8-r"
	.ContentTransferEncoding = "8bit"
	End With
    If strFilePath <> " " Then .AddAttachment strFilePath
    .Send
  End With
      If Err.Number <> 0 Then
         srtMessage = "Failed to send email. Error=" & CStr(Err.Number) & "!!!"_
					& vbCrLf & "  => " & Err.Description _
					& vbCrLf & "  To: " & strRecipients _
					& vbCrLf & "  Subject: " & strTextSubject _
					& vbCrLf & "  Body: " & strTextBody
		 call SaveLogFile(srtMessage)
		 Err.Clear
         WScript.Quit(ErrN)
      End If
  Set omail = Nothing
  On Error GoTo 0
end sub

sub SaveLogFile(strMessage)
	Dim objTextFile, strLogFilePath
	strLogFilePath = ReadIni(srcINIfile, "Message", "LogFile")
	If strLogFilePath = " " Then
	strLogFilePath = "\\iron2\secur$\DiasoftReportsArchive\_mailto_log\%YYYY%-%MM%-%DD%_%HH%-%MI%-%SS%.log"
	End If
	strLogFilePath = Replace(strLogFilePath, "%YYYY%", strYear)
	strLogFilePath = Replace(strLogFilePath, "%MM%",   strMonth)
	strLogFilePath = Replace(strLogFilePath, "%DD%",   strDay)
	strLogFilePath = Replace(strLogFilePath, "%HH%",   strHour)
	strLogFilePath = Replace(strLogFilePath, "%MI%",   strMinu)
	strLogFilePath = Replace(strLogFilePath, "%SS%",   strSecu)
	
    set objTextFile = objFSO.OpenTextFile(strLogFilePath, 8, true) 
		objTextFile.Write(strMessage)
		objTextFile.Close
	set objTextFile = nothing
end sub

sub ZipApp(strFilePath, ArchiveFolder)
  Path     = ArchiveFolder & "\" & strYear & "\"
      If not (objFSO.FolderExists(Path)) Then objFSO.CreateFolder Path
  ZipFile  = Path & objFSO.GetFileName(strMonth & ".zip")
  ZipStr   = "\\IRON2\secur$\deal68\util\7z.exe a -tzip -mx9 -r -w -y ""{0}"" ""{1}"""
  ZipStr   = Replace(ZipStr, "{0}", ZipFile)
  ZipStr   = Replace(ZipStr, "{1}", strFilePath)
  objShell.Run ZipStr, 0, true
  If objFSO.FileExists(strFilePath) Then objFSO.DeleteFile strFilePath, True
  ArchiveFolder = ZipFile
end sub

sub RenameFile(strFilePath, intType)
	Dim strTimeStamp, strCopyFile, nPoint
	Select Case intType
			Case 1
				strTimeStamp=strYear&"-"&strMonth&"-"&strDay
			Case 2
				strTimeStamp=strHour&"-"&strMinu&"-"&strSecu
			Case 3
				strTimeStamp=strYear&"-"&strMonth&"-"&strDay&"_"&strHour&"-"&strMinu&"-"&strSecu
	End select
	strCopyFile = StrReverse(strFilePath)
	If InStr(strCopyFile,".") > InStr(strCopyFile,"\") or InStr(strCopyFile,".") = 0 Then strCopyFile = "." & strCopyFile
	nPoint      = InStr(strCopyFile,".")
	strCopyFile = Left(strCopyFile, nPoint) & StrReverse(strTimeStamp) & rtrim(Mid(strCopyFile, nPoint, 255))
	strCopyFile = StrReverse(strCopyFile)
	If objFSO.FileExists(strCopyFile) Then objFSO.DeleteFile strCopyFile
	If objFSO.FileExists(strFilePath) Then objFSO.MoveFile strFilePath, strCopyFile
	strFilePath = strCopyFile
end sub