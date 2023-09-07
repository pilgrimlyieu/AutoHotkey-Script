/************************************************************************
 * @description Optical Character Recognition Commander
 * @file OCRC.ahk
 * @author PilgrimLyieu
 * @date 2023/08/24
 * @version 2.1.0-develop
 ***********************************************************************/

;@Ahk2Exe-SetMainIcon icon\OCRC.ico

if !FileExist("ahk-json.dll")
    FileInstall("lib\ahk-json.dll", "ahk-json.dll")

#Include <Common>
#Include <Translate>
#Include <BaiduOCR>
#Include <MathpixOCR>
#Include <BingOCR>

global OCRC_ConfigFilePath           := "OCRC.ini"
global OCRC_Configs                  := Map()
global OCRC_LaTeXInlineStyles        := [
    ["$", "$"],
    ["\(", "\)"],
]
global OCRC_LaTeXDisplayStyles       := [
    ["$$", "$$"],
    ["\[", "\]"],
]
global BaiduOCR_RecognitionTypes     := Map(
    "general_basic",  "通用文字（标准）识别",
    "accurate_basic", "通用文字（高精度）识别",
    "handwriting",    "手写文字识别",
    "webimage",       "网络图片文字识别",
)
global BaiduOCR_IsChinese            := "[\x{4e00}-\x{9fa5}]"
global BaiduOCR_IsChineseBefore      := "(?:[\x{4e00}-\x{9fa5}]\s?)\K"
global BaiduOCR_IsChineseAfter       := "(?=\s?[\x{4e00}-\x{9fa5}])"
global BaiduOCR_IsEnglishBefore      := "([\w\d]\s?)\K"
global BaiduOCR_IsEnglishAfter       := "(?=\s?[\w\d])"
global BaiduOCR_c2ePunctuations      := Map(
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
global BaiduOCR_e2cPunctuations      := Map(
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
global BaiduOCR_TranslateEngines     := Map(
    "谷歌翻译", GoogleTranslate,
    "腾讯翻译", TencentTranslate,
)
global BaiduOCR_TranslateTypes       := Map( ; TODO Add more translate types
    "自动检测", ["auto", "zh-CN"],
    "英->中", ["en", "zh-CN"],
    "中->英", ["zh-CN", "en"],
    "繁->简", ["zh-TW", "zh-CN"],
    "日->中", ["ja", "zh-CN"],
)

if !FileExist(OCRC_ConfigFilePath)
    CreateConfig()

UpdateGlobalVar()

A_IconTip := "OCRC"
A_TrayMenu.Delete()
A_TrayMenu.Add("设置", (*) => SettingGUI())
A_TrayMenu.Add("重启", (*) => Reload())
A_TrayMenu.Add("退出", (*) => ExitApp())
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default := "设置"

global BaiduOCR_HotkeyTemp := OCRC_Configs["BaiduOCR"]["BaiduOCR_Hotkey"], MathpixOCR_HotkeyTemp := OCRC_Configs["MathpixOCR"]["MathpixOCR_Hotkey"]
if OCRC_Configs["Basic"]["Basic_BaiduOCROnOff"]
    Hotkey(OCRC_Configs["BaiduOCR"]["BaiduOCR_Hotkey"], OCRC_BaiduOCR, "On")
if OCRC_Configs["Basic"]["Basic_MathpixOCROnOff"]
    Hotkey(OCRC_Configs["MathpixOCR"]["MathpixOCR_Hotkey"], OCRC_MathpixOCR, "On")

OCRC_BaiduOCR(ThisHotkey) {
    UpdateGlobalVar()
    if base64string := PrepareOCR(False)
        BaiduOCR := Baidu(
            Map(
                "paragraph",     "true",
                "probability",   OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"] ? "true" : "false",
                "language_type", Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"], 0)[OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"]]
            ),
            Map(
                "api_key",           OCRC_Configs["BaiduOCR"]["BaiduOCR_APIKey"],
                "secret_key",        OCRC_Configs["BaiduOCR"]["BaiduOCR_SecretKey"],
                "token",             OCRC_Configs["BaiduOCR"]["BaiduOCR_Token"],
                "token_expiration",  OCRC_Configs["BaiduOCR"]["BaiduOCR_TokenExpiration"],
                "image_base64",      base64string,
                "recognition_type",  Map2Array(BaiduOCR_RecognitionTypes)[OCRC_Configs["BaiduOCR"]["BaiduOCR_RecognitionType"]],
                "probability_type",  OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"],
                "format_style",      OCRC_Configs["BaiduOCR"]["BaiduOCR_FormatStyle"],
                "punctuation_style", OCRC_Configs["BaiduOCR"]["BaiduOCR_PunctuationStyle"],
                "space_style",       OCRC_Configs["BaiduOCR"]["BaiduOCR_SpaceStyle"],
                "translate_engine",  OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateEngine"],
                "translate_proxy",   OCRC_Configs["Advance"]["Advance_GoogleTranslateProxy"],
                "translate_type",    OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateType"],
                "search_engine",     OCRC_Configs["BaiduOCR"]["BaiduOCR_SearchEngine"],
                "close_and_search",  OCRC_Configs["BaiduOCR"]["BaiduOCR_CloseAndSearch"],
            )
        )
}

