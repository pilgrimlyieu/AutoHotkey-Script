/************************************************************************
 * @description Optical Character Recognition Commander
 * @file OCRC.ahk
 * @author PilgrimLyieu
 * @date 2023/08/24
 * @version 2.0.0-beta.6
 ***********************************************************************/

;@Ahk2Exe-SetMainIcon icon\OCRC.ico

if !FileExist("ahk-json.dll")
    FileInstall("lib\ahk-json.dll", "ahk-json.dll", 1)

#Include <Common>
#Include <Baidu>
#Include <Mathpix>

global OCRC_ConfigFilePath        := "OCRC.ini"
global OCRC_Configs               := Map()
global Baidu_RecognitionTypes     := Map(
    "general_basic",  "通用文字（标准）识别",
    "accurate_basic", "通用文字（高精度）识别",
    "handwriting",    "手写文字识别",
    "webimage",       "网络图片文字识别",
)
global Baidu_RecognitionTypes_key := [
    "general_basic",
    "accurate_basic",
    "handwriting",
    "webimage",
]
global Baidu_IsChinese            := "[\x{4e00}-\x{9fa5}]"
global Baidu_IsChineseBefore      := "(?:[\x{4e00}-\x{9fa5}]\s?)\K"
global Baidu_IsChineseAfter       := "(?=\s?[\x{4e00}-\x{9fa5}])"
global Baidu_IsEnglishBefore      := "([\w\d]\s?)\K"
global Baidu_IsEnglishAfter       := "(?=\s?[\w\d])"
global Baidu_c2ePunctuations      := Map(
    "，", ",",
    "。", ".",
    "？", "?",
    "！", "!",
    "、", ",",
    "：", ":",
    "；", ";",
    "“",  "`"",
    "”",  "`"",
    "‘",  "'",
    "’",  "'",
    "「", "`"",
    "」", "`"",
    "『", "'",
    "』", "'",
    "（", "(",
    "）", ")",
    "【", "[",
    "】", "]",
    "《", "",
    "》", "",
)
global Baidu_e2cPunctuations      := Map(
    ",", "，",
    ".", "。",
    "?", "？",
    "!", "！",
    ":", "：",
    ";", "；",
    "(", "（",
    ")", "）",
    "[", "【",
    "]", "】",
)
global Baidu_TranslationEngines   := Map(
    "谷歌翻译", GoogleTranslate,
    "腾讯翻译", TencentTranslate,
)
global Baidu_TranslationEngines_key := [
    "谷歌翻译",
    "腾讯翻译",
]
global Baidu_TranslationTypes     := Map(
    "自动检测", ["auto", "zh-CN"],
    "英->中", ["en", "zh-CN"],
    "中->英", ["zh-CN", "en"],
    "繁->简", ["zh-TW", "zh-CN"],
    "日->中", ["ja", "zh-CN"],
)
global Baidu_TranslationTypes_key := [
    "自动检测",
    "英->中",
    "中->英",
    "繁->简",
    "日->中",
]
global Mathpix_InlineStyles       := [
    ["$", "$"],
    ["\(", "\)"],
]
global Mathpix_DisplayStyles      := [
    ["$$", "$$"],
    ["\[", "\]"],
]

A_IconTip := "OCRC"
A_TrayMenu.Delete()
A_TrayMenu.Add("设置", (*) => SettingGUI())
A_TrayMenu.Add("重启", (*) => Reload())
A_TrayMenu.Add("退出", (*) => ExitApp())
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default := "设置"

if !FileExist(OCRC_ConfigFilePath)
    CreateConfig()

ConfigSections := StrSplit(IniRead(OCRC_ConfigFilePath), "`n")
for section_index, section in ConfigSections {
    ConfigKeys := StrSplit(IniRead(OCRC_ConfigFilePath, section), "`n")
    for key_index, key in ConfigKeys {
        ConfigValues := StrSplit(key, "=", , 2)
        OCRC_Configs[ConfigValues[1]] := ConfigValues[2]
    }
}

global Baidu_SearchEngines := Map()
SearchEnginesKeys := StrSplit(IniRead(OCRC_ConfigFilePath, "Baidu_SearchEngines"), "`n")
for key_index, key in SearchEnginesKeys {
    ConfigValues := StrSplit(key, "=", , 2)
    Baidu_SearchEngines[ConfigValues[1]] := ConfigValues[2]
}
global Baidu_SearchEngines_key := []
for key, value in Baidu_SearchEngines
    Baidu_SearchEngines_key.Push(key)

