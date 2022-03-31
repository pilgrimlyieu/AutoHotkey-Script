;@Ahk2Exe-SetMainIcon Icon\OCRC_icon.ico
; Adapted from https://www.autoahk.com/archives/35526
; Thank https://www.autohotkey.com/boards/viewtopic.php?t=86814&p=381493#
; Thank https://github.com/iseahound/Vis2
; Thank https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

#Include <OCRC_class>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini", stHwnd
Global Baidu_RecogTypes := ["general_basic", "accurate_basic", "handwriting", "webimage"]
Global Baidu_RecogTypesP := ["通用文字（标准）识别", "通用文字（高精度）识别", "手写文字识别", "网络图片文字识别"]
Global Baidu_Formats := ["智能段落", "合并多行", "拆分多行"]
Global Baidu_Spaces := ["智能空格", "保留空格", "去除空格"]
Global Baidu_Puncs := ["原始结果", "智能标点", "中文标点", "英文标点"]
Global Baidu_Trans := ["自动检测", "英⟹中", "中⟹英", "繁⟹简", "日⟹中"]
Global Baidu_SEngines := ["百度搜索", "谷歌搜索", "百度百科", "维基百科", "Everything"]
Global Mathpix_ReturnStyles := ["RAW", "$RAW$", "$$RAW$$", "\(RAW\)", "\[RAW\]"]
Global C2EPuncs := {"，": ",", "。": ".", "？": "?", "！": "!", "、": ",", "：": ":", "；": ";", "“": """", "”": """", "‘": "'", "’": "'", "「": """", "」": """", "『": "'", "』": "'", "（": "(", "）": ")", "【": "[", "】": "]", "《": "", "》": ""}
Global E2CPuncs := {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}

Menu, Tray, NoStandard
Menu, Tray, Tip, OCRC
Menu, Tray, Click, 1
Menu, Tray, Add, 设置, Setting
Menu, Tray, Default, 设置
Menu, Tray, Add, 重启, ReloadSub
Menu, Tray, Add, 退出, ExitSub

if not A_IsAdmin {
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
if (!Baidu_Token and Baidu_API_Key and Baidu_Secret_Key)
	Baidu_Token := Get_Token(Baidu_API_Key, Baidu_Secret_Key)

BHKTemp := BHK
Hotkey %BHK%, BOCR, On
MHKTemp := MHK
; Hotkey %MHK%, MOCR, On

return

BOCR:
	clipboard := ""
	Send {f8}
	Sleep 500
	WinWaitNotActive Snipper - Snipaste, , 10
	if ErrorLevel {
		Send {Esc}
		return
	}
	ClipWait 1, 1
	if ErrorLevel
		return

	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromClipboard()
	base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)

	BResultJson := BDOCR_Bitmap(base64string, Baidu_Token)

	words_count := BResultJson.words_result_num
	paragraphs_count := BResultJson.paragraphs_result_num
	paragraphs := BResultJson.paragraphs_result
	words := BResultJson.words_result

	Gosub BPreDo
	if Baidu_ProbOnOff
		Gosub BProb
	Gosub BResWin
return

BPreDo:
	Baidu_ResultFormatStyle  := Baidu_FormatStyle
	Baidu_ResultPuncStyle  := Baidu_PuncStyle
	Baidu_ResultSpaceStyle  := Baidu_SpaceStyle
	Baidu_ResultTranType  := Baidu_TranType
	Baidu_ResultSearchEngine  := Baidu_SearchEngine
	Gosub DoBFormat
	Gosub DoBSpace
	Gosub DoBPunc
	Gosub DoBClip
return

BProb:
	Baidu_Probability := 0
	BProAddPlus := 0
	; BProAdd := 0
	for index, value in words {
		; BProAdd += value.probability.average
		BProAddPlus += value.probability.average * StrLen(value.words)
	}
	; Baidu_Probability := Format("{:.2f}", 100 * ProAdd / words.Length())
	Baidu_Probability := Format("{:.2f}", 100 * BProAddPlus / StrLen(BResult))
return

BResWin:
	Gui New
	Gui +MinimizeBox
	Gui Font, s16, SimHei
	Gui Add, Text, x20, 排版
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultFormatStyle gDoBFormat AltSubmit Choose%Baidu_ResultFormatStyle%, 智能段落|合并多行|拆分多行
	Gui Font, s16
	Gui Add, Text, x+15, 标点
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultPuncStyle gDoBPunc AltSubmit Choose%Baidu_ResultPuncStyle%, 原始结果|智能标点|中文标点|英文标点
	Gui Font, s16
	Gui Add, Text, x+15, 空格
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultSpaceStyle gDoBSpace AltSubmit Choose%Baidu_ResultSpaceStyle%, 智能空格|保留空格|去除空格
	Gui Font, s16
	Gui Add, Text, x+15, 翻译
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultTranType gDoBTran AltSubmit Choose%Baidu_ResultTranType%, 自动检测|英⟹中|中⟹英|繁⟹简|日⟹中
	Gui Font, s16
	Gui Add, Text, x+15, 搜索
	Gui Font, s12
	Gui Add, DropDownList, x+5 w105 vBaidu_ResultSearchEngine gDoBSearch AltSubmit Choose%Baidu_ResultSearchEngine%, 百度搜索|谷歌搜索|百度百科|维基百科|Everything
	Gui Font, s18
	Gui Add, Edit, x20 y45 w770 h395 vBResult gDoBClip hwndBResultHwnd, %BResult%
	if Baidu_ProbOnOff
		Gui Show, w800 h450, % "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[Baidu_RecogType] "」识别结果        Probability: " Baidu_Probability "%"
	else
		Gui Show, w800 h450, % "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[Baidu_RecogType] "」识别结果"
return

DoBFormat:
	Gui Submit, NoHide
	BResult := ""
	if (Baidu_ResultFormatStyle = 1) {
		for index, value in paragraphs {
			for idx, vl in value.words_result_idx
				BResult .= words[vl + 1].words
			BResult .= "`n"
		}
	}
	else if (Baidu_ResultFormatStyle = 2) {
		for index, value in words
			BResult .= value.words
	}
	else if (Baidu_ResultFormatStyle = 3) {
		for index, value in words
			BResult .= value.words "`n"
	}
	BResultTemp := BResult
	GuiControl Text, %BResultHwnd%, %BResult%
return

DoBSpace:
	Gui Submit, NoHide
	if (Baidu_ResultSpaceStyle = 1) {
		; TBC
	}
	else if (Baidu_ResultSpaceStyle = 3)
		BResult := StrReplace(BResult, A_Space)
	GuiControl Text, %BResultHwnd%, %BResult%
return

DoBPunc:
	Gui Submit, NoHide
	if (Baidu_ResultPuncStyle = 1)
		BResult := BResultTemp
	else if (Baidu_ResultPuncStyle = 2) {
		; TBC
	}
	else if (Baidu_ResultPuncStyle = 3) {
		for EP, CP in E2CPuncs
			BResult := StrReplace(BResult, EP, CP)
	}
	else if (Baidu_ResultPuncStyle = 4) {
		for CP, EP in C2EPuncs
			BResult := StrReplace(BResult, CP, EP)
	}
	GuiControl Text, %BResultHwnd%, %BResult%
return

DoBTran:
	Gui Submit, NoHide
	; TBC
return

DoBSearch:
	Gui Submit, NoHide
	; TBC
return

DoBClip:
	Gui Submit, NoHide
	clipboard := BResult
return

Create_Config:
	; IniWrite ?, %ConfigFile%, Basic, ?

	IniWrite F7, %ConfigFile%, BaiduOCR, BHK
	IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_API_Key
	IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_Secret_Key
	IniWrite % "", %ConfigFile%, BaiduOCR, Baidu_Token
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_RecogType
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_ProbOnOff
	IniWrite 1 , %ConfigFile%, BaiduOCR, Baidu_FormatStyle
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_PuncStyle
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_SpaceStyle
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_TranType
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_SearchEngine

	IniWrite F4, %ConfigFile%, MathpixOCR, MHK
	IniWrite % "", %ConfigFile%, MathpixOCR, Mathpix_App_ID
	IniWrite % "", %ConfigFile%, MathpixOCR, Mathpix_App_Key
	IniWrite 2, %ConfigFile%, MathpixOCR, Mathpix_ReturnStyle
	IniWrite 1, %ConfigFile%, MathpixOCR, Mathpix_ConfOnOff
return

!a::
Gosub Setting
return

Setting:
	if !FileExist(ConfigFile)
		Gosub Create_Config

	Gui st:New, , 设置
	Gui st:Default
	Gui st:+AlwaysOnTop +HwndstHwnd
	Gui st:Margin, 10, 10
	Gui st:Font, s12, SimHei
    Gui st:Color, EBEDF4
	Gui Add, Tab3, Choose2, 基础|BaiduOCR|MathpixOCR


	Gui Tab, 基础


	Gui Tab, BaiduOCR
	Gui Add, GroupBox, x20 y40 w310 h220, 基础设置
	Gui Add, Text, x15 y70 w90 h25 +Right, 热键
	Gui Add, Hotkey, x+15 w200 h25 vBHK gGBHK, %BHK%
	Gui Add, Text, x15 y+15 w90 h25 +Right, API Key
	Gui Add, Edit, x+15 w200 h25 vBaidu_API_Key gGETV, %Baidu_API_Key%
	Gui Add, Text, x15 y+15 w90 h25 +Right, Secret Key
	Gui Add, Edit, x+15 w200 h25 vBaidu_Secret_Key gGETV, %Baidu_Secret_Key%
	Gui Add, Text, x15 y+15 w90 h25 +Right, 识别类型
	Gui Add, DropDownList, x+15 w200 vBaidu_RecogType gGETV AltSubmit Choose%Baidu_RecogType%, 通用文字（标准）识别|通用文字（高精度）识别|手写文字识别|网络图片文字识别
	Gui Add, CheckBox, x35 y+15 w90 vBaidu_ProbOnOff gGETV Checked%Baidu_ProbOnOff% +Right, 置信度

	Gui Add, GroupBox, x20 y270 w310 h220, 默认选项
	Gui Add, Text, x15 y300 w90 h25 +Right, 默认排版
	Gui Add, DropDownList, x+15 w200 vBaidu_FormatStyle gGETV AltSubmit Choose%Baidu_FormatStyle%, 智能段落|合并多行|拆分多行
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认标点
	Gui Add, DropDownList, x+15 w200 vBaidu_PuncStyle gGETV AltSubmit Choose%Baidu_PuncStyle%, 原始结果|智能标点|中文标点|英文标点
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认空格
	Gui Add, DropDownList, x+15 w200 vBaidu_SpaceStyle gGETV AltSubmit Choose%Baidu_SpaceStyle%, 智能空格|保留空格|去除空格
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认翻译
	Gui Add, DropDownList, x+15 w200 vBaidu_TranType gGETV AltSubmit Choose%Baidu_TranType%, 自动检测|英⟹中|中⟹英|繁⟹简|日⟹中
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认搜索
	Gui Add, DropDownList, x+15 w200 vBaidu_SearchEngine gGETV AltSubmit Choose%Baidu_SearchEngine%, 百度搜索|谷歌搜索|百度百科|维基百科|Everything


	Gui Tab, MathpixOCR
	Gui Add, GroupBox, x20 y40 w310 h220, 基础设置
	Gui Add, Text, x15 y70 w90 h25 +Right, 热键
	Gui Add, Hotkey, x+15 w200 h25 vMHK gGMHK, %MHK%
	Gui Add, Text, x15 y+15 w90 h25 +Right, App ID
	Gui Add, Edit, x+15 w200 h25 vMathpix_App_ID gGETV, %Mathpix_App_ID%
	Gui Add, Text, x15 y+15 w90 h25 +Right, App Key
	Gui Add, Edit, x+15 w200 h25 vMathpix_App_Keey gGETV, %Mathpix_App_Keey%
	Gui Add, Text, x15 y+15 w90 h25 +Right, 返回样式
	Gui Add, DropDownList, x+15 w200 vMathpix_ReturnStyle gGETV AltSubmit Choose%Mathpix_ReturnStyle%, 纯文本|$...$|$$...$$|\(...\)|\[...\]
	Gui Add, CheckBox, x35 y+15 w90 vMathpix_ConfOnOff gGETV Checked%Mathpix_ConfOnOff% +Right, 置信度


	Gui st:Show, , 设置
return

GBHK:
	GuiControlGet, tVa, , % A_GuiControl
	%A_GuiControl% := tVa
	WriteIni(ConfigFile, tVa, A_GuiControl, "BaiduOCR")
	if BHK {
		Hotkey %BHKTemp%, BOCR, Off
		Hotkey %BHK%, BOCR, On
		BHKTemp := BHK
	}
return

GMHK:
	GuiControlGet, tVa, , % A_GuiControl
	%A_GuiControl% := tVa
	WriteIni(ConfigFile, tVa, A_GuiControl, "MathpixOCR")
	if MHK {
		; Hotkey %MHKTemp%, MOCR, Off
		; Hotkey %MHK%, MOCR, On
		MHKTemp := MHK
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
exitapp
return