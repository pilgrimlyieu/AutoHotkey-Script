#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

RunVSCode() {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run(Format("code `"{1}`"", selected))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#q::RunVSCode()
