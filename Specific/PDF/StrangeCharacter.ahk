global pinyins := "^\w*[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü]\w*$"

Clean(string) {
    if !(string ~= pinyins)
        string := RegExReplace(string, "[\w\s@#]")
    return string
}

#HotIf WinActive("ahk_exe SumatraPDF.exe")

$^c::{
    SendInput "{Ctrl Down}c{Ctrl Up}"
    ClipWait 0.5, 0
    ClipSaved := RegExReplace(A_Clipboard, "\s*\v+\s*")
    A_Clipboard := Clean(ClipSaved)
    ClipSaved := ""
}

^+c::SendInput "{Ctrl Down}c{Ctrl Up}"