#Include <JSON>

Readini(_ConfigFile, _key:="", _Section:="") {
	if FileExist(_ConfigFile)
	{
		Iniread, initmp, %_ConfigFile%, %_Section%, %_key%
		return initmp
	}
}

Writeini(_ConfigFile, _value, _key, _Section:="Config") {
	if _value !=
		IniWrite, %_value%, %_ConfigFile%, %_Section%, %_key%
}

URLDownloadToVar(url, Encoding = "", Method="GET", postData="", headers:="") {
	hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.SetTimeouts(30000, 30000, 1200000, 1200000) 
	try
		hObject.Open(Method, url, (Method="POST" ? True : False))  
	
	if IsObject(headers)
	{
		for k, v in headers
		{
			if v
				hObject.SetRequestHeader(k, v)
		}
	}
	if postData
	{
		try
			hObject.Send(postData)
		hObject.WaitForResponse(-1)
	}
	else
	{
		try
			hObject.Send()
	}

	if (Encoding && hObject.ResponseBody)
	{
		oADO := ComObjCreate("adodb.stream")
		oADO.Type := 1
		oADO.Mode := 3
		oADO.Open()
		oADO.Write(hObject.ResponseBody)
		oADO.Position := 0
		oADO.Type := 2
		oADO.Charset := Encoding
		return oADO.ReadText(), oADO.Close()
	}
	try 
		return hObject.ResponseText
}

StrPutVar(sVar, ByRef sbin, encoding) {
	VarSetCapacity(sbin, StrPut(sVar, encoding)* ((encoding="utf-16"||encoding="cp1200")  ? 2 : 1))
    return (StrPut(sVar, &sbin, encoding) -1)* ((encoding="utf-16"||encoding="cp1200")  ? 2 : 1)
}

Urlencode(string, encoding:="utf-8") {
	bt:=StrPutVar(string,sb,encoding)
	Loop % bt
	{
		hex:=format("{1:02x}", hex2:=NumGet(&sb, A_index-1, "Uchar"))

		if hex2
		if (hex2==33 || (hex2>=39 && hex2 <=42) || hex2==45 || hex2 ==46 || (hex2>=48 && hex2<=57) || (hex2>=65 && hex2<=90) || hex2==95 || (hex2>=97 && hex2<=122) || hex2==126)
			content .=Chr(hex2)
		else
			content .="`%" hex
	}
	return content
}

Get_Token(BD_Key,BD_Secret) {
	BD_access_Token := Readini(ConfigFile, "Baidu_Token", "OCR设置")
	if BD_access_Token
		return BD_access_Token
	BD_Url := "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials"
	BD_Url := BD_Url "&client_id=" BD_Key "&client_secret=" BD_Secret
	BD_Json := JSON.Load(URLDownloadToVar(BD_Url))
	BD_access_Token := BD_Json.access_token
	if BD_access_Token {
		IniWrite, %BD_access_Token%, %ConfigFile%, OCR设置, Baidu_Token
		return BD_access_Token
	}
}

Get_Ocr(imgBase64, BD_access_Token, txttype := "general_basic") {
	BD_Url := "https://aip.baidubce.com/rest/2.0/ocr/v1/" txttype "?access_token=" BD_access_Token
	postdata := "image=" urlencode(imgBase64) "&paragraph=true"
	BD_ReturnTxt := URLDownloadToVar(BD_Url, "UTF-8", "POST", postdata, {"Content-Type":"application/x-www-form-urlencoded"})
	BD_Json := JSON.Load(BD_ReturnTxt)
	if BD_Json.error_msg != ""
		return BD_Json.error_msg
	wordsC := BD_Json.words_result_num
	hh := Readini(ConfigFile, "保留换行", "OCR设置")
	if wordsC > 1
	{
		Loop % wordsC
		{
			txtmp .= BD_Json.words_result[A_Index].words
			if hh
				txtmp .= "`n"
		}
		if !Readini(ConfigFile, "保留空格", "OCR设置")
			StringReplace, txtmp, txtmp, %A_Space%,,1
		return txtmp
	}
	else
	{
		Return BD_Json.words_result[1].words
	}
	Return 0
}

bdocr_Bitmap(base64, BD_access_Token) {
	if Readini(ConfigFile, "识别类型", "OCR设置")
		txttype := Readini(ConfigFile, "识别类型", "OCR设置")
	else
		txttype := "general_basic"
	return Get_Ocr(base64, BD_access_Token, txttype)
}

Gdip_EncodeBitmapTo64string(pBitmap, ext, Quality=100) {
    if Ext not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
        return -1
    Extension := "." Ext

    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
    if !(nCount && nSize)
    return -2

    Loop, %nCount%
    {
            sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
            if !InStr(sString, "*" Extension)
                continue

            pCodec := &ci+idx
            break
    }

    if !pCodec
        return -3

    if (Quality != 75)
    {
        Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
        if Extension in .JPG,.JPEG,.JPE,.JFIF
        {
                DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
                VarSetCapacity(EncoderParameters, nSize, 0)
                DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
                Loop, % NumGet(EncoderParameters, "UInt")
                {
                elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
                {
                        p := elem+&EncoderParameters-pad-4
                        NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
                        break
                }
                }
        }
    }

    DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
    DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)

    DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
    pData := DllCall("GlobalLock", "ptr",hData, "uptr")
    nSize := DllCall("GlobalSize", "uint",pData)

    VarSetCapacity(Bin, nSize, 0)
    DllCall("RtlMoveMemory", "ptr",&Bin , "ptr",pData , "uint",nSize)
    DllCall("GlobalUnlock", "ptr",hData)
    DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
    DllCall("GlobalFree", "ptr",hData)
    
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",0, "uint*",base64Length)
    VarSetCapacity(base64, base64Length*2, 0)
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr",&Bin, "uint",nSize, "uint",0x01, "ptr",&base64, "uint*",base64Length)
    Bin := ""
    VarSetCapacity(Bin, 0)
    VarSetCapacity(base64, -1)

    return base64
}

WM_SHOWWINDOW(wParam, lParam, msg, hwnd) {
	if % hwnd = sthwnd && wParam{
		Gui, st:Show, NA, 设置
		ControlFocus,, ahk_id %stHwnd%
		WinGet, ListC, ControlListHwnd, ahk_id %sthwnd%
		C_S := StrSplit(ListC,"`n")
		Global N_ := [],C_ := []
		N_len := 0
		loop % C_S.length() {
			GuiControlGet, cName, Name, % C_S[A_index]
			if cName{
				N_[N_len+=1] := cName
				C_[N_len] := C_S[A_index]
			}
		}
		C_S =
		Global _Tp:=["general_basic","accurate_basic","handwriting","webimage"]
		loop % N_len{
			tt := Readini(ConfigFile, N_[A_index], "OCR设置")
			if % N_[A_index] = "识别类型"{
				loop % _Tp.length() {
					if _Tp[A_index] = tt
						GuiControl, Choose, 识别类型, % A_index, break
				}
				continue
			}
			GuiControl,, % C_[A_index], %tt%
		}
		cz := 1
	}
	if % hwnd = sthwnd && !wParam
		WinClose, 设置
}

Gdip_Startup() {
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}

Gdip_Shutdown(pToken) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("FreeLibrary", Ptr, hModule)
	return 0
}

Gdip_CreateBitmapFromClipboard() {
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if !DllCall("OpenClipboard", Ptr, 0)
		return -1
	if !DllCall("IsClipboardFormatAvailable", "uint", 8)
		return -2
	if !hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
		return -3
	if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
		return -4
	if !DllCall("CloseClipboard")
		return -5
	DeleteObject(hBitmap)
	return pBitmap
}

Gdip_DisposeImage(pBitmap) {
    return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

DeleteObject(hObject) {
    return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}