OCRC_MathpixOCR(ThisHotkey) {
    UpdateGlobalVar()
    if base64string := PrepareOCR(True)
        MathpixOCR := Mathpix(
            Map(
                "math_inline_delimiters",  OCRC_LaTeXInlineStyles[OCRC_Configs["LaTeX"]["LaTeX_InlineStyle"]],
                "math_display_delimiters", OCRC_LaTeXDisplayStyles[OCRC_Configs["LaTeX"]["LaTeX_DisplayStyle"]],
                "default_select",          OCRC_Configs["MathpixOCR"]["MathpixOCR_DefaultSelect"],
            ),
            Map(
                "app_id",       OCRC_Configs["MathpixOCR"]["MathpixOCR_AppID"],
                "app_key",      OCRC_Configs["MathpixOCR"]["MathpixOCR_AppKey"],
                "image_base64", base64string,
            )
        )
}

OCRC_BingOCR(ThisHotkey) {
    UpdateGlobalVar()
    if base64string := PrepareOCR(True)
        BingOCR := Bing(
            Map(
                "image_base64", base64string,
                "math_inline_delimiters",  OCRC_LaTeXInlineStyles[OCRC_Configs["LaTeX"]["LaTeX_InlineStyle"]],
                "math_display_delimiters", OCRC_LaTeXDisplayStyles[OCRC_Configs["LaTeX"]["LaTeX_DisplayStyle"]],
            )
        )
}

!a::SettingGUI()