global Baidu_HotkeyTemp := OCRC_Configs["Baidu_Hotkey"], Mathpix_HotkeyTemp := OCRC_Configs["Mathpix_Hotkey"]
if OCRC_Configs["Basic_BaiduOCROnOff"]
    Hotkey(OCRC_Configs["Baidu_Hotkey"], OCRC_BaiduOCR, "On")
if OCRC_Configs["Basic_MathpixOCROnOff"]
    Hotkey(OCRC_Configs["Mathpix_Hotkey"], OCRC_MathpixOCR, "On")

OCRC_BaiduOCR(ThisHotkey) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    if !GetScreenshot(OCRC_Configs["Basic_SnipTime"], OCRC_Configs["Basic_WaitSnipTime"], OCRC_Configs["Advance_ThirdPartyScreenshotOnOff"], OCRC_Configs["Advance_ThirdPartyScreenshotPath"]) {
        A_Clipboard := ClipSaved, ClipSaved := ""
        if OCRC_Configs["Basic_SnipWarning"]
            MsgBox("未检测到截图", "Clipping ERROR", "Iconx 0x1000")
        return
    }
    base64string := Img2Base(False, OCRC_Configs["Advance_EBto64SQuality"])
    A_Clipboard := ClipSaved, ClipSaved := ""

    BaiduOCR := Baidu(
        Map(
            "paragraph"  , "true",
            "probability", OCRC_Configs["Baidu_ProbabilityType"] ? "true" : "false",
        ),
        Map(
            "api_key",            OCRC_Configs["Baidu_APIKey"],
            "secret_key",         OCRC_Configs["Baidu_SecretKey"],
            "image_base64",       base64string,
            "recognition_type",   Baidu_RecognitionTypes_key[OCRC_Configs["Baidu_RecognitionType"]],
            "probability_type",   OCRC_Configs["Baidu_ProbabilityType"],
            "format_style",       OCRC_Configs["Baidu_FormatStyle"],
            "punctuation_style",  OCRC_Configs["Baidu_PunctuationStyle"],
            "space_style",        OCRC_Configs["Baidu_SpaceStyle"],
            "translation_engine", OCRC_Configs["Baidu_TranslationEngine"],
            "translation_proxy",  OCRC_Configs["Advance_GoogleTranslationProxy"],
            "translation_type",   OCRC_Configs["Baidu_TranslationType"],
            "search_engine",      OCRC_Configs["Baidu_SearchEngine"],
            "close_and_search",   OCRC_Configs["Baidu_CloseAndSearch"],
        )
    )
}

OCRC_MathpixOCR(ThisHotkey) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    if !GetScreenshot(OCRC_Configs["Basic_SnipTime"], OCRC_Configs["Basic_WaitSnipTime"], OCRC_Configs["Advance_ThirdPartyScreenshotOnOff"], OCRC_Configs["Advance_ThirdPartyScreenshotPath"]) {
        A_Clipboard := ClipSaved, ClipSaved := ""
        if OCRC_Configs["Basic_SnipWarning"]
            MsgBox("未检测到截图", "Clipping ERROR", "Iconx 0x1000")
        return
    }
    base64string := Img2Base(True, OCRC_Configs["Advance_EBto64SQuality"])
    A_Clipboard := ClipSaved, ClipSaved := ""

    MathpixOCR := Mathpix(
        Map(
            "math_inline_delimiters" , Mathpix_InlineStyles[OCRC_Configs["Mathpix_InlineStyle"]],
            "math_display_delimiters", Mathpix_DisplayStyles[OCRC_Configs["Mathpix_DisplayStyle"]],
            "default_select",          OCRC_Configs["Mathpix_DefaultSelect"],
        ),
        Map(
            "app_id",       OCRC_Configs["Mathpix_AppID"],
            "app_key",      OCRC_Configs["Mathpix_AppKey"],
            "image_base64", base64string,
        )
    )
}

