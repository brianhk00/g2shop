<%@ Language="VBScript" %>
<!-- #INCLUDE File="local/local.phtml" -->
<!-- #INCLUDE File="util/xt_func_util.phtml" -->
<!-- #INCLUDE File="util/xt_func_string.phtml" -->
<!-- #include file="aspuploader/include_aspuploader.asp" -->
<%

Function CreateGuid()
	Dim hex,str,i,res
	hex="0123456789ABCDEF"
	str="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
	res=""
	For i=1 To Len(str)
		If Mid(str,i,1)="X" Then
			res = res & Mid(hex,Rnd(16)+1,1)
		Else
			res = res & "-"
		End If
	Next
	CreateGuid=res
End Function
Function CheckGuid(str)
	Dim re
	Set re=new RegExp
	re.Pattern="^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$"
	re.IgnoreCase=true
	If not re.Test(str) Then
		Err.Raise -1,"","Invalid Guid" & str
	End If
End Function
Function ToTwoChar(str)
	If Len(str)>1 Then
		ToTwoChar=str
	Else
		ToTwoChar="0" & str
	End If
End Function
Function GetNewDateTime()
	GetNewDateTime=Year(Date()) & "-" & ToTwoChar(Month(Date())) & "-" & ToTwoChar(Day(Date())) & " " & ToTwoChar(Hour(Time())) & "-" & ToTwoChar(Minute(Time())) & "-" & ToTwoChar(Second(Time()))
End Function

pf_id = Trim(Request("pf_id"))
Set fso=CreateObject("Scripting.FileSystemObject")
'savefolder=Server.MapPath("filemanagerfolder/guest")
savefolder=Server.MapPath("../media/catalog/product/" & pf_id)
downloadfile = Request.QueryString("downloadfile") & ""

Dim files,i,filepath,list

Set files=FSO.GetFolder(savefolder).Files


