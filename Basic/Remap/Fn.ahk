#NoTrayIcon

Fn_Status := 0

#Space::{
    global Fn_Status
    Fn_Status := !Fn_Status
    ToolTip Fn_Status ? "Fn is turned on." : "Fn is turned off."
    SetTimer () => ToolTip(), -1000
}

!Space::{
    global Fn_Status
    ToolTip Fn_Status ? "Fn is on." : "Fn is off."
    SetTimer () => ToolTip(), -1000
}

#HotIf Fn_Status && WinActive("ahk_exe msedge.exe")
F4::SendInput "{Browser_Home}"
F5::SendInput "{Browser_Refresh}"
F6::SendInput "{Browser_Back}"
F7::SendInput "{Browser_Forward}"

#HotIf Fn_Status
F1::SendInput "{Volume_Mute}"
F2::SendInput "{Volume_Up}"
F3::SendInput "{Volume_Down}"

F9::{
if WinExist("GeoGebra") {
    if !WinActive("GeoGebra")
        WinActivate "GeoGebra"
}
else
    Run "GeoGebra.exe", "D:\Program Files\GeoGebra"
}

F10::{
if WinExist("ahk_exe msedge.exe") {
    if !WinActive("ahk_exe msedge.exe")
        WinActivate "ahk_exe msedge.exe"
}
else
    Run "msedge.exe"
}

F11::Run "explorer.exe"

F12::{
if WinExist("计算器") {
    if !WinActive("计算器")
        WinActivate "计算器"
}
else
    Run "calc.exe"
}
