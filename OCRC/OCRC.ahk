;@Ahk2Exe-SetMainIcon Icon\OCRC_icon.ico
; Adapted from https://www.autoahk.com/archives/35526
; Thank https://www.autohotkey.com/boards/viewtopic.php?t=86814&p=381493#
; Thank https://github.com/iseahound/Vis2
; Thank https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

#Include <OCRC_class>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini", stHwnd
Global Formats := ["智能段落", "合并多行", "拆分多行"]
Global Spaces := ["智能空格", "保留空格", "去除空格", "原始结果"]
Global Puncs := ["智能标点", "中文标点", "英文标点", "原始结果"]
Global SEngines := ["百度搜索", "谷歌搜索", "百度百科", "维基百科", "Everything"]

Menu, Tray, NoStandard
Menu, Tray, Tip, OCRC
Menu, Tray, Click, 1
Menu, Tray, Add, 设置, Show_st
Menu, Tray, Default, 设置
Menu, Tray, Add, 重启, ReloadSub
Menu, Tray, Add, 退出, ExitSub

if not A_IsAdmin {
	try {
		Run *RunAs "%A_ScriptFullPath%"
		ExitApp
	}
}

Gosub Create_st

if !FileExist(ConfigFile)
	Gosub Create_Config
_Ke := StrSplit(Readini(ConfigFile,"","OCR设置"),"`n")
loop % _Ke.length() {
	_Va := StrSplit(_Ke[A_Index],"=")
	tVar := _Va[1]
	%tVar% := _Va[2]
}
HKTemp := HK
Hotkey %HK%, OCR, On

return

OCR:
	clipboard := ""
	Send {f8}
	ClipWait , 10, 1
	if ErrorLevel
		return

	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromClipboard()
	base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)

	Baidu_Token := Get_Token(Baidu_API_Key, Baidu_Secret_Key)
	clipboard := bdocr_Bitmap(base64string, Baidu_Token)
	Gosub ResWin
return

ResWin:
	Gui New
	Gui ResWin:Default
	Gui +MaximizeBox +MinimizeBox
	Gui Font, s16, SimHei
	Gui Add, Text, x40, 排版
	Gui Font, s12
	Gui Add, DropDownList, x+5 w100 vFormatStyle gDoFormat Choose1, 智能段落|合并多行|拆分多行
	Gui Font, s16
	Gui Add, Text, x+15, 空格
	Gui Font, s12
	Gui Add, DropDownList, x+5 w100 vSpaceStyle gDoSpace Choose1, 智能空格|保留空格|去除空格|原始结果
	Gui Font, s16
	Gui Add, Text, x+15, 标点
	Gui Font, s12
	Gui Add, DropDownList, x+5 w100 vPuncStyle gDoPunc Choose1, 智能标点|中文标点|英文标点|原始结果
	Gui Font, s16
	Gui Add, Text, x+15, 搜索
	Gui Font, s12
	Gui Add, DropDownList, x+5 w100 vSearchEngine gDoSearch Choose1, 百度搜索|谷歌搜索|百度百科|维基百科|Everything
	Gui Font, s16
	Gui Add, Button, x+15 y9 w60 h30, 翻译
	Gui Font, s18
	Gui Add, Edit, x40 y45 w720 h395 vResult gDoClip
	Gui Show, w800 h450 Center, OCRC (BaiduOCR) Result`        Probability: %Probability%`%
Return

DoFormat:
; TBC
Return

DoSpace:
; TBC
Return

DoPunc:
; TBC
Return

DoSearch:
; TBC
Return

DoClip:
; TBC
Return

Create_Config:
	IniWrite, % "F7", %ConfigFile%, OCR设置, HK
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_API_Key
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_Secret_Key
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_Token
	IniWrite, general_basic, %ConfigFile%, OCR设置, 识别类型
	IniWrite, 0 , %ConfigFile%, OCR设置, 保留换行
	IniWrite, 0, %ConfigFile%, OCR设置, 保留空格
Return

Create_st:
	Global cz := 0
	Gui, st:Default
	Gui, st:+AlwaysOnTop +HwndstHwnd
	Gui, st:Margin, 10, 10
	Gui, st:Font, s12, SimHei
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, OCR 热键
	Gui, Add, Hotkey, x+15 w200 h25 vHK gGHK
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, BaiduAPI
	Gui, Add, Edit, x+15 w200 h25 vBaidu_API_Key gGETV
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, BaiduSecret
	Gui, Add, Edit, x+15 w200 h25 vBaidu_Secret_Key gGETV
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, BaiduToken
	Gui, Add, Edit, x+15 w200 h25 vBaidu_Token gGETV
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, 识别类型
	Gui, Add, DropDownList, x+15 w200 h25 v识别类型 r4 gGETV AltSubmit, 通用文字（标准）识别|通用文字（高精度）识别|手写文字识别|网络图片文字识别
	Gui, Add, Text, xm x15 y+25 w90 h25 +Right, 保留换行
	Gui, Add, Checkbox, x+15 v保留换行 gGETV
	Gui, Add, Text, xm x200 y+-19 w90 h25 +Right, 保留空格
	Gui, Add, Checkbox, x+15 v保留空格 gGETV
	Onmessage(0x18,"WM_SHOWWINDOW")
	Gui, st:Show, Hide, 设置
Return

Show_st:
	if !FileExist(ConfigFile)
		Gosub Create_Config
	Gui, st:Show, NA, 设置
Return

GHK:
	GuiControlGet, tVa, , % A_GuiControl
	%A_GuiControl% := tVa
	if cz
		Writeini(ConfigFile, tVa, A_GuiControl, "OCR设置")
	If HK {
		Hotkey %HKTemp%, OCR, Off
		Hotkey %HK%, OCR, On
		HKTemp := HK
	}
return

GETV:
	GuiControlGet, tVa, , % A_GuiControl
	if A_GuiControl = 识别类型
		tVa := _Tp[tVa]
	%A_GuiControl% := tVa
	if cz
		Writeini(ConfigFile, tVa, A_GuiControl, "OCR设置")
return

ReloadSub:
Reload
Return

ExitSub:
exitapp
Return