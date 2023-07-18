#Requires AutoHotkey v1.1.36.02+
#NoTrayIcon

if not A_IsAdmin
    Run *RunAs "%A_ScriptFullPath%" /restart

Global EverythingPath := "D:/Program Files/Everything/Everything.exe "

#f::
    Clip := ClipboardAll
    Clipboard := ""
    SendInput {Ctrl Down}c{Ctrl Up}
    ClipWait 0
    selected := Trim(Clipboard)
    if (!(selected ~= "[*?""<>|]") and selected ~= "^[C-Z]:(?:[\\\/].+)*[\\\/][^.]+$")
        ; Run % EverythingPath "-path " """" selected """" ; 为路径则打开路径（包括子文件夹）
        Run % EverythingPath "-parent " """" selected """" ; 为路径则打开路径（不包括子文件夹）
    else if (selected != "")
        Run % EverythingPath "-search " """" selected """" ; 不为路径则搜索指定内容
    else
        Run % EverythingPath "-home" ; 未选中内容时打开主界面
    Clipboard := Clip
return

#s::WinMinimize A
#+s::WinMaximize A

^Space::
RegRead ProxyStatus, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
RegWrite REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable, % ProxyStatus := !ProxyStatus
ToolTip % "Proxy has been switched " (ProxyStatus ? "On" : "Off") "."
SetTimer RemoveToolTip, -1000
return

#!Space::
RegRead TouchpadStatus, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad\Status, Enabled
Run % "SystemSettingsAdminFlows.exe EnableTouchPad " (TouchpadStatus := !TouchpadStatus)
return

RemoveToolTip:
ToolTip
return
