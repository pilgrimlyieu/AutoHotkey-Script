#Include <JSON>

Request(url, Encoding := "", Method := "GET", postData := "", headers := "") {
    hObject := ComObject("WinHttp.WinHttpRequest.5.1")
    hObject.SetTimeouts(30000, 30000, 1200000, 1200000) 
    try
        hObject.Open(Method, url, (Method = "POST" ? True : False))  
    
    if IsObject(headers)
        for k, v in headers
            if v
                hObject.SetRequestHeader(k, v)
    if postData {
        try {
            hObject.Send(postData)
            hObject.WaitForResponse(-1)
        }
    }
    else
        try hObject.Send()

    if Encoding && hObject.ResponseBody {
        oADO      := ComObject("adodb.stream")
        oADO.Type := 1
        oADO.Mode := 3
        oADO.Open()
        oADO.Write(hObject.ResponseBody)
        oADO.Position := 0
        oADO.Type     := 2
        oADO.Charset  := Encoding
        return oADO.ReadText() oADO.Close()
    }
    try 
        return hObject.ResponseText
}

; Adapted from https://www.autohotkey.com/boards/viewtopic.php?p=516828
UrlEncode(str) {
    static Doc, JS
    if !IsSet(Doc) {
        Doc := ComObject("htmlfile")
        Doc.write('<meta http-equiv="X-UA-Compatible" content="IE=9">')
        JS := Doc.parentWindow
        ( Doc.documentMode < 9 && JS.execScript() )
    }
    Return JS.encodeURIComponent(str)
}

; Extracted from https://github.com/buliasz/AHKv2-Gdip/blob/master/Gdip_All.ahk
Gdip_EncodeBitmapTo64string(pBitmap, extension := "png", quality := 75) {

    ; Fill a buffer with the available image codec info.
    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &count:=0, "uint*", &size:=0)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", count, "uint", size, "ptr", ci := Buffer(size))

    ; struct ImageCodecInfo - http://www.jose.it-berater.org/gdiplus/reference/structures/imagecodecinfo.htm
    loop {
        if (A_Index > count)
        throw Error("Could not find a matching encoder for the specified file format.")

        idx := (48+7*A_PtrSize)*(A_Index-1)
    } until InStr(StrGet(NumGet(ci, idx+32+3*A_PtrSize, "ptr"), "UTF-16"), extension) ; FilenameExtension

    ; Get the pointer to the clsid of the matching encoder.
    pCodec := ci.ptr + idx ; ClassID

    ; JPEG default quality is 75. Otherwise set a quality value from [0-100].
    if (quality ~= "^-?\d+$") and ("image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16")) { ; MimeType
        ; Use a separate buffer to store the quality as ValueTypeLong (4).
        v := Buffer(4)
		NumPut("uint", quality, v)

        ; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
        ; enum ValueType - https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoderparametervaluetype
        ; clsid Image Encoder Constants - http://www.jose.it-berater.org/gdiplus/reference/constants/gdipimageencoderconstants.htm
        ep := Buffer(24+2*A_PtrSize)                  ; sizeof(EncoderParameter) = ptr + n*(28, 32)
        NumPut(  "uptr",     1, ep,            0)  ; Count
        DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", ep.ptr+A_PtrSize, "HRESULT")
        NumPut(  "uint",     1, ep, 16+A_PtrSize)  ; Number of Values
        NumPut(  "uint",     4, ep, 20+A_PtrSize)  ; Type
        NumPut(   "ptr", v.ptr, ep, 24+A_PtrSize)  ; Value
    }

    ; Create a Stream.
    DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", True, "ptr*", &pStream:=0, "HRESULT")
    DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "ptr", IsSet(ep) ? ep : 0)

    ; Get a pointer to binary data.
    DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "ptr*", &hbin:=0, "HRESULT")
    bin := DllCall("GlobalLock", "ptr", hbin, "ptr")
    size := DllCall("GlobalSize", "uint", bin, "uptr")

    ; Calculate the length of the base64 string.
    flags := 0x40000001 ; CRYPT_STRING_NOCRLF | CRYPT_STRING_BASE64
    length := 4 * Ceil(size/3) + 1 ; An extra byte of padding is required.
    str := Buffer(length)

    ; Using CryptBinaryToStringA saves about 2MB in memory.
    DllCall("crypt32\CryptBinaryToStringA", "ptr", bin, "uint", size, "uint", flags, "ptr", str, "uint*", &length)

    ; Release binary data and stream.
    DllCall("GlobalUnlock", "ptr", hbin)
    ObjRelease(pStream)
    
    ; Return encoded string length minus 1.
    return StrGet(str, length, "CP0")
}

Gdip_Startup() {
	if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
		throw Error("Could not load GDI+ library")
	}

	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("UInt", 1, si)
	DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.Ptr, "UPtr", 0)
	if (!pToken) {
		throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
	}

	return pToken
}

Gdip_Shutdown(pToken) {
	DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
	hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
	if (!hModule) {
		throw Error("GDI+ library was unloaded before shutdown")
	}
	if (!DllCall("FreeLibrary", "UPtr", hModule)) {
		throw Error("Could not free GDI+ library")
	}

	return 0
}

Gdip_CreateBitmapFromClipboard() {
	if !DllCall("IsClipboardFormatAvailable", "UInt", 8) {
		return -2
	}

	if !DllCall("OpenClipboard", "UPtr", 0) {
		return -1
	}

	hBitmap := DllCall("GetClipboardData", "UInt", 2, "UPtr")

	if !DllCall("CloseClipboard") {
		return -5
	}

	if !hBitmap {
		return -3
	}

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
	if (!pBitmap) {
		return -4
	}

    DllCall("DeleteObject", "UPtr", hBitmap) ; DeleteObject(hBitmap)

	return pBitmap
}

Gdip_DisposeImage(pBitmap) => DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0) {
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
	return pBitmap
}

GetScreenshot(SnipTime := 10, BufferTime := 1000, If3pSnip := 0, CmdOf3pSnip := "") {
    A_Clipboard := ""
    try {
        if !(If3pSnip && CmdOf3pSnip)
            throw
        Run CmdOf3pSnip
        RegExMatch(CmdOf3pSnip, "(?P<EXE>[^\/\\:*?`"<>|]+\.(?:exe|EXE)).*", &Snip)
    }
    catch
        SendInput("{LWin Down}{LShift Down}s{LShift Up}{LWin Up}")
    SnipEXE := IsSet(Snip) && HasProp(Snip, "EXE") ? Snip["EXE"] : "ScreenClippingHost.exe"
    Sleep(BufferTime)
    if WinWaitNotActive("ahk_exe " SnipEXE, , SnipTime - BufferTime / 1000) && ClipWait(0.5, 1)
        return 1
    return 0
}

Img2Base(Front := False, Quality := 75) {
    pToken       := Gdip_Startup()
    pBitmap      := Gdip_CreateBitmapFromClipboard()
    base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG", Quality)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    return Front ? "data:image/jpg;base64," base64string : base64string
}