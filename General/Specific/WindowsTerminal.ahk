#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

RunWT(max) {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    if DirExist(selected)
        Run("wt" (max ? " --maximized" : "") " --startingDirectory `"" selected "`" " )
    else
        Run("wt" (max ? " --maximized" : "") " --startingDirectory ~")
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT(0)
#+t::RunWT(1)