#Include <JSON>

Request(url, Encoding := "", Method := "GET", postData := "", headers := "", proxy := "") {
    hObject := ComObject("WinHttp.WinHttpRequest.5.1")
    if proxy
        hObject.SetProxy(2, proxy)
    hObject.SetTimeouts(30000, 30000, 1200000, 1200000) 
    try hObject.Open(Method, url, (Method = "POST" ? True : False))  
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
    try return hObject.ResponseText
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

; Extracted & Modified from https://github.com/buliasz/AHKv2-Gdip/blob/master/Gdip_All.ahk
Gdip_EncodeBitmapTo64string(pBitmap, extension := "png", quality := 75) {
    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &count:=0, "uint*", &size:=0)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", count, "uint", size, "ptr", ci := Buffer(size))
    loop {
        if A_Index > count
            throw Error("Could not find a matching encoder for the specified file format.")
        idx := (48+7*A_PtrSize)*(A_Index-1)
    } until InStr(StrGet(NumGet(ci, idx+32+3*A_PtrSize, "ptr"), "UTF-16"), extension)
    pCodec := ci.ptr + idx
    if quality ~= "^-?\d+$" && "image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16") {
        v := Buffer(4)
        NumPut("uint", quality, v)
        ep := Buffer(24+2*A_PtrSize)                 
        NumPut(  "uptr",     1, ep,            0) 
        DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", ep.ptr+A_PtrSize, "HRESULT")
        NumPut(  "uint",     1, ep, 16+A_PtrSize) 
        NumPut(  "uint",     4, ep, 20+A_PtrSize) 
        NumPut(   "ptr", v.ptr, ep, 24+A_PtrSize) 
    }
    DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", True, "ptr*", &pStream:=0, "HRESULT")
    DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "ptr", IsSet(ep) ? ep : 0)
    DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "ptr*", &hbin:=0, "HRESULT")
    bin := DllCall("GlobalLock", "ptr", hbin, "ptr")
    size := DllCall("GlobalSize", "uint", bin, "uptr")
    flags := 0x40000001
    length := 4 * Ceil(size/3) + 1
    str := Buffer(length)
    DllCall("crypt32\CryptBinaryToStringA", "ptr", bin, "uint", size, "uint", flags, "ptr", str, "uint*", &length)
    DllCall("GlobalUnlock", "ptr", hbin)
    ObjRelease(pStream)
    return StrGet(str, length, "CP0")
}

Gdip_Startup() {
    if !DllCall("LoadLibrary", "str", "gdiplus", "UPtr")
        throw Error("Could not load GDI+ library")
    si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.Ptr, "UPtr", 0)
    if !pToken
        throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
    return pToken
}

Gdip_Shutdown(pToken) {
    DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
    hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
    if !hModule
        throw Error("GDI+ library was unloaded before shutdown")
    if !DllCall("FreeLibrary", "UPtr", hModule)
        throw Error("Could not free GDI+ library")
    return 0
}

Gdip_CreateBitmapFromClipboard() {
    if !DllCall("IsClipboardFormatAvailable", "UInt", 8)
        return -2
    if !DllCall("OpenClipboard", "UPtr", 0)
        return -1
    hBitmap := DllCall("GetClipboardData", "UInt", 2, "UPtr")
    if !DllCall("CloseClipboard")
        return -5
    if !hBitmap
        return -3
    if !(pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap))
        return -4
    DllCall("DeleteObject", "UPtr", hBitmap)
    return pBitmap
}

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0) {
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
    return pBitmap
}

Map2Array(in_map, forkey := 1) {
    out_array := []
    for key, value in in_map
        out_array.Push(forkey ? key : value)
    return out_array
}

Index2Value(in_map, index) => in_map[Map2Array(in_map)[index]]

IndexOf(item, list) {
    for index, value in list
        if value == item
            return index
}

