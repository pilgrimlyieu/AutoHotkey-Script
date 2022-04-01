;@Ahk2Exe-SetMainIcon Icon\OCRC_icon.ico
; Adapted from https://www.autoahk.com/archives/35526
; Thank https://www.autohotkey.com/boards/viewtopic.php?t=86814&p=381493#
; Thank https://github.com/iseahound/Vis2
; Thank https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

#Include <OCRC_class>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini"

Global Baidu_RecogTypes := ["general_basic", "accurate_basic", "handwriting", "webimage"]
Global Baidu_RecogTypesP := ["通用文字（标准）识别", "通用文字（高精度）识别", "手写文字识别", "网络图片文字识别"]
Global Baidu_Formats := ["智能段落", "合并多行", "拆分多行"]
Global Baidu_Puncs := ["智能标点", "原始结果", "中文标点", "英文标点"]
Global Baidu_Spaces := ["智能空格", "原始结果", "去除空格"]
Global Baidu_Trans := ["自动检测", "英⟹中", "中⟹英", "繁⟹简", "日⟹中"]
Global Baidu_SEngines := ["百度搜索", "谷歌搜索", "谷歌镜像", "百度百科", "维基镜像", "Everything"]
Global IsChinese := "[\x{4e00}-\x{9fa5}]"
Global IsChineseBefore := "(?:[\x{4e00}-\x{9fa5}]\s?)\K" ; 由于回顾断言的缺陷，用 \K 代替回顾断言
Global IsChineseAfter := "(?=\s?[\x{4e00}-\x{9fa5}])"
Global IsEnglishBefore := "([\w\d]\s?)\K"
Global IsEnglishAfter := "(?=\s?[\w\d])"
; Global CPuncs := ["，", "。", "？", "！", "、", "：", "；", "“", "”", "‘", "’", "「", "」", "『", "』", "（", "）", "【", "】", "《", "》"]
; Global EPuncs := [",", ".", "?", "!", ":", ";", "(", ")", "[", "]"]
Global C2EPuncs := {"，": ",", "。": ".", "？": "?", "！": "!", "、": ",", "：": ":", "；": ";", "“": """", "”": """", "‘": "'", "’": "'", "「": """", "」": """", "『": "'", "』": "'", "（": "(", "）": ")", "【": "[", "】": "]", "《": "", "》": ""}
Global E2CPuncs := {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
Global Baidu_SEnginesP := ["https://www.baidu.com/s?wd=", "https://www.google.com/search?q=", "https://google.pem.app/search?q=", "https://baike.baidu.com/item/", "https://zh.wikipedia.iwiki.eu.org/wiki/"]

Global Mathpix_ReturnStyles := ["RAW", "$RAW$", "$$RAW$$", "\(RAW\)", "\[RAW\]"]

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
Hotkey %MHK%, MOCR, On

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
	if Baidu_ProbType
		Gosub BProb
	Gosub BResWin
return

MOCR:
; TBC
return

BPreDo:
	Baidu_ResultFormatStyle  := Baidu_FormatStyle
	Baidu_ResultPuncStyle  := Baidu_PuncStyle
	Baidu_ResultSpaceStyle  := Baidu_SpaceStyle
	Baidu_ResultTranType  := Baidu_TranType
	Baidu_ResultSearchEngine  := Baidu_SearchEngine
	Gosub DoBFormat
	Gosub DoBPunc
	Gosub DoBSpace
	Gosub DoBClip
return

BProb:
	Baidu_Probability := 0
	if (Baidu_ProbType = 1) {
		BProAddPlus := 0
		for index, value in words
			BProAddPlus += value.probability.average * StrLen(value.words)
		Baidu_Probability := Format("{:.2f}", 100 * BProAddPlus / StrLen(BResult))
	}
	else {
		BProAdd := 0
		for index, value in words
			BProAdd += value.probability.average
		Baidu_Probability := Format("{:.2f}", 100 * ProAdd / words_count)
	}
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
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultPuncStyle gDoBPunc AltSubmit Choose%Baidu_ResultPuncStyle%, 智能标点|原始结果|中文标点|英文标点
	Gui Font, s16
	Gui Add, Text, x+15, 空格
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultSpaceStyle gDoBSpace AltSubmit Choose%Baidu_ResultSpaceStyle%, 智能空格|原始结果|去除空格
	Gui Font, s16
	Gui Add, Text, x+15, 翻译
	Gui Font, s12
	Gui Add, DropDownList, x+5 w90 vBaidu_ResultTranType gDoBTran AltSubmit Choose%Baidu_ResultTranType%, 自动检测|英⟹中|中⟹英|繁⟹简|日⟹中
	Gui Font, s16
	Gui Add, Text, x+15, 搜索
	Gui Font, s12
	Gui Add, DropDownList, x+5 w105 vBaidu_ResultSearchEngine gDoBSearch AltSubmit Choose%Baidu_ResultSearchEngine%, 百度搜索|谷歌搜索|谷歌镜像|百度百科|维基镜像|Everything
	Gui Font, s18
	Gui Add, Edit, x20 y45 w770 h395 vBResult gDoBClip hwndBResultHwnd, %BResult%
	if Baidu_ProbType
		Gui Show, w800 h450, % "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[Baidu_RecogType] "」识别结果        Probability: " Baidu_Probability "%"
	else
		Gui Show, w800 h450, % "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[Baidu_RecogType] "」识别结果"
return

DoBFormat:
	; 排版选项会覆盖标点、空格的修改。即如果需要撤销全部更改可以选择排版中的智能段落。
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

DoBPunc:
	Gui Submit, NoHide
	if (Baidu_ResultPuncStyle = 1) {
		for c, e in C2EPuncs
			BResult := RegExReplace(BResult, (c ~= "[“‘「『（【《]") ? c IsEnglishAfter : IsEnglishBefore c, e)
		for e, c in E2CPuncs
			BResult := RegExReplace(BResult, (e ~= "[([]") ? ((e ~= "[.?()[\]]") ? "\" e : e) IsChineseAfter : IsChineseBefore ((e ~= "[.?()[\]]") ? "\" e : e), c)
		PTR := ""
		loop parse, BResult, "
		{
			if Mod(A_Index, 2)
				PTR .= A_LoopField "“"
			else
				PTR .= Trim(A_LoopField) "”"
		}
		BResult := ""
		loop parse, PTR, '
		{
			if Mod(A_Index, 2)
				BResult .= A_LoopField "‘"
			else
				BResult .= Trim(A_LoopField) "’"
		}
		BResult := SubStr(BResult, 1, StrLen(BResult) - 2)
	}
	else if (Baidu_ResultPuncStyle = 1)
		BResult := BResultSpaceTemp
	else if (Baidu_ResultPuncStyle = 3) {
		for EP, CP in E2CPuncs
			BResult := StrReplace(BResult, EP, CP)
	}
	else if (Baidu_ResultPuncStyle = 4) {
		for CP, EP in C2EPuncs
			BResult := StrReplace(BResult, CP, EP)
	}
	BResultPuncTemp := BResult
	GuiControl Text, %BResultHwnd%, %BResult%
return

DoBSpace:
	Gui Submit, NoHide
	if (Baidu_ResultSpaceStyle = 1) {
		; 先智能标点再智能空格以获得更好体验。
		for c, e in C2EPuncs
			BResult := RegExReplace(BResult, " ?(" c ") ?", "$1")
		BResult := RegExReplace(BResult, "(?:[\x{4e00}-\x{9fa5}a-zA-Z])\K ?([\w.:-]+) ?(?=[\x{4e00}-\x{9fa5}a-zA-Z])", " $1 ")
		BResult := RegExReplace(BResult, "(?:[\x{4e00}-\x{9fa5}a-zA-Z])\K ?([\w.:-]+) ?(?![\x{4e00}-\x{9fa5}a-zA-Z])", " $1")
		BResult := RegExReplace(BResult, "(?<![\x{4e00}-\x{9fa5}a-zA-Z]) ?([\w.:-]+) ?(?=[\x{4e00}-\x{9fa5}a-zA-Z])", "$1 ")
		BResult := RegExReplace(BResult, "(?:[\w\d])?\K ?([,.?!:;]) ?(?=[\w\d])?", "$1 ")
		BResult := RegExReplace(BResult, "(?:[\w\d])?\K([([]) ?(?=[\w\d])?", "$1")
		BResult := RegExReplace(BResult, "(?:[\w\d])?\K ?([)\]])(?=[\w\d])?", "$1")
		BResult := RegExReplace(BResult, "(?:\d)\K ?([.:]) ?(?=\d)", "$1")
		PTR := ""
		loop parse, BResult, "
		{
			if Mod(A_Index, 2)
				PTR .= A_LoopField """"
			else
				PTR .= Trim(A_LoopField) """"
		}
		BResult := ""
		loop parse, PTR, '
		{
			if Mod(A_Index, 2)
				BResult .= A_LoopField "'"
			else
				BResult .= Trim(A_LoopField) "'"
		}
		BResult := SubStr(BResult, 1, StrLen(BResult) - 2)
	}
	else if (Baidu_ResultSpaceStyle = 2)
		BResult := BResultPuncTemp
	else if (Baidu_ResultSpaceStyle = 3)
		BResult := StrReplace(BResult, A_Space)
	BResultSpaceTemp := BResult
	GuiControl Text, %BResultHwnd%, %BResult%
return

DoBTran:
	Gui Submit, NoHide
	; TBC
return

DoBSearch:
	Gui Submit, NoHide
	if (Baidu_ResultSearchEngine = 6) {
		if (!(BResult ~= "[*?""<>|]") and BResult ~= "[C-G]:(?:[\\/].+)+")
			Run D:/Program Files/Everything/Everything.exe -path "%BResult%"
		else if BResult
			Run D:/Program Files/Everything/Everything.exe -search "%BResult%"
		else
			Run D:/Program Files/Everything/Everything.exe -home
	}
	else {
		Run % Baidu_SEnginesP[Baidu_ResultSearchEngine] BResult
		if (Baidu_ResultSearchEngine = 3)
			MsgBox 4144, 警告, 请勿在镜像站输入隐私信息！
	}
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
	IniWrite 1, %ConfigFile%, BaiduOCR, Baidu_ProbType
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
	Gui Add, CheckBox, x35 y+15 w90 vBaidu_ProbType gGETV Check3 Checked%Baidu_ProbType% +Right, 置信度

	Gui Add, GroupBox, x20 y270 w310 h220, 默认选项
	Gui Add, Text, x15 y300 w90 h25 +Right, 默认排版
	Gui Add, DropDownList, x+15 w200 vBaidu_FormatStyle gGETV AltSubmit Choose%Baidu_FormatStyle%, 智能段落|合并多行|拆分多行
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认标点
	Gui Add, DropDownList, x+15 w200 vBaidu_PuncStyle gGETV AltSubmit Choose%Baidu_PuncStyle%, 智能标点|原始结果|中文标点|英文标点
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认空格
	Gui Add, DropDownList, x+15 w200 vBaidu_SpaceStyle gGETV AltSubmit Choose%Baidu_SpaceStyle%, 智能空格|原始结果|去除空格
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认翻译
	Gui Add, DropDownList, x+15 w200 vBaidu_TranType gGETV AltSubmit Choose%Baidu_TranType%, 自动检测|英⟹中|中⟹英|繁⟹简|日⟹中
	Gui Add, Text, x15 y+15 w90 h25 +Right, 默认搜索
	Gui Add, DropDownList, x+15 w200 vBaidu_SearchEngine gGETV AltSubmit Choose%Baidu_SearchEngine%, 百度搜索|谷歌搜索|谷歌镜像|百度百科|维基镜像|Everything


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
		Hotkey %MHKTemp%, MOCR, Off
		Hotkey %MHK%, MOCR, On
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