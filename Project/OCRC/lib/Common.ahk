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
    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &count := 0, "uint*", &size := 0)
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
    DllCall("ole32\CreateStreamOnHGlobal", "ptr", 0, "int", True, "ptr*", &pStream := 0, "HRESULT")
    DllCall("gdiplus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", pCodec, "ptr", ep ?? 0)
    DllCall("ole32\GetHGlobalFromStream", "ptr", pStream, "ptr*", &hbin := 0, "HRESULT")
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

Gdip_SetImageAttributesColorMatrix(Matrix) {
    ColourMatrix := Buffer(100, 0)
    Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
    Matrix := StrSplit(Matrix, "|")
    loop 25 {
        M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index-1, 6) ? 0 : 1
        NumPut("Float", M, ColourMatrix, (A_Index-1)*4)
    }
    DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", &ImageAttr := 0)
    DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "UPtr", ImageAttr, "Int", 1, "Int", 1, "UPtr", ColourMatrix.Ptr, "UPtr", 0, "Int", 0)
    return ImageAttr
}

Gdip_Startup() {
    if !DllCall("LoadLibrary", "str", "gdiplus", "UPtr")
        throw Error("Could not load GDI+ library")
    si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "UPtr", si.Ptr, "UPtr", 0)
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

Gdip_DrawImage(pGraphics, pBitmap, dx := "", dy := "", dw := "", dh := "", sx := "", sy := "", sw := "", sh := "", Matrix := 1) {
    if !IsNumber(Matrix)
        ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
    else if Matrix != 1
        ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
    else
        ImageAttr := 0
    if (sx = "" && sy = "" && sw = "" && sh = "") {
        if (dx = "" && dy = "" && dw = "" && dh = "") {
            sx := dx := 0, sy := dy := 0
            DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &sw := 0), dw := sw
            DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &sh := 0), dh := sh
        }
        else {
            sx := sy := 0
            DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &sw := 0)
            DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &sh := 0)
        }
    }
    _E := DllCall("gdiplus\GdipDrawImageRectRect", "UPtr", pGraphics, "UPtr", pBitmap, "Float", dx, "Float", dy, "Float", dw, "Float", dh, "Float", sx, "Float", sy, "Float", sw, "Float", sh, "Int", 2, "UPtr", ImageAttr, "UPtr", 0, "UPtr", 0)
    if ImageAttr
        DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
    return _E
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
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", 0, "UPtr*", &pBitmap := 0)
    if !pBitmap
        return -4
    DllCall("DeleteObject", "UPtr", hBitmap)
    return pBitmap
}

CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0) {
    hdc2 := hdc ? hdc : DllCall("GetDC", "UPtr", 0)
    bi := Buffer(40, 0)
    NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)
    hbm := DllCall("CreateDIBSection", "UPtr", hdc2, "UPtr", bi.Ptr, "UInt", 0, "UPtr*", &ppvBits, "UPtr", 0, "UInt", 0, "UPtr")
    if !hdc
        DllCall("ReleaseDC", "UPtr", hdc2, "UPtr", hdc)
    return hbm
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

ClipImg2Base64(Front := False, Quality := 75) {
    try {
        pToken       := Gdip_Startup()
        pBitmap      := Gdip_CreateBitmapFromClipboard()
        base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG", Quality)
        DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
        Gdip_Shutdown(pToken)
    }
    return Front ? "data:image/jpg;base64," base64string : base64string
}

ImgFile2Base64(ImgFile, Extension := "PNG", Front := False, Quality := 75) {
    try {
        pToken := Gdip_Startup()
        DllCall("gdiplus\GdipCreateBitmapFromFile", "UPtr", StrPtr(ImgFile), "UPtr*", &pBitmap := 0)
        base64string := Gdip_EncodeBitmapTo64string(pBitmap, Extension, Quality)
        DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
        Gdip_Shutdown(pToken)
    }
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
    base64string := ClipImg2Base64(base64_front, OCRC_Configs["Advance"]["Advance_EBto64SQuality"])
    A_Clipboard := ClipSaved, ClipSaved := ""
    return base64string
}

UpdateVar(CtrlObj, *) => IniWrite(OCRC_Configs[CtrlObj.Gui["Tabs"].Text][CtrlObj.Name] := CtrlObj.Value, OCRC_ConfigFilePath, CtrlObj.Gui["Tabs"].Text, CtrlObj.Name)

UpdateHotkey(OCRType, OCRKey, OCRFunction, IsOn, *) {
    global Basic_TextOCRHotkey_temp, Basic_FormulaOCRHotkey_temp
    if !IsOn
        return
    if OCRType == "Text" {
        Hotkey(Basic_TextOCRHotkey_temp, , "Off")
        Hotkey(OCRKey, OCRFunction, "On")
        Basic_TextOCRHotkey_temp := OCRKey
    }
    else if OCRType == "Formula"{
        Hotkey(Basic_FormulaOCRHotkey_temp, , "Off")
        Hotkey(OCRKey, OCRFunction, "On")
        Basic_FormulaOCRHotkey_temp := OCRKey
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

FileTextOCR(*) {
    GlobalConstants()
    images := FileSelect("M", , "选择图片进行文本 OCR（可多选）", "*.jpg; *.jpeg; *.png; *.bmp")
    if images
        for index, image in images {
            SplitPath(image, , , &extension)
            Basic_TextOCREngines[engine := Map2Array(Basic_TextOCREngines)[OCRC_Configs["Basic"]["Basic_TextOCREngine"]]]("", ImgFile2Base64(image, extension, Basic_Base64HaveFront[engine], OCRC_Configs["Advance"]["Advance_EBto64SQuality"]))
        }
}

DirectoryTextOCR(*) {
    GlobalConstants()
    images_directory := FileSelect("D", , "选择图片文件夹进行文本 OCR")
    if images_directory {
        always_overwrite := OCRC_Configs["Basic"]["Basic_AlwaysOverwrite"]
        loop files images_directory "\*.*" {
            if A_LoopFileExt ~= "jpg|jpeg|png|bmp" {
                ocr_object := Basic_TextOCREngines[engine := Map2Array(Basic_TextOCREngines)[OCRC_Configs["Basic"]["Basic_TextOCREngine"]]]("", ImgFile2Base64(A_LoopFileFUllPath, A_LoopFileExt, Basic_Base64HaveFront[engine], OCRC_Configs["Advance"]["Advance_EBto64SQuality"]), 0)
                SetTimer(ChangeButtonNames, 10)
                if have_file := FileExist(A_LoopFileFullPath ".txt") && (overwrite := always_overwrite || (overwrite := MsgBox("文件已存在，是否覆盖？", "OverwriteFile", "Icon? 0x1000 CancelTryAgainContinue")) == "TryAgain" || overwrite == "Continue") {
                    if overwrite == "Continue"
                        always_overwrite := 1
                    try FileDelete(images_directory "\" A_LoopFileName ".txt")
                    catch
                        MsgBox("覆盖失败", "Overwrite ERROR", "Iconx 0x1000")
                }
                if !have_file || overwrite == 1 || overwrite == "TryAgain" || overwrite == "Continue"
                FileAppend(ocr_object.__Process(False), images_directory "\" A_LoopFileName ".txt", "`n UTF-8")
            }
        }
        ChangeButtonNames() {
            if WinExist("OverwriteFile") {
                SetTimer(, 0)
                WinActivate
                ControlSetText("跳过", "Button1")
                ControlSetText("覆盖", "Button2")
                ControlSetText("总是覆盖", "Button3")
            }
        }
    }
}