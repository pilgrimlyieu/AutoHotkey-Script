#NoTrayIcon

#Include ..\..\..\Library\Clipboard.ahk
#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"
SetWinDelay 0
MonitorGetWorkArea( , , , &WorkAreaInfoRight, &WorkAreaInfoBottom)

; 请将 Vim 目录放 PATH

ListJoin(list, string) {
    for index, content in list
        str .= string . content
    return SubStr(str, StrLen(string) + 1)
}

#+CapsLock::SetCapsLockState(!GetKeyState("CapsLock", "T"))

#HotIf !WinActive("ahk_exe gvim.exe")

!q::{
    ClipLists := GetSelectedPath(), ClipSaved := ClipLists.saved, clip_result := ClipLists.path
    EnvSet("VIM_KEYCODE_TRANS_STRATEGY", "experimental") ; Vim patch 9.1.0050. See also `:h w32-experimental-keycode-trans-strategy`
    if InStr(clip_result, "`r`n")
        Run("gvim -d `"" ListJoin(StrSplit(clip_result, "`r`n"), "`" `"") "`"", , , &process_id)
    else if clip_result
        Run("gvim `"" clip_result "`"", , , &process_id)
    else
        Run("gvim", , , &process_id)
    if WinWait("ahk_pid " process_id, , 10) {
        ProcessSetPriority("High", process_id)
        WinSetStyle(-0xC40000, "ahk_pid " process_id)
        ; This is conflict with "au GUIEnter * simalt ~x"(auto maximized) in Vim. Don't add it to vimrc.
        WinMove(0, 0, WorkAreaInfoRight, WorkAreaInfoBottom, "ahk_pid " process_id)
        WinActivate("ahk_pid " process_id)
    }
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#HotIf WinActive("^.*✏️[isvV]$")

CapsLock::SendInput("{Alt Down}{F12}{Alt Up}")
+CapsLock::SendInput("{Alt Down}{Shift Down}{F12}{Shift Up}{Alt Up}")
^CapsLock::SendInput("{Ctrl Down}{Alt Down}{F12}{Alt Up}{Ctrl Up}")
^+CapsLock::SendInput("{Ctrl Down}{Shift Down}{Alt Down}{F12}{Alt Up}{Shift Up}{Ctrl Up}")

#HotIf WinActive(".*✏️i$") && WinActive("ahk_exe gvim.exe")

~RControl::{
    if (A_PriorHotkey != "~RControl" || A_TimeSincePriorHotkey > 250) {
        KeyWait("RControl")
        return
    }
    SendInput("{Esc}")
}

#HotIf WinActive(".*✏️i$") && WinActive("ahk_exe WindowsTerminal.exe")

~RControl::{
    if (A_PriorHotkey != "~RControl" || A_TimeSincePriorHotkey > 250) {
        KeyWait("RControl")
        return
    }
    SendInput("{Esc}{Ctrl Down}[{Ctrl Up}")
}
