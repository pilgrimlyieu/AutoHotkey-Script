#HotIf WinActive("ahk_exe anki.exe")

^b::{
    A_Clipboard := RegExReplace(A_Clipboard, "m)^ {4}| +$", "")
    SendInput("^v")
}
