#NoTrayIcon

#Include ..\..\..\Library\Clipboard.ahk
#Include ..\..\..\Library\IME.ahk

SetTitleMatchMode "RegEx"
SetWinDelay 0
MonitorGetWorkArea( , , , &WorkAreaInfoRight, &WorkAreaInfoBottom)

; 请将 Vim 目录放 PATH

JoinArray(arr, sep) {
    result := ""
    for i, v in arr {
        if (i > 1)
            result .= sep
        result .= v
    }
    return result
}

QuotePath(path) {
    return '"' . path . '"'
}

JoinQuoted(paths) {
    quoted := []
    for p in paths
        quoted.Push(QuotePath(p))
    return JoinArray(quoted, " ")
}

GetSelectedPaths(clipText) {
    paths := []
    if (clipText == "")
        return paths

    for p in StrSplit(clipText, "`r`n") {
        if (p != "")
            paths.Push(p)
    }
    return paths
}

GetWorkingDir(paths) {
    home := EnvGet("USERPROFILE")

    if (paths.Length == 0)
        return home

    ; 多个文件比较时，取第一个
    first := paths[1]

    ; 如果选中的本身就是目录，直接作为 CWD
    if DirExist(first)
        return first

    ; 否则取文件所在目录
    SplitPath(first, , &dir)
    return dir ? dir : home
}

BuildVimCommand(neovim, paths) {
    if (neovim) {
        exe := "neovide --frame none"
        if (paths.Length > 1)
            return exe . " --no-tabs " . JoinQuoted(paths) . " -- -d"
        if (paths.Length == 1)
            return exe . " " . QuotePath(paths[1])
        return exe
    }

    exe := "gvim"
    if (paths.Length > 1)
        return exe . " -d " . JoinQuoted(paths)
    if (paths.Length == 1)
        return exe . " " . QuotePath(paths[1])
    return exe
}

openVim(neovim := true) {
    global workAreaInfoRight, workAreaInfoBottom

    selected := GetSelectedPath()
    savedClipboard := selected.saved
    clipText := selected.path

    paths := GetSelectedPaths(clipText)
    cwd := GetWorkingDir(paths)

    if (!neovim)
        EnvSet("VIM_KEYCODE_TRANS_STRATEGY", "experimental") ; Vim patch 9.1.0050

    command := BuildVimCommand(neovim, paths)
    Run(command, cwd, , &pid)

    if WinWait("ahk_pid " pid, , 1) {
        ProcessSetPriority("High", pid)
        if (!neovim)
            WinSetStyle(-0xC40000, "ahk_pid " pid)
        ; 与 Vim 的 au GUIEnter * simalt ~x 冲突，不要加到 vimrc
        WinMove(0, 0, workAreaInfoRight, workAreaInfoBottom, "ahk_pid " pid)
        try WinActivate("ahk_pid " pid)
    }

    A_Clipboard := savedClipboard
}

#+CapsLock::SetCapsLockState(!GetKeyState("CapsLock", "T"))

#HotIf !WinActive("ahk_exe gvim.exe") && !WinActive("ahk_exe neovide.exe")

!q::openVim()
!+q::openVim(false)

; #HotIf WinActive("^.*✏️[isvV]$") || (WinActive("ahk_exe WindowsTerminal.exe") && WinActive(" \| [\w-]*md$"))

#HotIf WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe gvim.exe") || WinActive("ahk_exe neovide.exe")

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