CreateConfig() {
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_BaiduOCROnOff")
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_MathpixOCROnOff")
    IniWrite(10,  OCRC_ConfigFilePath, "Basic", "Basic_SnipTime")
    IniWrite(500, OCRC_ConfigFilePath, "Basic", "Basic_WaitSnipTime")
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_SnipWarning")

    IniWrite(75, OCRC_ConfigFilePath, "Advance", "Advance_EBto64SQuality")
    IniWrite(0,  OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotOnOff")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotPath")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_GoogleTranslationProxy")

    IniWrite("F7",  OCRC_ConfigFilePath, "Baidu", "Baidu_Hotkey")
    IniWrite("",    OCRC_ConfigFilePath, "Baidu", "Baidu_APIKey")
    IniWrite("",    OCRC_ConfigFilePath, "Baidu", "Baidu_SecretKey")
    IniWrite("",    OCRC_ConfigFilePath, "Baidu", "Baidu_Token")
    IniWrite(A_Now, OCRC_ConfigFilePath, "Baidu", "Baidu_TokenExpiration")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_RecognitionType")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_ProbabilityType")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_FormatStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_PunctuationStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_SpaceStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_TranslationEngine")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_TranslationType")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_SearchEngine")
    IniWrite(1,     OCRC_ConfigFilePath, "Baidu", "Baidu_CloseAndSearch")

    IniWrite("https://www.baidu.com/s?wd=@W",      OCRC_ConfigFilePath, "Baidu_SearchEngines", "百度")
    IniWrite("https://www.google.com/search?q=@W", OCRC_ConfigFilePath, "Baidu_SearchEngines", "谷歌")
    IniWrite("https://cn.bing.com/search?q=@W",    OCRC_ConfigFilePath, "Baidu_SearchEngines", "必应")
    IniWrite("https://baike.baidu.com/item/@W",    OCRC_ConfigFilePath, "Baidu_SearchEngines", "百度百科")
    IniWrite("https://zh.wikipedia.org/wiki/@W",   OCRC_ConfigFilePath, "Baidu_SearchEngines", "维基百科")

    IniWrite("F4", OCRC_ConfigFilePath, "Mathpix", "Mathpix_Hotkey")
    IniWrite("",   OCRC_ConfigFilePath, "Mathpix", "Mathpix_AppID")
    IniWrite("",   OCRC_ConfigFilePath, "Mathpix", "Mathpix_AppKey")
    IniWrite(1,    OCRC_ConfigFilePath, "Mathpix", "Mathpix_InlineStyle")
    IniWrite(1,    OCRC_ConfigFilePath, "Mathpix", "Mathpix_DisplayStyle")
    IniWrite(1,    OCRC_ConfigFilePath, "Mathpix", "Mathpix_DefaultSelect")
}

