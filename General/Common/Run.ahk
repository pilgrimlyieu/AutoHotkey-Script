#NoTrayIcon
#SingleInstance Force

#Include ..\..\Library\Clipboard.ahk
#Include ..\..\Library\IME.ahk

; 请将 Everything 目录放 PATH
#f::{
    ClipLists := GetSelectedPath(), ClipSaved := ClipLists.saved, selected := ClipLists.path
    if DirExist(selected)
        ; "Run(everything -path `"" selected "`"") ; 为路径则打开路径（包括子文件夹）
        Run("everything -parent `"" selected "`"") ; 为路径则打开路径（不包括子文件夹）
    else if FileExist(selected)
        SplitPath(selected, &name), Run("everything -search `"" name "`"") ; 为文件则搜索文件名
    else
        Run("everything -search `"" selected "`"") ; 不为路径则搜索指定内容
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#+e::Run("rundll32 sysdm.cpl,EditEnvironmentVariables")

#+c::Run("ms-clock:")

#b::Run("msedge")

#+b::Run("msedge.exe -inprivate")

#p::Run("control")

#g::Run("regedit")

#q::Run("code")

^Space::{
    ProxyStatus := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
    RegWrite(ProxyStatus := !ProxyStatus, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
    ToolTip("Proxy has been switched " (ProxyStatus ? "On." : "Off."))
    SetTimer(() => ToolTip(), -1000)
}

#+F1::{ ; 双拼方案 UserDefinedDoublePinyinScheme0: 小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt
    RegWrite(ShuangpinStatus := !IsShuangpin(), "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS", "Enable Double Pinyin")
    ToolTip("已" (ShuangpinStatus ? "启用" : "关闭") "双拼。")
    SetTimer(() => ToolTip(), -1000)
}

#F2::{ ; Adapted from https://www.autohotkey.com/boards/viewtopic.php?p=180845#p180845
    TaskbarGlomLevelStatus := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarGlomLevel")
    RegWrite(TaskbarGlomLevelStatus := !TaskbarGlomLevelStatus, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarGlomLevel")
    SendMessage(0x1A, , , , "ahk_class Shell_TrayWnd")
    WinRedraw("ahk_class Shell_TrayWnd")
}

#F3::{ ; https://superuser.com/a/1357023
    buttonState := DllCall("user32.dll\SwapMouseButton", "UInt", 1)
    if buttonState != 0 {
        buttonState := DllCall("user32.dll\SwapMouseButton", "UInt", 0)
    }
}

#!Space::{
    TouchpadStatus := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad\Status", "Enabled")
    Run("SystemSettingsAdminFlows.exe EnableTouchPad " (TouchpadStatus := !TouchpadStatus))
}

PrintScreen::Run("D:\Software\Snipaste\Snipaste.exe snip")
+PrintScreen::Run("D:\Software\Snipaste\Snipaste.exe paste")
