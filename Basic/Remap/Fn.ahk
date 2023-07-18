#Requires AutoHotkey v1.1.36.02+
#NoTrayIcon

Fn_Status := 0

#Space::
Fn_Status := !Fn_Status
ToolTip % Fn_Status ? "Fn is turned on." : "Fn is turned off."
SetTimer RemoveToolTip, -1000
return

!Space::
ToolTip % Fn_Status ? "Fn is on." : "Fn is off."
SetTimer RemoveToolTip, -1000
return

RemoveToolTip:
ToolTip
return

#If Fn_Status and WinActive("ahk_exe msedge.exe")
f4::SendInput {Browser_Home}
f5::SendInput {Browser_Refresh}
f6::SendInput {Browser_Back}
f7::SendInput {Browser_Forward}

#If Fn_Status
f1::SendInput {Volume_Mute}
f2::SendInput {Volume_Up}
f3::SendInput {Volume_Down}

f8::
if WinExist("ahk_exe Anki.exe") {
    if !WinActive("ahk_exe Anki.exe")
        WinActivate ahk_exe Anki.exe
}
else
    Run "G:\Movable Computer\Movable Software\Program Files\Anki\Anki.exe" -b "G:\Movable Computer\Movable Software\Program Files\Anki\AnkiData"
return

f9::
if WinExist("GeoGebra") {
    if !WinActive("GeoGebra")
        WinActivate GeoGebra
}
else
    Run GeoGebra.exe, D:\Program Files\GeoGebra
return

f10::
if WinExist("ahk_exe msedge.exe") {
    if !WinActive("ahk_exe msedge.exe")
        WinActivate ahk_exe msedge.exe
}
else
    Run MSEdge.exe
return

f11::Run Explorer.exe

f12::
if WinExist("计算器") {
    if !WinActive("计算器")
        WinActivate 计算器
}
else
    Run Calc.exe
return
