#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

RunVSCode() {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run(Format("code `"{1}`"", selected))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

zedPath := "D:\Software\Scoop\apps\zed\current\Zed.exe"

RunZed() {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run(Format("`"{1}`" `"{2}`"", zedPath, selected))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#q::RunZed()
#+q::RunVSCode()
