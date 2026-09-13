#HotIf WinActive("ahk_exe anki.exe") || WinActive("ahk_exe pythonw.exe")

kfsjfjsdkgnsjgnagn(string) {
    temp := RegExReplace(string, "!(?P<alt>\[.*?\])\((?P<course>(?:\./)?[\d\w-]+)/(?P<name>.+?)\)", "!${alt}(images/${name})")
    temp := StrReplace(temp, "<", "&lt;")
    return temp
}

^b::{
    A_Clipboard := kfsjfjsdkgnsjgnagn(A_Clipboard)
    SendInput("^v")
}

^+b::{
    A_Clipboard := RegExReplace(A_Clipboard, "!(?P<alt>\[.*?\])\((?P<course>(?:\./)?[\d\w-]+)/(?P<name>.+?)\)", "!${alt}(images/${name})")
    SendInput("^v")
}

^!+b::{
    TempContent := kfsjfjsdkgnsjgnagn(A_Clipboard)
    A_Clipboard := RegExReplace(TempContent, "m)^ {4}| +$", "")
    SendInput("^v")
}