SettingGUI() {
    if !FileExist(OCRC_ConfigFilePath)
        CreateConfig()
    UpdateGlobalVar()

    Setting := Gui(, "OCRC Setting")
    Setting.OnEvent("Close", (*) => (
        OnMessage(0x200, CtrlToolTip, 0)
        OnMessage(0x2A3, (*) => ToolTip(), 0)
        ToolTip()
    ))
    Setting.Title := "OCRC 设置"
    Setting.BackColor := "EBEDF4"
    Setting.MarginX := 10
    Setting.MarginY := 10
    Setting.Opt("AlwaysOnTop")
    Setting.SetFont("s12", "Microsoft YaHei")
    Setting.AddTab3("vTabs Choose1", ["Basic", "Advance", "BaiduOCR", "MathpixOCR", "LaTeX"])

    Setting["Tabs"].UseTab("Basic")
    Setting.AddGroupBox("x20 y50 w310 h100", "OCR 启用")
    Setting.AddCheckBox("x32 y80 w115 vBasic_BaiduOCROnOff Right Checked" OCRC_Configs["Basic"]["Basic_BaiduOCROnOff"], "BaiduOCR").OnEvent("Click", SwitchHotkey)
    Setting["Basic_BaiduOCROnOff"].ToolTip := "设置是否启用百度 OCR 识别"
    Setting.AddCheckBox("x32 y+15 w115 vBasic_MathpixOCROnOff Right Checked" OCRC_Configs["Basic"]["Basic_MathpixOCROnOff"], "MathpixOCR").OnEvent("Click", SwitchHotkey)
    Setting["Basic_MathpixOCROnOff"].ToolTip := "设置是否启用 Mathpix OCR 识别"

    Setting.AddGroupBox("x20 y160 w310 h150", "截图")
    Setting.AddText("x15 y190 w80 h25 Right", "截图时间")
    Setting.AddEdit("x+15 w80 vBasic_SnipTime Number", OCRC_Configs["Basic"]["Basic_SnipTime"]).OnEvent("Change", UpdateVar)
    Setting["Basic_SnipTime"].ToolTip := "设置截图时间。超时将自动结束 OCR"
    Setting.AddUpDown("vBasic_SnipTime_extra Range5-60", OCRC_Configs["Basic"]["Basic_SnipTime"])
    Setting.AddText("x200 y190 w20 h25 Left", "秒")
    Setting.AddText("x15 y+15 w80 h25 Right", "缓冲时间")
    Setting.AddEdit("x+15 w80 vBasic_WaitSnipTime Number", OCRC_Configs["Basic"]["Basic_WaitSnipTime"]).OnEvent("Change", UpdateVar)
    Setting["Basic_WaitSnipTime"].ToolTip := "设置等待截图窗口出现的缓冲时间。设置时间过短可能导致经常性的截图失败。超时将自动结束 OCR"
    Setting.AddUpDown("vBasic_WaitSnipTime_extra Range100-5000 0x80", OCRC_Configs["Basic"]["Basic_WaitSnipTime"])
    Setting.AddText("x200 y230 w40 h25 Left", "毫秒")
    Setting.AddCheckBox("x21 y+15 w200 vBasic_SnipWarning Right Checked" OCRC_Configs["Basic"]["Basic_SnipWarning"], "未检测到截图时抛出警告").OnEvent("Click", UpdateVar)
    Setting["Basic_SnipWarning"].ToolTip := "设置是否在未检测到截图时抛出警告"

    Setting.AddGroupBox("x20 y320 w310 h75", "OCRC")
    Setting.AddCheckBox("x20 y350 w155 vBasic_OCRCToolTips Right Checked" OCRC_Configs["Basic"]["Basic_OCRCToolTips"], "设置界面工具提示").OnEvent("Click", (CtrlObj, *) => (
        UpdateVar(CtrlObj),
        OnMessage(0x200, CtrlToolTip, CtrlObj.Value)
        OnMessage(0x2A3, (*) => ToolTip(), CtrlObj.Value)
        ToolTip()
    ))
    Setting["Basic_OCRCToolTips"].ToolTip := "设置是否在 OCRC 设置界面显示工具提示"

    Setting["Tabs"].UseTab("Advance")
    Setting.AddGroupBox("x20 y50 w310 h80", "高级设置")
    Setting.AddText("x15 y80 w90 h25 Right", "编码精度")
    Setting.AddEdit("x+15 w60 vAdvance_EBto64SQuality Number", OCRC_Configs["Advance"]["Advance_EBto64SQuality"]).OnEvent("Change", UpdateVar)
    Setting["Advance_EBto64SQuality"].ToolTip := "设置 JPEG 编码精度。数值越高，编码越精确，但是编码后的字符串越长"
    Setting.AddUpDown("vAdvance_EBto64SQuality_extra Range0-100", OCRC_Configs["Advance"]["Advance_EBto64SQuality"])

    Setting.AddGroupBox("x20 y140 w310 h110", "外部截图软件支持")
    Setting.AddCheckBox("x0 y170 w90 vAdvance_ThirdPartyScreenshotOnOff Right Checked" OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotOnOff"], "启用").OnEvent("Click", UpdateVar)
    Setting["Advance_ThirdPartyScreenshotOnOff"].ToolTip := "设置是否启用外部截图软件支持。即使填写了下一个选项，也需要启用此选项才能生效"
    Setting.AddText("x-15 y+15 w90 h25 Right", "路径")
    Setting.AddEdit("x+15 w230 h25 vAdvance_ThirdPartyScreenshotPath", OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotPath"]).OnEvent("Change", UpdateVar)
    Setting["Advance_ThirdPartyScreenshotPath"].ToolTip := "设置外部截图软件的路径。允许额外添加参数，例如：Snipaste.exe snip -o clipboard"

    Setting.AddGroupBox("x20 y260 w310 h150", "翻译设置")
    Setting.AddText("x15 y290 w145 h25 Right", "谷歌翻译代理")
    Setting.AddEdit("x+15 w145 h25 vAdvance_GoogleTranslateProxy", OCRC_Configs["Advance"]["Advance_GoogleTranslateProxy"]).OnEvent("Change", UpdateVar)
    Setting["Advance_GoogleTranslateProxy"].ToolTip := "设置谷歌翻译的代理。如不使用谷歌翻译则无需设置"
    Setting.AddText("x15 y+15 w145 h25 Right", "腾讯翻译 SecretID")
    Setting.AddEdit("x+15 w145 h25 vAdvance_TencentTranslateSecretID", OCRC_Configs["Advance"]["Advance_TencentTranslateSecretID"]).OnEvent("Change", UpdateVar)
    Setting["Advance_TencentTranslateSecretID"].ToolTip := "设置腾讯翻译的 SecretID。如不使用腾讯翻译则无需设置`n注意：腾讯翻译暂不可用"
    Setting.AddText("x15 y+15 w145 h25 Right", "腾讯翻译 SecretKey")
    Setting.AddEdit("x+15 w145 h25 vAdvance_TencentTranslateSecretKey", OCRC_Configs["Advance"]["Advance_TencentTranslateSecretKey"]).OnEvent("Change", UpdateVar)
    Setting["Advance_TencentTranslateSecretKey"].ToolTip := "设置腾讯翻译的 SecretKey。如不使用腾讯翻译则无需设置`n注意：腾讯翻译暂不可用"

    Setting["Tabs"].UseTab("BaiduOCR")
    Setting.AddGroupBox("x20 y50 w310 h260", "基础设置")
    Setting.AddText("x15 y80 w90 h25 Right", "热键")
    Setting.AddHotkey("x+15 w200 h25 vBaiduOCR_Hotkey", OCRC_Configs["BaiduOCR"]["BaiduOCR_Hotkey"]).OnEvent("Change", UpdateHotkey)
    Setting["BaiduOCR_Hotkey"].ToolTip := "设置百度 OCR 的热键。如果不使用百度 OCR 则需要在基础设置关闭"
    Setting.AddText("x15 y+15 w90 h25 Right", "API Key")
    Setting.AddEdit("x+15 w200 h25 vBaiduOCR_APIKey", OCRC_Configs["BaiduOCR"]["BaiduOCR_APIKey"]).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_APIKey"].ToolTip := "设置百度 OCR 的 API Key。如果不使用百度 OCR 则无需设置"
    Setting.AddText("x15 y+15 w90 h25 Right", "Secret Key")
    Setting.AddEdit("x+15 w200 h25 vBaiduOCR_SecretKey", OCRC_Configs["BaiduOCR"]["BaiduOCR_SecretKey"]).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_SecretKey"].ToolTip := "设置百度 OCR 的 Secret Key。如果不使用百度 OCR 则无需设置"
    Setting.AddText("x15 y+15 w90 h25 Right", "识别语言")
    Setting.AddDropDownList("x+15 w200 vBaiduOCR_LanguageType AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"], Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"])).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_LanguageType"].ToolTip := "设置百度 OCR 的识别语言。默认有「中英文混合」和「英文」，可在配置文件中自行设置"
    Setting.AddText("x15 y+15 w90 h25 Right", "识别类型")
    Setting.AddDropDownList("x+15 w200 vBaiduOCR_RecognitionType AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_RecognitionType"], Map2Array(BaiduOCR_RecognitionTypes, 0)).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_RecognitionType"].ToolTip := "设置百度 OCR 的识别类型`n通用文字（标准）识别：适用于日常场景的简单文字识别。`n通用文字（高精度）识别：适用于复杂场景下的文字识别。`n手写文字识别：适用于手写场景下的文字识别。`n网络图片文字识别：适用于网络图片场景下的文字识别"
    Setting.AddCheckBox("x30 y+15 w90 vBaiduOCR_ProbabilityType Right Check3 Checked" OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"], "置信度").OnEvent("Click", UpdateVar)
    Setting["BaiduOCR_ProbabilityType"].ToolTip := "设置置信度类型：精准、模糊、关闭`n精准：根据每行置信度及其字符数目的权重，综合计算得到。`n模糊：每行置信度直接平均得到。`n关闭：不显示置信度。"

    Setting.AddGroupBox("x20 y320 w310 h310", "默认选项")
    Setting.AddText("x15 y350 w120 h25 Right", "默认排版")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_FormatStyle AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_FormatStyle"], ["智能段落", "合并多行", "拆分多行"]).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_FormatStyle"].ToolTip := "设置默认段落格式`n智能段落：根据返回结果智能合并段落。`n合并多行：将多行合并为一行。`n拆分多行：不对返回结果进行段落合并处理。"
    Setting.AddText("x15 y+15 w120 h25 Right", "默认标点")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_PunctuationStyle AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_PunctuationStyle"], ["智能标点", "原始结果", "中文标点", "英文标点"]).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_PunctuationStyle"].ToolTip := "设置默认标点格式`n智能标点（实验性，可能有较大问题！）：根据上下文智能转换标点。`n原始结果：恢复上一文本处理操作前的状态（不支持连续恢复）。`n中文标点：将所有标点转换为中文标点。`n英文标点：将所有标点转换为英文标点。"
    Setting.AddText("x15 y+15 w120 h25 Right", "默认空格")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_SpaceStyle AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_SpaceStyle"], ["智能空格", "原始结果", "去除空格"]).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_SpaceStyle"].ToolTip := "设置默认空格格式`n智能空格（实验性，可能有较大问题！在对网址等文本处理不建议使用）：根据上下文智能转换空格。`n原始结果：恢复上一文本处理操作前的状态（不支持连续恢复）。`n去除空格：去除所有空格。"
    Setting.AddText("x15 y+15 w120 h25 Right", "默认翻译引擎")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_TranslateEngine AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateEngine"], Map2Array(BaiduOCR_TranslateEngines)).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_TranslateEngine"].ToolTip := "设置默认翻译引擎（目前仅「谷歌翻译」引擎可用，且可能需要配置代理）"
    Setting.AddText("x15 y+15 w120 h25 Right", "默认翻译类型")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_TranslateType AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateType"], Map2Array(BaiduOCR_TranslateTypes)).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_TranslateType"].ToolTip := "设置默认翻译格式`n自动检测：根据文本内容自动检测输入文本语言并翻译为中文。`n英->中：英文翻译为中文。`n中->英：中文翻译为英文。`n繁->简：繁体中文翻译为简体中文。`n日->中：日文翻译为中文。"
    Setting.AddText("x15 y+15 w120 h25 Right", "默认搜索引擎")
    Setting.AddDropDownList("x+15 w170 vBaiduOCR_SearchEngine AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_SearchEngine"], Map2Array(OCRC_Configs["BaiduOCR_SearchEngines"])).OnEvent("Change", UpdateVar)
    Setting["BaiduOCR_SearchEngine"].ToolTip := "设置默认搜索引擎。以下为默认选项（可在配置文件中移除或添加）：`n百度：百度搜索。`n谷歌：谷歌搜索。`n必应：必应搜索。`n百度百科：百度百科搜索。`n维基百科：维基百科搜索。"
    Setting.AddCheckBox("x18 y+15 w180 vBaiduOCR_CloseAndSearch Right Checked" OCRC_Configs["BaiduOCR"]["BaiduOCR_CloseAndSearch"], "搜索时关闭结果窗口").OnEvent("Click", UpdateVar)
    Setting["BaiduOCR_CloseAndSearch"].ToolTip := "设置是否在点击搜索后关闭结果窗口"

    Setting["Tabs"].UseTab("MathpixOCR")
    Setting.AddGroupBox("x20 y50 w310 h150", "基础设置")
    Setting.AddText("x15 y80 w90 h25 Right", "热键")
    Setting.AddHotkey("x+15 w200 h25 vMathpixOCR_Hotkey", OCRC_Configs["MathpixOCR"]["MathpixOCR_Hotkey"]).OnEvent("Change", UpdateHotkey)
    Setting["MathpixOCR_Hotkey"].ToolTip := "设置 Mathpix OCR 的热键。如果不使用 Mathpix OCR 则需要在基础设置关闭"
    Setting.AddText("x15 y+15 w90 h25 Right", "App ID")
    Setting.AddEdit("x+15 w200 h25 vMathpixOCR_AppID", OCRC_Configs["MathpixOCR"]["MathpixOCR_AppID"]).OnEvent("Change", UpdateVar)
    Setting["MathpixOCR_AppID"].ToolTip := "设置 Mathpix OCR 的 App ID。如果不使用 Mathpix OCR 则无需设置"
    Setting.AddText("x15 y+15 w90 h25 Right", "App Key")
    Setting.AddEdit("x+15 w200 h25 vMathpixOCR_AppKey", OCRC_Configs["MathpixOCR"]["MathpixOCR_AppKey"]).OnEvent("Change", UpdateVar)
    Setting["MathpixOCR_AppKey"].ToolTip := "设置 Mathpix OCR 的 App Key。如果不使用 Mathpix OCR 则无需设置"

    Setting.AddGroupBox("x20 y210 w310 h75", "默认选项")
    Setting.AddText("x15 w90 y240 h25 Right", "默认选择")
    Setting.AddDropDownList("x+15 w200 vMathpixOCR_DefaultSelect AltSubmit Choose" OCRC_Configs["MathpixOCR"]["MathpixOCR_DefaultSelect"], ["LaTeX", "行内公式", "行间公式"]).OnEvent("Change", UpdateVar)
    Setting["MathpixOCR_DefaultSelect"].ToolTip := "设置默认选择的公式类型`nLaTeX：纯 LaTeX 代码（无数学分隔符）。`n行内公式：行内公式。`n行间公式：行间公式。`n文本公式：混排文本和公式时默认选择，智能区分文本和公式。"

    Setting["Tabs"].UseTab("LaTeX")
    Setting.AddGroupBox("x20 y50 w310 h110", "基础设置")
    Setting.AddText("x15 y80 w90 h25 Right", "行内公式")
    Setting.AddDropDownList("x+15 w200 vLaTeX_InlineStyle AltSubmit Choose" OCRC_Configs["LaTeX"]["LaTeX_InlineStyle"], ["$...$", "\(...\)"]).OnEvent("Change", UpdateVar)
    Setting["LaTeX_InlineStyle"].ToolTip := "设置默认行内公式格式"
    Setting.AddText("x15 y+15 w90 h25 Right", "行间公式")
    Setting.AddDropDownList("x+15 w200 vLaTeX_DisplayStyle AltSubmit Choose" OCRC_Configs["LaTeX"]["LaTeX_DisplayStyle"], ["$$...$$", "\[...\]"]).OnEvent("Change", UpdateVar)
    Setting["LaTeX_DisplayStyle"].ToolTip := "设置默认行间公式格式"

    if OCRC_Configs["Basic"]["Basic_OCRCToolTips"] {
        OnMessage(0x200, CtrlToolTip)
        OnMessage(0x2A3, (*) => ToolTip())
    }
    Setting.Show()

    CtrlToolTip(wParam, lParam, msg, Hwnd) {
        static PrevHwnd := 0
        if Hwnd != PrevHwnd {
            Text := "", ToolTip()
            if (CurrControl := GuiCtrlFromHwnd(Hwnd)) && CurrControl.HasProp("ToolTip")
                SetTimer(() => ToolTip(CurrControl.ToolTip), -500)
            PrevHwnd := Hwnd
        }
    }
}

