; everyting 搜索
#f::
	Clipboard := ""
	Send {Ctrl Down}c{Ctrl Up}
	Clipboard := Trim(Clipboard)
	If (!(Clipboard ~= "[*?""<>|]") and Clipboard ~= "[C-G]:(?:[\\/].+)+")
		Run D:/Program Files/Everything/Everything.exe -path "%Clipboard%"
	Else If Clipboard
		Run D:/Program Files/Everything/Everything.exe -search "%Clipboard%"
	Else
		Run D:/Program Files/Everything/Everything.exe -home
	Clipboard := ""
Return

#HotString * c0

; 课表
::ctb::
	Run C:\Users\Administrator\Desktop\课表.png, , Max
	#IfWinActive ahk_exe D:\Program Files\Honeyview\Honeyview.exe
	KeyWait q, DT5
	WinClose ahk_exe D:\Program Files\Honeyview\Honeyview.exe, , 0
	#IfWinActive
Return

; 时间表
::ttb::
	Run C:\Users\Administrator\Desktop\时间表.png, , Max
	#IfWinActive ahk_exe D:\Program Files\Honeyview\Honeyview.exe
	KeyWait q, DT5
	WinClose ahk_exe D:\Program Files\Honeyview\Honeyview.exe, , 0
	#IfWinActive
Return

; 数学课本
:X:sxs::Run G:\Movable Computer\Library\ENoteBook\Docs\CourseFiles\2-Mathematics\电子课本\人教A版-高中数学-选择性必修第三册.pdf, , Max


; 物理课本
:X:wls::Run G:\Movable Computer\Library\ENoteBook\Docs\CourseFiles\4-Physics\电子课本\新人教版-高中物理-选择性必修第一册-除动量.pdf, , Max


; 物理必刷题答案
:X:bst::Run G:\Movable Computer\Library\ENoteBook\Docs\CourseFiles\4-Physics\电子练习册\物理选修一必刷题答案.pdf, , Max


#a::WinSet AlwaysOnTop, , A