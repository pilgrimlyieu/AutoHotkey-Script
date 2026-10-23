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

BuildNeovimCommand(paths) {
    exe := "neovide"
    if (paths.Length > 1)
        return exe . " --no-tabs " . JoinQuoted(paths) . " -- -d"
    if (paths.Length == 1)
        return exe . " " . QuotePath(paths[1])
    return exe
}

openNeovim() {
    global workAreaInfoRight, workAreaInfoBottom

    selected := GetSelectedPath()
    savedClipboard := selected.saved
    clipText := selected.path

    paths := GetSelectedPaths(clipText)
    cwd := GetWorkingDir(paths)

    command := BuildNeovimCommand(paths)
    Run(command, cwd, , &pid)

    if WinWait("ahk_pid " pid, , 1) {
        ProcessSetPriority("High", pid)
        WinMove(0, 0, workAreaInfoRight, workAreaInfoBottom, "ahk_pid " pid)
        try WinActivate("ahk_pid " pid)
    }

    A_Clipboard := savedClipboard
}

#+CapsLock::SetCapsLockState(!GetKeyState("CapsLock", "T"))

#HotIf !WinActive("ahk_exe neovide.exe")

!q::openNeovim()

#HotIf WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe neovide.exe")

CapsLock::SendInput("{Alt Down}{F12}{Alt Up}")
+CapsLock::SendInput("{Alt Down}{Shift Down}{F12}{Shift Up}{Alt Up}")
^CapsLock::SendInput("{Ctrl Down}{Alt Down}{F12}{Alt Up}{Ctrl Up}")
^+CapsLock::SendInput("{Ctrl Down}{Shift Down}{Alt Down}{F12}{Alt Up}{Shift Up}{Ctrl Up}")