CreateConfig() {
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_BaiduOCROnOff")
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_MathpixOCROnOff")
    IniWrite(10,  OCRC_ConfigFilePath, "Basic", "Basic_SnipTime")
    IniWrite(500, OCRC_ConfigFilePath, "Basic", "Basic_WaitSnipTime")
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_SnipWarning")
    IniWrite(1,   OCRC_ConfigFilePath, "Basic", "Basic_OCRCToolTips")

    IniWrite(75, OCRC_ConfigFilePath, "Advance", "Advance_EBto64SQuality")
    IniWrite(0,  OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotOnOff")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotPath")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_GoogleTranslateProxy")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_TencentTranslateSecretID")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_TencentTranslateSecretKey")

    IniWrite("F7",  OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_Hotkey")
    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_APIKey")
    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_SecretKey")
    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_Token")
    IniWrite(A_Now, OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_TokenExpiration")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_RecognitionType")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_ProbabilityType")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_FormatStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_PunctuationStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_SpaceStyle")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_TranslateEngine")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_TranslateType")
    IniWrite(2,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_SearchEngine")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_CloseAndSearch")

    IniWrite("auto_detect", OCRC_ConfigFilePath, "BaiduOCR_LanguageTypes", "自动检测")
    IniWrite("CHN_ENG",     OCRC_ConfigFilePath, "BaiduOCR_LanguageTypes", "中英文混合")
    IniWrite("ENG",         OCRC_ConfigFilePath, "BaiduOCR_LanguageTypes", "英文")

    IniWrite("https://www.baidu.com/s?wd=@W",      OCRC_ConfigFilePath, "BaiduOCR_SearchEngines", "百度")
    IniWrite("https://www.google.com/search?q=@W", OCRC_ConfigFilePath, "BaiduOCR_SearchEngines", "谷歌")
    IniWrite("https://cn.bing.com/search?q=@W",    OCRC_ConfigFilePath, "BaiduOCR_SearchEngines", "必应")
    IniWrite("https://baike.baidu.com/item/@W",    OCRC_ConfigFilePath, "BaiduOCR_SearchEngines", "百度百科")
    IniWrite("https://zh.wikipedia.org/wiki/@W",   OCRC_ConfigFilePath, "BaiduOCR_SearchEngines", "维基百科")

    IniWrite("F4", OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_Hotkey")
    IniWrite("",   OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_AppID")
    IniWrite("",   OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_AppKey")
    IniWrite(1,    OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_DefaultSelect")

    IniWrite(1,    OCRC_ConfigFilePath, "LaTeX", "LaTeX_InlineStyle")
    IniWrite(1,    OCRC_ConfigFilePath, "LaTeX", "LaTeX_DisplayStyle")
}

UpdateGlobalVar() {
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

UpdateVar(CtrlObj, *) => IniWrite(OCRC_Configs[CtrlObj.Name] := CtrlObj.Value, OCRC_ConfigFilePath, CtrlObj.Gui["Tabs"].Text, CtrlObj.Name)

UpdateHotkey(CtrlObj, *) {
    UpdateVar(CtrlObj)
    if !CtrlObj.Value
        return
    global BaiduOCR_HotkeyTemp, MathpixOCR_HotkeyTemp
    if CtrlObj.Name == "BaiduOCR_Hotkey" {
        Hotkey(BaiduOCR_HotkeyTemp, OCRC_BaiduOCR, "Off")
        Hotkey(CtrlObj.Value, OCRC_BaiduOCR, "On")
        BaiduOCR_HotkeyTemp := CtrlObj.Value
    }
    else {
        Hotkey(MathpixOCR_HotkeyTemp, OCRC_MathpixOCR, "Off")
        Hotkey(CtrlObj.Value, OCRC_MathpixOCR, "On")
        MathpixOCR_HotkeyTemp := CtrlObj.Value
    }
}

SwitchHotkey(CtrlObj, *) => (UpdateVar(CtrlObj), Hotkey(OCRC_Configs["BaiduOCR"]["BaiduOCR_Hotkey"], OCRC_BaiduOCR, CtrlObj.Value ? "On" : "Off"))
