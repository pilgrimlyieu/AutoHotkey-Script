RunWT(max) {
    ClipSaved := ClipboardAll(), A_Clipboard := ""
    SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(0.5, 0)
    selected := Trim(A_Clipboard)
    if DirExist(selected)
        Run("wt" (max ? " --maximized" : "") " --startingDirectory `"" selected "`" " )
    else
        Run("wt" (max ? " --maximized" : "") " --startingDirectory ~")
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT(0)
#+t::RunWT(1)