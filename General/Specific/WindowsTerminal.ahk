#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

RunWT() {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run("wt --startingDirectory `"" (DirExist(selected) ? selected : "~") "`"")
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT()