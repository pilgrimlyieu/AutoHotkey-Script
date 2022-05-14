#Include <JSON>

ReadIni(_ConfigFile, _key := "", _Section := "") {
    Iniread initmp, %_ConfigFile%, %_Section%, %_key%
    return initmp
}

URLDownloadToVar(url, Encoding := "", Method := "GET", postData := "", headers := "") {
    hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    hObject.SetTimeouts(30000, 30000, 1200000, 1200000) 
    try
        hObject.Open(Method, url, (Method = "POST" ? True : False))  
    
    if IsObject(headers) {
        for k, v in headers {
            if v
                hObject.SetRequestHeader(k, v)
        }
    }
    if postData {
        try
            hObject.Send(postData)
        hObject.WaitForResponse(-1)
    }
    else {
        try
            hObject.Send()
    }

    if (Encoding && hObject.ResponseBody) {
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
    VarSetCapacity(sbin, StrPut(sVar, encoding))
    return (StrPut(sVar, &sbin, encoding) -1)
}

UrlEncode(string) {
    bt := StrPutVar(string, sb, "utf-8")
    loop % bt {
        hex := format("{1:02x}", hex2 := NumGet(&sb, A_index - 1, "Uchar"))
        if (hex2 == 33 || (hex2 >= 39 && hex2 <= 42) || hex2 == 45 || hex2 == 46 || (hex2 >= 48 && hex2 <= 57) || (hex2 >= 65 && hex2 <= 90) || hex2 == 95 || (hex2 >= 97 && hex2 <= 122) || hex2 == 126)
            content .= Chr(hex2)
        else
            content .= "`%" hex
    }
    return content
}

Gdip_EncodeBitmapTo64string(pBitmap, Ext, Quality := 75) {
    if Ext not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
        return -1
    Extension := "." Ext

    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
    if !(nCount && nSize)
        return -2

    loop %nCount% {
        sString := StrGet(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize), "UTF-16")
        if !InStr(sString, "*" Extension)
            continue

        pCodec := &ci + idx
        break
    }

    if !pCodec
        return -3

    if (Quality != 75) {
        Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
        if Extension in .JPG,.JPEG,.JPE,.JFIF 
        {
            DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
            VarSetCapacity(EncoderParameters, nSize, 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
            loop % NumGet(EncoderParameters, "UInt") {
                elem := (24 + (A_PtrSize ? A_PtrSize : 4)) * (A_Index - 1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                if (NumGet(EncoderParameters, elem + 16, "UInt") = 1) && (NumGet(EncoderParameters, elem + 20, "UInt") = 6) {
                    p := elem + &EncoderParameters - pad - 4
                    NumPut(Quality, NumGet(NumPut(4, NumPut(1, p + 0) + 20, "UInt")), "UInt")
                    break
                }
            }
        }
    }

    DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", true, "ptr*", pStream)
    DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "uint", p ? p : 0)

    DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "uint*", hData)
    pData := DllCall("GlobalLock", "ptr", hData, "uptr")
    nSize := DllCall("GlobalSize", "uint", pData)

    VarSetCapacity(Bin, nSize, 0)
    DllCall("RtlMoveMemory", "ptr", &Bin, "ptr", pData , "uint", nSize)
    DllCall("GlobalUnlock", "ptr", hData)
    DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr", pStream)
    DllCall("GlobalFree", "ptr", hData)
    
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr", &Bin, "uint", nSize, "uint", 0x01, "ptr",0, "uint*", base64Length)
    VarSetCapacity(base64, base64Length * 2, 0)
    DllCall("Crypt32.dll\CryptBinaryToString", "ptr", &Bin, "uint", nSize, "uint", 0x01, "ptr", &base64, "uint*", base64Length)
    Bin := ""
    VarSetCapacity(Bin, 0)
    VarSetCapacity(base64, -1)

    return base64
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
    DllCall("DeleteObject", Ptr, hBitmap)
    return pBitmap
}

Gdip_DisposeImage(pBitmap) {
    return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}

Gdip_CreateBitmapFromHBITMAP(hBitmap) {
    Ptr := A_PtrSize ? "UPtr" : "UInt"

    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    return pBitmap
}

GetScreenshot() {
    clipboard := ""
    Global Basic_SnipTime, Basic_WaitSnipTime, Advance_ThirdPartyScreenshotOnOff, Advance_ThirdPartyScreenshotPath
    try {
        if !Advance_ThirdPartyScreenshotOnOff
            throw
        Run % Advance_ThirdPartyScreenshotPath
        RegExMatch(Advance_ThirdPartyScreenshotPath, "(?P<Path>[^/\\]+\.(?:exe|EXE)).*", Snip)
    }
    catch e
        Send {LWin Down}{LShift Down}s{LShift Up}{LWin Up}
    SnipPath := SnipPath ? SnipPath : "ScreenClippingHost.exe"
    Sleep %Basic_WaitSnipTime%
    WinWaitNotActive ahk_exe %SnipPath%, , % Basic_SnipTime - Basic_WaitSnipTime / 1000
    if ErrorLevel
        return
    ClipWait 0.5, 1
    if ErrorLevel
        return
    return 1
}

Img2Base(Front := False, Quality := 75) {
    pToken := Gdip_Startup()
    pBitmap := Gdip_CreateBitmapFromClipboard()
    base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG", Quality)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    return Front ? "data:image/jpg;base64," base64string : base64string
}