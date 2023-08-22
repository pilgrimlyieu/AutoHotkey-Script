#NoTrayIcon

; 请将 Everything 目录放 PATH
#f::{
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(0.5, 0)
    selected := Trim(A_Clipboard)
    if InStr(FileExist(selected), "D")
        ; "Run(everything -path `"" selected "`"") ; 为路径则打开路径（包括子文件夹）
        Run("everything -parent `"" selected "`"") ; 为路径则打开路径（不包括子文件夹）
    else if selected
        Run("everything -search `"" selected "`"") ; 不为路径则搜索指定内容
    else
        Run("everything -home") ; 未选中内容时打开主界面
    A_Clipboard := ClipSaved
    ClipSaved := ""
}

^Space::{
    ProxyStatus := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
    RegWrite(ProxyStatus := !ProxyStatus, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
    ToolTip("Proxy has been switched " (ProxyStatus ? "On." : "Off."))
    SetTimer(() => ToolTip(), -1000)
}

#!Space::{
    TouchpadStatus := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad\Status", "Enabled")
    Run("SystemSettingsAdminFlows.exe EnableTouchPad " (TouchpadStatus := !TouchpadStatus))
}