SettingGUI(*) {
    if !FileExist(OCRC_ConfigFilePath)
        CreateConfig()
    GlobalConstants()

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
    Setting.AddTab3("vTabs Choose1", ["Basic", "Advance", "TextOCR", "FormulaOCR"])

    Setting["Tabs"].UseTab("Basic")
    Setting.AddGroupBox("x20 y50 w325 h270", "OCR")
    Setting.AddCheckBox("x30 y80 w120 vBasic_TextOCROnOff Right Checked" OCRC_Configs["Basic"]["Basic_TextOCROnOff"], "文本 OCR").OnEvent("Click", (CtrlObj, *) => SwitchHotkey(CtrlObj, "Basic_TextOCRHotkey", Basic_TextOCREngines[CtrlObj.Text]))
    Setting["Basic_TextOCROnOff"].ToolTip := "设置是否启用「文本 OCR」"
    Setting.AddCheckBox("x30 y+15 w120 vBasic_FormulaOCROnOff Right Checked" OCRC_Configs["Basic"]["Basic_FormulaOCROnOff"], "公式 OCR").OnEvent("Click", (CtrlObj, *) => SwitchHotkey(CtrlObj, "Basic_FormulaOCRHotkey", Basic_FormulaOCREngines[CtrlObj.Text]))
    Setting["Basic_FormulaOCROnOff"].ToolTip := "设置是否启用「公式 OCR」"
    Setting.AddText("x15 y+15 w120 h25 Right", "文本 OCR 引擎")
    Setting.AddDropDownList("x+15 w185 vBasic_TextOCREngine AltSubmit Choose" OCRC_Configs["Basic"]["Basic_TextOCREngine"], Map2Array(Basic_TextOCREngines)).OnEvent("Change", (CtrlObj, *) => (UpdateVar(CtrlObj), UpdateHotkey("Text", OCRC_Configs["Basic"]["Basic_TextOCRHotkey"], Basic_TextOCREngines[CtrlObj.Text])))
    Setting["Basic_TextOCREngine"].ToolTip := "设置文本 OCR 的引擎。目前仅支持「百度 OCR」"
    Setting.AddText("x15 y+15 w120 h25 Right", "公式 OCR 引擎")
    Setting.AddDropDownList("x+15 w185 vBasic_FormulaOCREngine AltSubmit Choose" OCRC_Configs["Basic"]["Basic_FormulaOCREngine"], Map2Array(Basic_FormulaOCREngines)).OnEvent("Change", (CtrlObj, *) => (UpdateVar(CtrlObj), UpdateHotkey("Formula", OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"], Basic_FormulaOCREngines[CtrlObj.Text])))
    Setting["Basic_FormulaOCREngine"].ToolTip := "设置公式 OCR 的引擎。目前支持「Bing OCR」和「Mathpix OCR」"
    Setting.AddText("x0 y+15 w135 h25 Right", "文本 OCR 热键")
    Setting.AddHotkey("x+15 w185 h25 vBasic_TextOCRHotkey", OCRC_Configs["Basic"]["Basic_TextOCRHotkey"]).OnEvent("Change", (CtrlObj, *) => (UpdateVar(CtrlObj), UpdateHotkey("Text", CtrlObj.Value, Basic_TextOCREngines[CtrlObj.Text])))
    Setting["Basic_TextOCRHotkey"].ToolTip := "设置文本 OCR 的热键。如果不使用文本 OCR 则需要在基础设置关闭"
    Setting.AddText("x0 y+15 w135 h25 Right", "公式 OCR 热键")
    Setting.AddHotkey("x+15 w185 h25 vBasic_FormulaOCRHotkey", OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"]).OnEvent("Change", (CtrlObj, *) => (UpdateVar(CtrlObj), UpdateHotkey("Formula", CtrlObj.Value, Basic_FormulaOCREngines[CtrlObj.Text])))
    Setting["Basic_FormulaOCRHotkey"].ToolTip := "设置公式 OCR 的热键。如果不使用公式 OCR 则需要在基础设置关闭"

    Setting.AddGroupBox("x20 y330 w325 h150", "截图")
    Setting.AddText("x15 y360 w80 h25 Right", "截图时间")
    Setting.AddEdit("x+15 w95 vBasic_SnipTime Number", OCRC_Configs["Basic"]["Basic_SnipTime"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vBasic_SnipTime_extra Range5-60", OCRC_Configs["Basic"]["Basic_SnipTime"])
    Setting["Basic_SnipTime"].ToolTip := "设置截图时间。超时将自动结束 OCR"
    Setting.AddText("x215 y360 w20 h25 Left", "秒")
    Setting.AddText("x15 y+15 w80 h25 Right", "缓冲时间")
    Setting.AddEdit("x+15 w95 vBasic_WaitSnipTime Number", OCRC_Configs["Basic"]["Basic_WaitSnipTime"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vBasic_WaitSnipTime_extra Range100-5000 0x80", OCRC_Configs["Basic"]["Basic_WaitSnipTime"])
    Setting["Basic_WaitSnipTime"].ToolTip := "设置等待截图窗口出现的缓冲时间。设置时间过短可能导致经常性的截图失败。超时将自动结束 OCR"
    Setting.AddText("x215 y400 w40 h25 Left", "毫秒")
    Setting.AddCheckBox("x21 y+15 w200 vBasic_SnipWarning Right Checked" OCRC_Configs["Basic"]["Basic_SnipWarning"], "未检测到截图时抛出警告").OnEvent("Click", UpdateVar)
    Setting["Basic_SnipWarning"].ToolTip := "设置是否在未检测到截图时抛出警告"

    Setting.AddGroupBox("x20 y490 w325 h75", "OCRC")
    Setting.AddCheckBox("x20 y520 w155 vBasic_OCRCToolTips Right Checked" OCRC_Configs["Basic"]["Basic_OCRCToolTips"], "设置界面工具提示").OnEvent("Click", (CtrlObj, *) => (
        UpdateVar(CtrlObj),
        OnMessage(0x200, CtrlToolTip, CtrlObj.Value)
        OnMessage(0x2A3, (*) => ToolTip(), CtrlObj.Value)
        ToolTip()
    ))
    Setting["Basic_OCRCToolTips"].ToolTip := "设置是否在 OCRC 设置界面显示工具提示"

    Setting["Tabs"].UseTab("Advance")
    Setting.AddGroupBox("x20 y50 w325 h80", "高级设置")
    Setting.AddText("x15 y80 w90 h25 Right", "编码精度")
    Setting.AddEdit("x+15 w75 vAdvance_EBto64SQuality Number", OCRC_Configs["Advance"]["Advance_EBto64SQuality"]).OnEvent("Change", UpdateVar)
    Setting.AddUpDown("vAdvance_EBto64SQuality_extra Range0-100", OCRC_Configs["Advance"]["Advance_EBto64SQuality"])
    Setting["Advance_EBto64SQuality"].ToolTip := "设置 JPEG 编码精度。数值越高，编码越精确，但是编码后的字符串越长"

    Setting.AddGroupBox("x20 y140 w325 h110", "外部截图软件支持")
    Setting.AddCheckBox("x0 y170 w90 vAdvance_ThirdPartyScreenshotOnOff Right Checked" OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotOnOff"], "启用").OnEvent("Click", UpdateVar)
    Setting["Advance_ThirdPartyScreenshotOnOff"].ToolTip := "设置是否启用外部截图软件支持。即使填写了下一个选项，也需要启用此选项才能生效"
    Setting.AddText("x-15 y+15 w90 h25 Right", "路径")
    Setting.AddEdit("x+15 w245 h25 vAdvance_ThirdPartyScreenshotPath", OCRC_Configs["Advance"]["Advance_ThirdPartyScreenshotPath"]).OnEvent("Change", UpdateVar)
    Setting["Advance_ThirdPartyScreenshotPath"].ToolTip := "设置外部截图软件的路径。允许额外添加参数，例如：Snipaste.exe snip -o clipboard"

    Setting.AddGroupBox("x20 y260 w325 h75", "翻译设置")
    Setting.AddText("x15 y290 w145 h25 Right", "谷歌翻译代理")
    Setting.AddEdit("x+15 w160 h25 vAdvance_GoogleTranslateProxy", OCRC_Configs["Advance"]["Advance_GoogleTranslateProxy"]).OnEvent("Change", UpdateVar)
    Setting["Advance_GoogleTranslateProxy"].ToolTip := "设置谷歌翻译的代理。如不使用谷歌翻译则无需设置"

    Setting["Tabs"].UseTab("TextOCR")
    Setting.AddGroupBox("x20 y50 w325 h310", "默认选项")
    Setting.AddText("x15 y80 w135 h25 Right", "默认排版")
    Setting.AddDropDownList("x+15 w170 vTextOCR_FormatStyle AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_FormatStyle"], ["智能段落", "合并多行", "拆分多行"]).OnEvent("Change", UpdateVar)
    Setting["TextOCR_FormatStyle"].ToolTip := "设置默认段落格式`n智能段落：根据返回结果智能合并段落。`n合并多行：将多行合并为一行。`n拆分多行：不对返回结果进行段落合并处理。"
    Setting.AddText("x15 y+15 w135 h25 Right", "默认标点")
    Setting.AddDropDownList("x+15 w170 vTextOCR_PunctuationStyle AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_PunctuationStyle"], ["智能标点", "原始结果", "中文标点", "英文标点"]).OnEvent("Change", UpdateVar)
    Setting["TextOCR_PunctuationStyle"].ToolTip := "设置默认标点格式`n智能标点（实验性，可能有较大问题！）：根据上下文智能转换标点。`n原始结果：恢复上一文本处理操作前的状态（不支持连续恢复）。`n中文标点：将所有标点转换为中文标点。`n英文标点：将所有标点转换为英文标点。"
    Setting.AddText("x15 y+15 w135 h25 Right", "默认空格")
    Setting.AddDropDownList("x+15 w170 vTextOCR_SpaceStyle AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_SpaceStyle"], ["智能空格", "原始结果", "去除空格"]).OnEvent("Change", UpdateVar)
    Setting["TextOCR_SpaceStyle"].ToolTip := "设置默认空格格式`n智能空格（实验性，可能有较大问题！在对网址等文本处理不建议使用）：根据上下文智能转换空格。`n原始结果：恢复上一文本处理操作前的状态（不支持连续恢复）。`n去除空格：去除所有空格。"
    Setting.AddText("x15 y+15 w135 h25 Right", "默认翻译原始语言")
    Setting.AddDropDownList("x+15 w170 vTextOCR_TranslateFrom AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_TranslateFrom"], TLs := Map2Array(TL := OCRC_Configs["TextOCR_TranslateLanguages"])).OnEvent("Change", UpdateVar)
    Setting["TextOCR_TranslateFrom"].ToolTip := "设置翻译的默认原始语言，可在配置文件中自行添加，默认有「自动检测」「中文」和英文，默认选择「自动检测」"
    Setting.AddText("x15 y+15 w135 h25 Right", "默认翻译目标语言")
    Setting.AddDropDownList("x+15 w170 vTextOCR_TranslateTo AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_TranslateTo"], TL.Has("自动检测") ? (TLs.RemoveAt(IndexOf("自动检测", TLs)), TLs) : TLs).OnEvent("Change", UpdateVar)
    Setting["TextOCR_TranslateTo"].ToolTip := "设置翻译的默认目标语言，可在配置文件中自行添加，默认有「中文」和英文，默认选择「中文」"
    Setting.AddText("x15 y+15 w135 h25 Right", "默认搜索引擎")
    Setting.AddDropDownList("x+15 w170 vTextOCR_SearchEngine AltSubmit Choose" OCRC_Configs["TextOCR"]["TextOCR_SearchEngine"], Map2Array(OCRC_Configs["TextOCR_SearchEngines"])).OnEvent("Change", UpdateVar)
    Setting["TextOCR_SearchEngine"].ToolTip := "设置默认搜索引擎。以下为默认选项（可在配置文件中移除或添加）：`n百度：百度搜索。`n谷歌：谷歌搜索。`n必应：必应搜索。`n百度百科：百度百科搜索。`n维基百科：维基百科搜索。"
    Setting.AddCheckBox("x18 y+15 w180 vTextOCR_CloseAndSearch Right Checked" OCRC_Configs["TextOCR"]["TextOCR_CloseAndSearch"], "搜索时关闭结果窗口").OnEvent("Click", UpdateVar)
    Setting["TextOCR_CloseAndSearch"].ToolTip := "设置是否在点击搜索后关闭结果窗口"

    Setting["Tabs"].UseTab("FormulaOCR")
    Setting.AddGroupBox("x20 y50 w325 h110", "基础设置")
    Setting.AddText("x15 y80 w105 h25 Right", "行内公式")
    Setting.AddDropDownList("x+15 w200 vFormulaOCR_InlineStyle AltSubmit Choose" OCRC_Configs["FormulaOCR"]["FormulaOCR_InlineStyle"], ["$...$", "\(...\)"]).OnEvent("Change", UpdateVar)
    Setting["FormulaOCR_InlineStyle"].ToolTip := "设置默认行内公式格式"
    Setting.AddText("x15 y+15 w105 h25 Right", "行间公式")
    Setting.AddDropDownList("x+15 w200 vFormulaOCR_DisplayStyle AltSubmit Choose" OCRC_Configs["FormulaOCR"]["FormulaOCR_DisplayStyle"], ["$$...$$", "\[...\]"]).OnEvent("Change", UpdateVar)
    Setting["FormulaOCR_DisplayStyle"].ToolTip := "设置默认行间公式格式"

    Setting.AddGroupBox("x20 y180 w325 h75", "默认选项")
    Setting.AddText("x15 w90 y210 h25 Right", "默认选择")
    Setting.AddDropDownList("x+15 w215 vFormulaOCR_DefaultSelect AltSubmit Choose" OCRC_Configs["FormulaOCR"]["FormulaOCR_DefaultSelect"], ["LaTeX", "行内公式", "行间公式"]).OnEvent("Change", UpdateVar)
    Setting["FormulaOCR_DefaultSelect"].ToolTip := "设置默认选择的公式类型`nLaTeX：纯 LaTeX 代码（无数学分隔符）。`n行内公式：行内公式。`n行间公式：行间公式。`n文本公式：混排文本和公式时默认选择，智能区分文本和公式。"

    if OCRC_Configs["Basic"]["Basic_OCRCToolTips"] {
        OnMessage(0x200, CtrlToolTip)
        OnMessage(0x2A3, (*) => ToolTip())
    }
    Setting.Show()
}

OCREnginesGUI(*) {
    if !FileExist(OCRC_ConfigFilePath)
        CreateConfig()
    GlobalConstants()

    OCREngines := Gui(, "OCRC OCREngines")
    OCREngines.OnEvent("Close", (*) => (
        OnMessage(0x200, CtrlToolTip, 0)
        OnMessage(0x2A3, (*) => ToolTip(), 0)
        ToolTip()
    ))
    OCREngines.Title := "OCR 引擎设置"
    OCREngines.BackColor := "EBEDF4"
    OCREngines.MarginX := 10
    OCREngines.MarginY := 10
    OCREngines.Opt("AlwaysOnTop")
    OCREngines.SetFont("s12", "Microsoft YaHei")
    OCREngines.AddTab3("vTabs Choose1", ["BaiduOCR", "MathpixOCR"])

    OCREngines["Tabs"].UseTab("BaiduOCR")
    OCREngines.AddGroupBox("x20 y50 w325 h230", "基础设置")
    OCREngines.AddText("x15 y80 w90 h25 Right", "API Key")
    OCREngines.AddEdit("x+15 w215 h25 vBaiduOCR_APIKey", OCRC_Configs["BaiduOCR"]["BaiduOCR_APIKey"]).OnEvent("Change", UpdateVar)
    OCREngines["BaiduOCR_APIKey"].ToolTip := "设置百度 OCR 的 API Key。如果不使用百度 OCR 则无需设置"
    OCREngines.AddText("x15 y+15 w90 h25 Right", "Secret Key")
    OCREngines.AddEdit("x+15 w215 h25 vBaiduOCR_SecretKey", OCRC_Configs["BaiduOCR"]["BaiduOCR_SecretKey"]).OnEvent("Change", UpdateVar)
    OCREngines["BaiduOCR_SecretKey"].ToolTip := "设置百度 OCR 的 Secret Key。如果不使用百度 OCR 则无需设置"
    OCREngines.AddText("x15 y+15 w90 h25 Right", "识别语言")
    OCREngines.AddDropDownList("x+15 w215 vBaiduOCR_LanguageType AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"], Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"])).OnEvent("Change", UpdateVar)
    OCREngines["BaiduOCR_LanguageType"].ToolTip := "设置百度 OCR 的识别语言。默认有「中英文混合」和「英文」，可在配置文件中自行添加"
    OCREngines.AddText("x15 y+15 w90 h25 Right", "识别类型")
    OCREngines.AddDropDownList("x+15 w215 vBaiduOCR_RecognitionType AltSubmit Choose" OCRC_Configs["BaiduOCR"]["BaiduOCR_RecognitionType"], Map2Array(BaiduOCR_RecognitionTypes, 0)).OnEvent("Change", UpdateVar)
    OCREngines["BaiduOCR_RecognitionType"].ToolTip := "设置百度 OCR 的识别类型`n通用文字（标准）识别：适用于日常场景的简单文字识别。`n通用文字（高精度）识别：适用于复杂场景下的文字识别。`n手写文字识别：适用于手写场景下的文字识别。`n网络图片文字识别：适用于网络图片场景下的文字识别"
    OCREngines.AddCheckBox("x30 y+15 w90 vBaiduOCR_ProbabilityType Right Check3 Checked" OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"], "置信度").OnEvent("Click", UpdateVar)
    OCREngines["BaiduOCR_ProbabilityType"].ToolTip := "设置置信度类型：精准、模糊、关闭`n精准：根据每行置信度及其字符数目的权重，综合计算得到。`n模糊：每行置信度直接平均得到。`n关闭：不显示置信度。"

    OCREngines["Tabs"].UseTab("MathpixOCR")
    OCREngines.AddGroupBox("x20 y50 w325 h120", "基础设置")
    OCREngines.AddText("x15 y80 w90 h25 Right", "App ID")
    OCREngines.AddEdit("x+15 w215 h25 vMathpixOCR_AppID", OCRC_Configs["MathpixOCR"]["MathpixOCR_AppID"]).OnEvent("Change", UpdateVar)
    OCREngines["MathpixOCR_AppID"].ToolTip := "设置 Mathpix OCR 的 App ID。如果不使用 Mathpix OCR 则无需设置"
    OCREngines.AddText("x15 y+15 w90 h25 Right", "App Key")
    OCREngines.AddEdit("x+15 w215 h25 vMathpixOCR_AppKey", OCRC_Configs["MathpixOCR"]["MathpixOCR_AppKey"]).OnEvent("Change", UpdateVar)
    OCREngines["MathpixOCR_AppKey"].ToolTip := "设置 Mathpix OCR 的 App Key。如果不使用 Mathpix OCR 则无需设置"

    if OCRC_Configs["Basic"]["Basic_OCRCToolTips"] {
        OnMessage(0x200, CtrlToolTip)
        OnMessage(0x2A3, (*) => ToolTip())
    }
    OCREngines.Show()
}

CreateConfig() {
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_TextOCROnOff")
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_FormulaOCROnOff")
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_TextOCREngine")
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_FormulaOCREngine")
    IniWrite("F7", OCRC_ConfigFilePath, "Basic", "Basic_TextOCRHotkey")
    IniWrite("F4", OCRC_ConfigFilePath, "Basic", "Basic_FormulaOCRHotkey")
    IniWrite(10,   OCRC_ConfigFilePath, "Basic", "Basic_SnipTime")
    IniWrite(500,  OCRC_ConfigFilePath, "Basic", "Basic_WaitSnipTime")
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_SnipWarning")
    IniWrite(1,    OCRC_ConfigFilePath, "Basic", "Basic_OCRCToolTips")

    IniWrite(75, OCRC_ConfigFilePath, "Advance", "Advance_EBto64SQuality")
    IniWrite(0,  OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotOnOff")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_ThirdPartyScreenshotPath")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_GoogleTranslateProxy")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_TencentTranslateSecretID")
    IniWrite("", OCRC_ConfigFilePath, "Advance", "Advance_TencentTranslateSecretKey")

    IniWrite(1, OCRC_ConfigFilePath, "TextOCR", "TextOCR_FormatStyle")
    IniWrite(1, OCRC_ConfigFilePath, "TextOCR", "TextOCR_PunctuationStyle")
    IniWrite(1, OCRC_ConfigFilePath, "TextOCR", "TextOCR_SpaceStyle")
    IniWrite(2, OCRC_ConfigFilePath, "TextOCR", "TextOCR_TranslateFrom")
    IniWrite(1, OCRC_ConfigFilePath, "TextOCR", "TextOCR_TranslateTo")
    IniWrite(2, OCRC_ConfigFilePath, "TextOCR", "TextOCR_SearchEngine")
    IniWrite(1, OCRC_ConfigFilePath, "TextOCR", "TextOCR_CloseAndSearch")

    IniWrite(1, OCRC_ConfigFilePath, "FormulaOCR", "FormulaOCR_InlineStyle")
    IniWrite(1, OCRC_ConfigFilePath, "FormulaOCR", "FormulaOCR_DisplayStyle")
    IniWrite(1, OCRC_ConfigFilePath, "FormulaOCR", "FormulaOCR_DefaultSelect")

    IniWrite("auto",  OCRC_ConfigFilePath, "TextOCR_TranslateLanguages", "自动检测")
    IniWrite("zh-cn", OCRC_ConfigFilePath, "TextOCR_TranslateLanguages", "简体中文")
    IniWrite("en",    OCRC_ConfigFilePath, "TextOCR_TranslateLanguages", "英文")

    IniWrite("https://www.baidu.com/s?wd=@W",      OCRC_ConfigFilePath, "TextOCR_SearchEngines", "百度")
    IniWrite("https://www.google.com/search?q=@W", OCRC_ConfigFilePath, "TextOCR_SearchEngines", "谷歌")
    IniWrite("https://cn.bing.com/search?q=@W",    OCRC_ConfigFilePath, "TextOCR_SearchEngines", "必应")
    IniWrite("https://baike.baidu.com/item/@W",    OCRC_ConfigFilePath, "TextOCR_SearchEngines", "百度百科")
    IniWrite("https://zh.wikipedia.org/wiki/@W",   OCRC_ConfigFilePath, "TextOCR_SearchEngines", "维基百科")

    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_APIKey")
    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_SecretKey")
    IniWrite("",    OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_Token")
    IniWrite(A_Now, OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_TokenExpiration")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_LanguageType")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_RecognitionType")
    IniWrite(1,     OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_ProbabilityType")

    IniWrite("CHN_ENG",     OCRC_ConfigFilePath, "BaiduOCR_LanguageTypes", "中英文混合")
    IniWrite("ENG",         OCRC_ConfigFilePath, "BaiduOCR_LanguageTypes", "英文")

    IniWrite("", OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_AppID")
    IniWrite("", OCRC_ConfigFilePath, "MathpixOCR", "MathpixOCR_AppKey")
}