SettingGUI() {
    if !FileExist(OCRC_ConfigFilePath)
        CreateConfig()

    Setting := Gui(, "OCRC Setting")
    Setting.Title := "OCRC 设置"
    Setting.BackColor := "EBEDF4"
    Setting.MarginX := 10
    Setting.MarginY := 10
    Setting.Opt("AlwaysOnTop")
    Setting.SetFont("s12", "Microsoft YaHei")
    Tabs := Setting.AddTab3("vTabs Choose1", ["Basic", "Advance", "Baidu", "Mathpix"])

    Tabs.UseTab("Basic")
    Setting.AddGroupBox("x20 y50 w310 h100", "OCR 启用")
    Setting.AddCheckBox("x32 y80 w90 vBasic_BaiduOCROnOff Right Checked" OCRC_Configs["Basic_BaiduOCROnOff"], "Baidu").OnEvent("Click", SwitchHotkey)
    Setting.AddCheckBox("x32 y+15 w90 vBasic_MathpixOCROnOff Right Checked" OCRC_Configs["Basic_MathpixOCROnOff"], "Mathpix").OnEvent("Click", SwitchHotkey)

    Setting.AddGroupBox("x20 y160 w310 h150", "截图")
    Setting.AddText("x15 y190 w80 h25 Right", "截图时间")
    Setting.AddEdit("x+15 w80 vBasic_SnipTime Number", OCRC_Configs["Basic_SnipTime"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vBasic_SnipTime_extra Range5-60", OCRC_Configs["Basic_SnipTime"])
    Setting.AddText("x200 y190 w20 h25 Left", "秒")
    Setting.AddText("x15 y+15 w80 h25 Right", "缓冲时间")
    Setting.AddEdit("x+15 w80 vBasic_WaitSnipTime Number", OCRC_Configs["Basic_WaitSnipTime"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vBasic_WaitSnipTime_extra Range100-5000 0x80", OCRC_Configs["Basic_WaitSnipTime"])
    Setting.AddText("x200 y230 w40 h25 Left", "毫秒")
    Setting.AddCheckBox("x21 y+15 w200 vBasic_SnipWarning Right Checked" OCRC_Configs["Basic_SnipWarning"], "未检测到截图时抛出警告").OnEvent("Click", UpdateVar)

    Tabs.UseTab("Advance")
    Setting.AddGroupBox("x20 y50 w310 h80", "高级设置")
    Setting.AddText("x15 y80 w90 h25 Right", "编码精度")
    Setting.AddEdit("x+15 w60 vAdvance_EBto64SQuality Number", OCRC_Configs["Advance_EBto64SQuality"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vAdvance_EBto64SQuality_extra Range0-100", OCRC_Configs["Advance_EBto64SQuality"])

    Setting.AddGroupBox("x20 y140 w310 h110", "外部截图软件支持")
    Setting.AddCheckBox("x32 y170 w90 vAdvance_ThirdPartyScreenshotOnOff Right Checked" OCRC_Configs["Advance_ThirdPartyScreenshotOnOff"], "启用").OnEvent("Click", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "路径")
    Setting.AddEdit("x+15 w200 h25 vAdvance_ThirdPartyScreenshotPath", OCRC_Configs["Advance_ThirdPartyScreenshotPath"]).OnEvent("Change", UpdateVar)

    Setting.AddGroupBox("x20 y260 w310 h150", "翻译设置")
    Setting.AddText("x15 y290 w145 h25 Right", "谷歌翻译代理")
    Setting.AddEdit("x+15 w145 h25 vAdvance_GoogleTranslationProxy", OCRC_Configs["Advance_GoogleTranslationProxy"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w145 h25 Right", "腾讯翻译 SecretID")
    Setting.AddEdit("x+15 w145 h25 vAdvance_TencentTranslationSecretID", OCRC_Configs["Advance_TencentTranslationSecretID"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w145 h25 Right", "腾讯翻译 SecretKey")
    Setting.AddEdit("x+15 w145 h25 vAdvance_TencentTranslationSecretKey", OCRC_Configs["Advance_TencentTranslationSecretKey"]).OnEvent("Change", UpdateVar)

    Tabs.UseTab("Baidu")
    Setting.AddGroupBox("x20 y50 w310 h230", "基础设置")
    Setting.AddText("x15 y80 w90 h25 Right", "热键")
    Setting.AddHotkey("x+15 w200 h25 vBaidu_Hotkey", OCRC_Configs["Baidu_Hotkey"]).OnEvent("Change", UpdateHotkey)
    Setting.AddText("x15 y+15 w90 h25 Right", "API Key")
    Setting.AddEdit("x+15 w200 h25 vBaidu_APIKey", OCRC_Configs["Baidu_APIKey"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "Secret Key")
    Setting.AddEdit("x+15 w200 h25 vBaidu_SecretKey", OCRC_Configs["Baidu_SecretKey"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "识别类型")
    Setting.AddDropDownList("x+15 w200 vBaidu_RecognitionType AltSubmit Choose" OCRC_Configs["Baidu_RecognitionType"], ["通用文字（标准）识别", "通用文字（高精度）识别", "手写文字识别", "网络图片文字识别"]).OnEvent("Change", UpdateVar)
    Setting.AddCheckBox("x32 y+15 w90 vBaidu_ProbabilityType Right Check3 Checked" OCRC_Configs["Baidu_ProbabilityType"], "置信度").OnEvent("Click", UpdateVar)

    Setting.AddGroupBox("x20 y290 w310 h310", "默认选项")
    Setting.AddText("x15 y320 w120 h25 Right", "默认选项")
    Setting.AddDropDownList("x+15 w170 vBaidu_FormatStyle AltSubmit Choose" OCRC_Configs["Baidu_FormatStyle"], ["智能段落", "合并多行", "拆分多行"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w120 h25 Right", "默认标点")
    Setting.AddDropDownList("x+15 w170 vBaidu_PunctuationStyle AltSubmit Choose" OCRC_Configs["Baidu_PunctuationStyle"], ["智能标点", "原始结果", "中文标点", "英文标点"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w120 h25 Right", "默认空格")
    Setting.AddDropDownList("x+15 w170 vBaidu_SpaceStyle AltSubmit Choose" OCRC_Configs["Baidu_SpaceStyle"], ["智能空格", "原始结果", "去除空格"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w120 h25 Right", "默认翻译引擎")
    Setting.AddDropDownList("x+15 w170 vBaidu_TranslationEngine AltSubmit Choose" OCRC_Configs["Baidu_TranslationEngine"], Baidu_TranslationEngines_key).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w120 h25 Right", "默认翻译类型")
    Setting.AddDropDownList("x+15 w170 vBaidu_TranslationType AltSubmit Choose" OCRC_Configs["Baidu_TranslationType"], Baidu_TranslationTypes_key).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w120 h25 Right", "默认搜索引擎")
    Setting.AddDropDownList("x+15 w170 vBaidu_SearchEngine AltSubmit Choose" OCRC_Configs["Baidu_SearchEngine"], Baidu_SearchEngines_key).OnEvent("Change", UpdateVar)
    Setting.AddCheckBox("x18 y+15 w180 vBaidu_CloseAndSearch Right Checked" OCRC_Configs["Baidu_CloseAndSearch"], "搜索时关闭结果窗口").OnEvent("Click", UpdateVar)

    Tabs.UseTab("Mathpix")
    Setting.AddGroupBox("x20 y50 w310 h150", "基础设置")
    Setting.AddText("x15 y80 w90 h25 Right", "热键")
    Setting.AddHotkey("x+15 w200 h25 vMathpix_Hotkey", OCRC_Configs["Mathpix_Hotkey"]).OnEvent("Change", UpdateHotkey)
    Setting.AddText("x15 y+15 w90 h25 Right", "App ID")
    Setting.AddEdit("x+15 w200 h25 vMathpix_AppID", OCRC_Configs["Mathpix_AppID"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "App Key")
    Setting.AddEdit("x+15 w200 h25 vMathpix_AppKey", OCRC_Configs["Mathpix_AppKey"]).OnEvent("Change", UpdateVar)

    Setting.AddGroupBox("x20 y210 w310 h150", "默认选项")
    Setting.AddText("x15 y240 w90 h25 Right", "行内公式")
    Setting.AddDropDownList("x+15 w200 vMathpix_InlineStyle AltSubmit Choose" OCRC_Configs["Mathpix_InlineStyle"], ["$...$", "\(...\)"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "行间公式")
    Setting.AddDropDownList("x+15 w200 vMathpix_DisplayStyle AltSubmit Choose" OCRC_Configs["Mathpix_DisplayStyle"], ["$$...$$", "\[...\]"]).OnEvent("Change", UpdateVar)
    Setting.AddText("x15 y+15 w90 h25 Right", "默认选择")
    Setting.AddDropDownList("x+15 w200 vMathpix_DefaultSelect AltSubmit Choose" OCRC_Configs["Mathpix_DefaultSelect"], ["LaTeX", "行内公式", "行间公式"]).OnEvent("Change", UpdateVar)
    Setting.Show()
}

UpdateVar(CtrlObj, *) => IniWrite(OCRC_Configs[CtrlObj.Name] := CtrlObj.Value, OCRC_ConfigFilePath, CtrlObj.Gui["Tabs"].Text, CtrlObj.Name)

UpdateHotkey(CtrlObj, *) {
    UpdateVar(CtrlObj)
    if !CtrlObj.Value
        return
    global Baidu_HotkeyTemp, Mathpix_HotkeyTemp
    if CtrlObj.Name == "Baidu_Hotkey" {
        Hotkey(Baidu_HotkeyTemp, OCRC_BaiduOCR, "Off")
        Hotkey(CtrlObj.Value, OCRC_BaiduOCR, "On")
        Baidu_HotkeyTemp := CtrlObj.Value
    }
    else {
        Hotkey(Mathpix_HotkeyTemp, OCRC_MathpixOCR, "Off")
        Hotkey(CtrlObj.Value, OCRC_MathpixOCR, "On")
        Mathpix_HotkeyTemp := CtrlObj.Value
    }
}

SwitchHotkey(CtrlObj, *) => (UpdateVar(CtrlObj), Hotkey(OCRC_Configs["Baidu_Hotkey"], OCRC_BaiduOCR, CtrlObj.Value ? "On" : "Off"))

!a::SettingGUI()