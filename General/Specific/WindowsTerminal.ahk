#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

RunWT(profile := "Git Bash") {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run(Format("wt -w 0 new-tab --profile `"{1}`" --startingDirectory `"{2}`"", profile, DirExist(selected) ? selected : "~"))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT()
#+t::RunWT("Ubuntu-22.04")