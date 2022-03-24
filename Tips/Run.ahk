; everyting 搜索
#f::
	Send {Ctrl Down}c{Ctrl Up}
	If Clipboard
		Run D:/Program Files/Everything/Everything.exe -search %Clipboard%
	Else
		Run D:/Program Files/Everything/Everything.exe
	Clipboard := ""
Return

; 课表
:*C0:ctb::
	Run C:\Users\Administrator\Desktop\课表.png, , Max
	#IfWinActive ahk_exe D:\Program Files\Honeyview\Honeyview.exe
	KeyWait q, DT5
	WinClose ahk_exe D:\Program Files\Honeyview\Honeyview.exe, , 0
	#IfWinActive
Return

; 时间表
:*C0:ttb::
	Run C:\Users\Administrator\Desktop\时间表.png, , Max
	#IfWinActive ahk_exe D:\Program Files\Honeyview\Honeyview.exe
	KeyWait q, DT5
	WinClose ahk_exe D:\Program Files\Honeyview\Honeyview.exe, , 0
	#IfWinActive
Return

#a::
WinSet AlwaysOnTop, , A