If downloadfile<>"" Then
	CheckGuid(downloadfile)	
	For Each filepath In files
		If InStr(1,FSO.GetBaseName(filepath),downloadfile,1)>0 Then
			Select Case LCase(FSO.GetExtensionName(filepath))
				Case "jpage"
					Response.ContentType="image/jpeg"
				Case "jpg"
					Response.ContentType="image/jpeg"
				Case "gif"
					Response.ContentType="image/gif"
				Case "png"
					Response.ContentType="image/png"
				Case Else
					Response.ContentType="application/octet-stream"
			End Select
			Response.AddHeader "Content-Disposition","attachment; filename=""" & Mid(fso.GetBaseName(filepath),58) & """"
			
			Dim data,stream
			Set stream=CreateObject("ADODB.Stream")
			stream.Mode=3
			stream.Type=1
			stream.Open()
			stream.LoadFromFile(filepath)
			Dim ws,cs
			ws=0
			while ws<stream.Size
				cs=stream.Size-ws
				If cs>1000 Then
					cs=1000
				End If
				data=stream.Read(cs)
				Response.BinaryWrite(data)
				Response.Flush()
				ws=ws+cs
			wend
			stream.Close()
			Response.End()
		End If
	Next
End If



Set uploader=new AspUploader

If Request.Form("guidlist")&""<>"" Then
	list=Split(Request.Form("guidlist"),"/")
	For i=0 to Ubound(list)
		Set mvcfile=uploader.GetUploadedFile(list(i))		
		'fso.MoveFile mvcfile.FilePath,savefolder & "\" & GetNewDateTime() & "." & mvcfile.FileGuid & "." & mvcfile.FileName & ".resx"
		fso.MoveFile mvcfile.FilePath,savefolder & "\" & mvcfile.FileGuid & "-" & mvcfile.FileName
		
		pstr = "FileURL=" & g_store_url & "media/catalog/product/" & pf_id & "/" & mvcfile.FileGuid & "-" & mvcfile.FileName
		
		dim xmlRecv2
		set xmlRecv2 = Server.CreateObject("Msxml2.ServerXMLHTTP")
		xmlRecv2.open "POST", "http://app.internetreports.com/api/upload?FileURL=" & g_store_url & "media/catalog/product/" & pf_id & "/" & mvcfile.FileGuid & "-" & mvcfile.FileName, False
		xmlRecv2.setRequestHeader "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"
		xmlRecv2.setTimeouts 5000, 5000, 15000, 15000
		xmlRecv2.send ""
		pResult = xmlRecv2.responseText
		
		if Len(pResult) > 0 then
			pResult = Replace(pResult, "[""", "")
			pResult = Replace(pResult, """]", "")
			ar_pResult = Split(pResult, """,""")
		end if
		
		cloud_public_id = ""
		cloud_url = ""
		cloud_secure_url = ""
		
		if Len(ar_pResult(0)) > 0 then
			cloud_public_id = ar_pResult(0)
		end if
		
		if Len(ar_pResult(1)) > 0 then
			cloud_url = ar_pResult(1)
		end if
		
		if Len(ar_pResult(2)) > 0 then
			cloud_secure_url = ar_pResult(2)
		end if
		
		sqlu = "INSERT INTO " & g_storeid & "_product_image (pf_id,image_name,cloud_public_id, cloud_url, cloud_secure_url) VALUES ('"& pf_id &"','" & mvcfile.FileGuid & "-" & mvcfile.FileName & "','" & cloud_public_id & "','" & cloud_url & "','" & cloud_secure_url  & "')"
		dbconn.execute(sqlu)
		
		'Response.Write(pStr)
		'Response.Write(pResult)
				
	Next
End If


If Request.Form("deleteid")&""<>"" Then
	'CheckGuid(Request.Form("deleteid"))
	For Each filepath In files
		'If InStr(1,FSO.GetBaseName(filepath),Request.Form("deleteid"),1)>0 Then
		If InStr(Request.Form("deleteid"),FSO.GetBaseName(filepath)) Then
			fso.DeleteFile(filepath)
			sql = "DELETE FROM " & g_storeid & "_product_image WHERE image_name='" & Request.Form("deleteid") & "'"
			dbconn.Execute(sql)
		End If
	Next
End If

Dim index
index=0
Response.Write("[")

sql = "SELECT * FROM " & g_storeid & "_product_image WHERE pf_id='" & pf_id & "' ORDER BY sort_order"
set rs = dbconn.Execute(sql)
do while not rs.EOF
	index=index+1
	If index>1 Then
		Response.Write(",")
	End If
	'Dim parts
	'parts=Split(fso.GetBaseName(filepath),".")
	Response.Write("{UploadTime:'")
	Response.Write(rs(2))
	Response.Write("'")
	
	ssImgSize = "upload/w_" & "100" & ",h_" & "100" & ",c_pad/"
	If Len(rs(3)) > 0 then
		g_image_url = Replace(rs(3), "upload/", ssImgSize)
	end if
	If Len(rs(4)) > 0 then
		g_secure_image_url = Replace(rs(4), "upload/", ssImgSize)
	end if
	
		
	Response.Write(",FileURI:'")
	Response.Write(g_image_url)
	Response.Write("'")
	Response.Write(",FileSecureURI:'")
	Response.Write(g_secure_image_url)
	Response.Write("'")
	Response.Write(",FileID:'")
	Response.Write(rs(1))
	Response.Write("'")
	Response.Write(",FileName:'")
	Response.Write(rs(1))
	Response.Write("'")
	Response.Write(",FileSize:'")
	Response.Write("")
	Response.Write("'")
	Response.Write(",FileLabel:'")
	Response.Write(rs(5))
	Response.Write("'")
	Response.Write(",FileSortOrder:'")
	Response.Write(rs(6))
	Response.Write("'")
	Response.Write(",FileUrl:'misc-filemanager-handler.asp?downloadfile=")
	Response.Write(rs(1))
	Response.Write("'")
	Response.Write("}")
	rs.MoveNext
loop
rs.Close
set rs = nothing


'For Each filepath In files
	'index=index+1
	'If index>1 Then
		'Response.Write(",")
	'End If
	'Dim parts
	'parts=Split(fso.GetBaseName(filepath),".")
	'Response.Write("{UploadTime:'")
	'Response.Write(parts(0))
	'Response.Write("'")
	'Response.Write(",FileID:'")
	'Response.Write(parts(1))
	'Response.Write("'")
	'Response.Write(",FileName:'")
	'Response.Write(Mid(fso.GetBaseName(filepath),58))
	'Response.Write("'")
	'Response.Write(",FileSize:'")
	'Response.Write(fso.GetFile(filepath).Size)
	'Response.Write("'")
	'Response.Write(",FileUrl:'misc-filemanager-handler.asp?downloadfile=")
	'Response.Write(parts(1))
	'Response.Write("'")
	'Response.Write("}")
'Next
Response.Write("]")

%>
