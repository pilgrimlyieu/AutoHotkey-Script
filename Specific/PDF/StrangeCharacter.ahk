global pinyins := "^\w*[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü]\w*$"

#HotIf WinActive("ahk_exe SumatraPDF.exe")

$^c::{
    SendInput("{Ctrl Down}c{Ctrl Up}")
    ClipWait(0.5, 0)
    ClipSaved := RegExReplace(A_Clipboard, "\s*\v+\s*")
    A_Clipboard := (ClipSaved ~= pinyins) ? ClipSaved : RegExReplace(ClipSaved, "[\w\s@#]")
    ClipSaved := ""
}

^+c::SendInput("{Ctrl Down}c{Ctrl Up}")