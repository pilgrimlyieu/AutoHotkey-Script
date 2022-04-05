;@Ahk2Exe-SetMainIcon Icon\OCRC_icon.ico

; Optical Character Recognition Commander
; by PilgrimLyieu
; v1.1.1

#Include <Common>
#Include <JSON>
#Include <Baidu>
#Include <Mathpix>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini"

Global Baidu_RecogTypes := ["general_basic", "accurate_basic", "handwriting", "webimage"]
Global Baidu_RecogTypesP := {"general_basic": "通用文字（标准）识别", "accurate_basic": "通用文字（高精度）识别", "handwriting": "手写文字识别", "webimage": "网络图片文字识别"}
Global IsChinese := "[\x{4e00}-\x{9fa5}]"
Global IsChineseBefore := "(?:[\x{4e00}-\x{9fa5}]\s?)\K"
Global IsChineseAfter := "(?=\s?[\x{4e00}-\x{9fa5}])"
Global IsEnglishBefore := "([\w\d]\s?)\K"
Global IsEnglishAfter := "(?=\s?[\w\d])"
Global C2EPuncs := {"，": ",", "。": ".", "？": "?", "！": "!", "、": ",", "：": ":", "；": ";", "“": """", "”": """", "‘": "'", "’": "'", "「": """", "」": """", "『": "'", "』": "'", "（": "(", "）": ")", "【": "[", "】": "]", "《": "", "》": ""}
Global E2CPuncs := {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
Global Baidu_SEnginesP := ["https://www.baidu.com/s?wd=", "https://cn.bing.com/search?q=", "https://www.google.com/search?q=", "https://google.pem.app/search?q=", "https://baike.baidu.com/item/", "https://zh.wikipedia.iwiki.eu.org/wiki/"]

Global Mathpix_InlineStyles := [["$", "$"], ["\(", "\)"]]
Global Mathpix_DisplayStyles := [["$$", "$$"], ["\[", "\]"]]

Menu, Tray, NoStandard
Menu, Tray, Tip, OCRC
Menu, Tray, Click, 1
Menu, Tray, Add, 设置, Setting
Menu, Tray, Default, 设置
Menu, Tray, Add, 重启, ReloadSub
Menu, Tray, Add, 退出, ExitSub

if !A_IsAdmin {
    try {
        Run *RunAs "%A_ScriptFullPath%"
        ExitApp
    }
}

if !FileExist(ConfigFile)
    Gosub Create_Config

_Se := StrSplit(ReadIni(ConfigFile),"`n")
loop % _Se.length() {
    _Ke := StrSplit(ReadIni(ConfigFile, "", _Se[A_Index]), "`n")
    loop % _Ke.length() {
        _Va := StrSplit(_Ke[A_Index], "=")
        tVar := _Va[1]
        %tVar% := _Va[2]
    }
}

Baidu_HotkeyTemp := Baidu_Hotkey
Hotkey %Baidu_Hotkey%, BaiduOCR, On
Mathpix_HotkeyTemp := Mathpix_Hotkey
Hotkey %Mathpix_Hotkey%, MathpixOCR, On

return

BaiduOCR:
    success := GetScreenShot()
    if success
        return
    base64string := Img2Base()

    BaiduOCR := new Baidu({"paragraph": "true"
                         , "probability": Baidu_ProbType ? "true" : "false"}
                         , {"api_key": Baidu_API_Key
                         , "secret_key": Baidu_Secret_Key
                         , "token": Baidu_Token
                         , "token_expiration": Baidu_TokenExpiration
                         , "imgbase64": base64string
                         , "recogtype": Baidu_RecogTypes[Baidu_RecogType]
                         , "probtype": Baidu_ProbType
                         , "formatstyle": Baidu_FormatStyle
                         , "puncstyle": Baidu_PuncStyle
                         , "spacestyle": Baidu_SpaceStyle
                         , "trantype": Baidu_TranType
                         , "searchengine": Baidu_SearchEngine})
    BaiduOCR.Show()
return

MathpixOCR:
    success := GetScreenShot()
    if success
        return
    base64string := Img2Base(True)

    MathpixOCR := new Mathpix({"math_inline_delimiters": Mathpix_InlineStyles[Mathpix_InlineStyle]
                             , "math_display_delimiters": Mathpix_DisplayStyles[Mathpix_DisplayStyle]}
                             , {"app_id": Mathpix_App_ID
                             , "app_key": Mathpix_App_Key
                             , "imgbase64": base64string
                             , "default_select": Mathpix_DefaultSelect})
    MathpixOCR.Show()
return

Create_Config:
    IniWrite F7, %ConfigFile%, BaiduOCR, Baidu_Hotkey
    IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_API_Key
    IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_Secret_Key
    IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_Token
    IniWrite %A_Now%, %ConfigFile%, BaiduOCR, Baidu_TokenExpiration
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_RecogType
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_ProbType
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_FormatStyle
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_PuncStyle
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_SpaceStyle
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_TranType
    IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_SearchEngine

    IniWrite F4, %ConfigFile%, MathpixOCR, Mathpix_Hotkey
    IniWrite % "", %ConfigFile%, MathpixOCR, Mathpix_App_ID
    IniWrite % "", %ConfigFile%, MathpixOCR, Mathpix_App_Key
    IniWrite 1, %ConfigFile%, MathpixOCR, Mathpix_InlineStyle
    IniWrite 1, %ConfigFile%, MathpixOCR, Mathpix_DisplayStyle
    IniWrite 1, %ConfigFile%, MathpixOCR, Mathpix_DefaultSelect
return

Setting:
    if !FileExist(ConfigFile)
        Gosub Create_Config

    Gui st:New, , 设置
    Gui st:Default
    Gui st:+AlwaysOnTop +HwndstHwnd
    Gui st:Margin, 10, 10
    Gui st:Font, s12, Microsoft YaHei
    Gui st:Color, EBEDF4
    Gui Add, Tab3, Choose1, BaiduOCR|MathpixOCR

    Gui Tab, BaiduOCR
    Gui Add, GroupBox, x20 y40 w310 h230, 基础设置
    Gui Add, Text, x15 y70 w90 h25 +Right, 热键
    Gui Add, Hotkey, x+15 w200 h25 vBaidu_Hotkey gGBaidu_Hotkey, %Baidu_Hotkey%
    Gui Add, Text, x15 y+15 w90 h25 +Right, API Key
    Gui Add, Edit, x+15 w200 h25 vBaidu_API_Key gGETV, %Baidu_API_Key%
    Gui Add, Text, x15 y+15 w90 h25 +Right, Secret Key
    Gui Add, Edit, x+15 w200 h25 vBaidu_Secret_Key gGETV, %Baidu_Secret_Key%
    Gui Add, Text, x15 y+15 w90 h25 +Right, 识别类型
    Gui Add, DropDownList, x+15 w200 vBaidu_RecogType gGETV AltSubmit Choose%Baidu_RecogType%, 通用文字（标准）识别|通用文字（高精度）识别|手写文字识别|网络图片文字识别
    Gui Add, CheckBox, x35 y+15 w90 vBaidu_ProbType gGETV Check3 Checked%Baidu_ProbType% +Right, 置信度

    Gui Add, GroupBox, x20 y280 w310 h250, 默认选项
    Gui Add, Text, x15 y310 w90 h25 +Right, 默认排版
    Gui Add, DropDownList, x+15 w200 vBaidu_FormatStyle gGETV AltSubmit Choose%Baidu_FormatStyle%, 智能段落|合并多行|拆分多行
    Gui Add, Text, x15 y+15 w90 h25 +Right, 默认标点
    Gui Add, DropDownList, x+15 w200 vBaidu_PuncStyle gGETV AltSubmit Choose%Baidu_PuncStyle%, 智能标点|原始结果|中文标点|英文标点
    Gui Add, Text, x15 y+15 w90 h25 +Right, 默认空格
    Gui Add, DropDownList, x+15 w200 vBaidu_SpaceStyle gGETV AltSubmit Choose%Baidu_SpaceStyle%, 智能空格|原始结果|去除空格
    Gui Add, Text, x15 y+15 w90 h25 +Right, 默认翻译
    Gui Add, DropDownList, x+15 w200 vBaidu_TranType gGETV AltSubmit Choose%Baidu_TranType%, 自动检测|英⟹中|中⟹英|繁⟹简|日⟹中
    Gui Add, Text, x15 y+15 w90 h25 +Right, 默认搜索
    Gui Add, DropDownList, x+15 w200 vBaidu_SearchEngine gGETV AltSubmit Choose%Baidu_SearchEngine%, 百度搜索|必应搜索|谷歌搜索|谷歌镜像|百度百科|维基镜像|Everything

    Gui Tab, MathpixOCR
    Gui Add, GroupBox, x20 y40 w310 h150, 基础设置
    Gui Add, Text, x15 y70 w90 h25 +Right, 热键
    Gui Add, Hotkey, x+15 w200 h25 vMathpix_Hotkey gGMathpix_Hotkey, %Mathpix_Hotkey%
    Gui Add, Text, x15 y+15 w90 h25 +Right, App ID
    Gui Add, Edit, x+15 w200 h25 vMathpix_App_ID gGETV, %Mathpix_App_ID%
    Gui Add, Text, x15 y+15 w90 h25 +Right, App Key
    Gui Add, Edit, x+15 w200 h25 vMathpix_App_Key gGETV, %Mathpix_App_Key%

    Gui Add, GroupBox, x20 y200 w310 h160, 默认选项
    Gui Add, Text, x15 y230 w90 h25 +Right, 行内公式
    Gui Add, DropDownList, x+15 w200 vMathpix_InlineStyle gGETV AltSubmit Choose%Mathpix_InlineStyle%, $...$|\(...\)
    Gui Add, Text, x15 y+15 w90 h25 +Right, 行间公式
    Gui Add, DropDownList, x+15 w200 vMathpix_DisplayStyle gGETV AltSubmit Choose%Mathpix_DisplayStyle%, $$...$$|\[...\]
    Gui Add, Text, x15 y+15 w90 h25 +Right, 默认选择
    Gui Add, DropDownList, x+15 w200 vMathpix_DefaultSelect gGETV AltSubmit Choose%Mathpix_DefaultSelect%, LaTeX|行内公式|行间公式|文本公式

    Gui st:Show, , OCRC 设置
return

GBaidu_Hotkey:
    GuiControlGet, tVa, , % A_GuiControl
    %A_GuiControl% := tVa
    WriteIni(ConfigFile, tVa, A_GuiControl, "BaiduOCR")
    if Baidu_Hotkey {
        Hotkey %Baidu_HotkeyTemp%, BaiduOCR, Off
        Hotkey %Baidu_Hotkey%, BaiduOCR, On
        Baidu_HotkeyTemp := Baidu_Hotkey
    }
return

GMathpix_Hotkey:
    GuiControlGet, tVa, , % A_GuiControl
    %A_GuiControl% := tVa
    WriteIni(ConfigFile, tVa, A_GuiControl, "MathpixOCR")
    if Mathpix_Hotkey {
        Hotkey %Mathpix_HotkeyTemp%, MathpixOCR, Off
        Hotkey %Mathpix_Hotkey%, MathpixOCR, On
        Mathpix_HotkeyTemp := Mathpix_Hotkey
    }
return

GETV:
    GuiControlGet TabVar, , SysTabControl321
    GuiControlGet, tVa, , % A_GuiControl
    %A_GuiControl% := tVa
    WriteIni(ConfigFile, tVa, A_GuiControl, TabVar)
return

ReloadSub:
Reload
return

ExitSub:
ExitApp
return