GetScreenshot(SnipTime := 10, BufferTime := 1000, If3pSnip := 0, CmdOf3pSnip := "") {
    try {
        if !(If3pSnip && CmdOf3pSnip)
            throw
        Run(CmdOf3pSnip)
        RegExMatch(CmdOf3pSnip, "(?P<EXE>[^\/\\:*?`"<>|]+\.(?:exe|EXE)).*", &Snip)
    }
    catch
        Run("ms-screenclip:")
    SnipEXE := IsSet(Snip) ? Snip["EXE"] : "ScreenClippingHost.exe"
    if WinWaitActive("ahk_exe " SnipEXE, , BufferTime / 1000) && WinWaitNotActive("ahk_exe " SnipEXE, , SnipTime - BufferTime / 1000) && ClipWait(0.5, 1)
        return 1
    return 0
}

Img2Base64(Front := False, Quality := 75) {
    pToken       := Gdip_Startup()
    pBitmap      := Gdip_CreateBitmapFromClipboard()
    base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG", Quality)
    DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
    Gdip_Shutdown(pToken)
    return Front ? "data:image/jpg;base64," base64string : base64string
}

GlobalConstants() {
    ConfigSections := StrSplit(IniRead(OCRC_ConfigFilePath), "`n")
    for section_index, section in ConfigSections {
        ConfigKeys := StrSplit(IniRead(OCRC_ConfigFilePath, section), "`n")
        OCRC_Configs[section] := Map()
        for key_index, key in ConfigKeys {
            ConfigValues := StrSplit(key, "=", , 2)
            OCRC_Configs[section][ConfigValues[1]] := ConfigValues[2]
        }
    }
}

PrepareOCR(base64_front) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    if !GetScreenshot(OCRC_Configs["Basic"]["Basic_SnipTime"], OCRC_Configs["Basic"]["Basic_WaitSnipTime"], OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotOnOff"], OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotPath"]) {
        A_Clipboard := ClipSaved, ClipSaved := ""
        if OCRC_Configs["Basic"]["Basic_SnipWarning"]
            MsgBox("未检测到截图", "Clipping ERROR", "Iconx 0x1000")
        return
    }
    base64string := Img2Base64(base64_front, OCRC_Configs["Advance"]["Advance_EBto64SQuality"])
    A_Clipboard := ClipSaved, ClipSaved := ""
    return base64string
}

UpdateVar(CtrlObj, *) => IniWrite(OCRC_Configs[CtrlObj.Gui["Tabs"].Text][CtrlObj.Name] := CtrlObj.Value, OCRC_ConfigFilePath, CtrlObj.Gui["Tabs"].Text, CtrlObj.Name)

UpdateHotkey(CtrlObj, OCRFunction, *) {
    UpdateVar(CtrlObj)
    if !CtrlObj.Value
        return
    global Basic_TextOCRHotkey_temp, Basic_FormulaOCRHotkey_temp
    if CtrlObj.Name == "Basic_TextOCRHotkey" {
        Hotkey(Basic_TextOCRHotkey_temp, OCRFunction, "Off")
        Hotkey(CtrlObj.Value, OCRFunction, "On")
        Basic_TextOCRHotkey_temp := CtrlObj.Value
    }
    else {
        Hotkey(Basic_FormulaOCRHotkey_temp, OCRFunction, "Off")
        Hotkey(CtrlObj.Value, OCRFunction, "On")
        Basic_FormulaOCRHotkey_temp := CtrlObj.Value
    }
}

SwitchHotkey(CtrlObj, OCRType, OCRFunction, *) => (UpdateVar(CtrlObj), Hotkey(OCRC_Configs["Basic"][OCRType], OCRFunction, CtrlObj.Value ? "On" : "Off"))

CtrlToolTip(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if Hwnd != PrevHwnd {
        Text := "", ToolTip()
        if (CurrControl := GuiCtrlFromHwnd(Hwnd)) && CurrControl.HasProp("ToolTip")
            SetTimer(() => ToolTip(CurrControl.ToolTip), -500)
        PrevHwnd := Hwnd
    }
}

GoogleTranslate(text, from := "auto", to := "zh-CN", configs := {}) {
    result := ""
    try for index, sentence in JSON.parse(Request("https://translate.google.com/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=" from "&tl=" to "&q=" UrlEncode(text), , , , , configs.proxy))["sentences"]
        result .= sentence["trans"]
    if !result
        try for index, sentence in JSON.parse(Request("https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=" from "&tl=" to "&q=" UrlEncode(text), , , , , configs.proxy))[1]
            result .= sentence[1]
    return result
}