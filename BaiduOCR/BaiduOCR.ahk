;@Ahk2Exe-SetMainIcon Icon\BaiduOCR_icon.ico
; Adapted from https://www.autoahk.com/archives/35526
; Thank https://www.autohotkey.com/boards/viewtopic.php?t=86814&p=381493#
; Thank https://github.com/iseahound/Vis2
; Thank https://wyagd001.github.io/zh-cn/docs/AutoHotkey.htm

#Include <BaiduOCR_class>

Global BD_Configfile := A_ScriptDir "\BaiduOCR_config.privacy.ini", stHwnd

Menu, Tray, NoStandard
Menu, Tray, Tip, BaiduOCR
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

create_st := 1

Gosub Create_st

if !FileExist(BD_Configfile)
	Gosub Create_Config
_Ke := StrSplit(Readini(BD_Configfile,"","OCR设置"),"`n")
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
	ClipWait , , 10
	if ErrorLevel
		return

	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromClipboard()
	base64string := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)

	token := Get_token(API_Key, Secret_Key)
	clipboard := bdocr_Bitmap(base64string, token)
	Gui New, +Resize +MinSize180x160, BaiduOCR Result
	Gui font, s18, times new roman
	Gui add, text, , %clipboard%
	Gui show
return

Create_Config:
	IniWrite, % "F7", %BD_Configfile%, OCR设置, HK
	IniWrite, % "", %BD_Configfile%, OCR设置, API_Key
	IniWrite, % "", %BD_Configfile%, OCR设置, Secret_Key
	IniWrite, % "", %BD_Configfile%, OCR设置, BD_token
	IniWrite, general_basic, %BD_Configfile%, OCR设置, 识别类型
	IniWrite, 0 , %BD_Configfile%, OCR设置, 保留换行
	IniWrite, 0, %BD_Configfile%, OCR设置, 保留空格
return

Create_st:
	Global cz := 0
	Gui, st:Default
	Gui, st:+AlwaysOnTop +HwndstHwnd
	Gui, st:Margin, 10, 10
	Gui, st:Font, s14, SimHei
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, OCR 热键
	Gui, Add, Hotkey, x+15 w250 h25 vHK gGHK
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, API_Key
	Gui, Add, Edit, x+15 w250 h25 vAPI_Key gGETV
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, Secret_Key
	Gui, Add, Edit, x+15 w250 h25 vSecret_Key gGETV
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, BD_token
	Gui, Add, Edit, x+15 w250 h25 vBD_token gGETV
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, 识别类型
	Gui, Add, DropDownList, x+15 w250 h25 v识别类型 r4 gGETV AltSubmit, 通用文字（标准）识别|通用文字（高精度）识别|手写文字识别|网络图片文字识别
	Gui, Add, Text, xm x15 y+25 w100 h25 +Right, 保留换行
	Gui, Add, Checkbox, x+15 v保留换行 gGETV
	Gui, Add, Text, xm x250 y+-19 w100 h25 +Right, 保留空格
	Gui, Add, Checkbox, x+15 v保留空格 gGETV
	Onmessage(0x18,"WM_SHOWWINDOW")
	Gui, st:Show, Hide, 设置
Return

Show_st:
	if !FileExist(BD_Configfile)
		Gosub Create_Config
	Gui, st:Show, NA, 设置
Return

GHK:
	GuiControlGet, tVa, , % A_GuiControl
	%A_GuiControl% := tVa
	if cz
		Writeini(BD_Configfile, tVa, A_GuiControl, "OCR设置")
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
		Writeini(BD_Configfile, tVa, A_GuiControl, "OCR设置")
return

ReloadSub:
Reload
Return

ExitSub:
exitapp
Return