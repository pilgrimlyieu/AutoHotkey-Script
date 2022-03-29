;@Ahk2Exe-SetMainIcon Icon\OCRC_icon.ico
; Adapted from https://www.autoahk.com/archives/35526
; Thank https://www.autohotkey.com/boards/viewtopic.php?t=86814&p=381493#
; Thank https://github.com/iseahound/Vis2
; Thank https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

#Include <OCRC_class>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini", stHwnd

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
	Gui New, +Resize +MinSize180x160, OCRC Result
	Gui font, s18, times new roman
	Gui add, text, , %clipboard%
	Gui show
return

Create_Config:
	IniWrite, % "F7", %ConfigFile%, OCR设置, HK
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_API_Key
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_Secret_Key
	IniWrite, % "", %ConfigFile%, OCR设置, Baidu_Token
	IniWrite, general_basic, %ConfigFile%, OCR设置, 识别类型
	IniWrite, 0 , %ConfigFile%, OCR设置, 保留换行
	IniWrite, 0, %ConfigFile%, OCR设置, 保留空格
return

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