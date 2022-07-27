Global pinyins := "^\w*[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü]\w*$"

Clean(string) {
    if !(string ~= pinyins)
        string := RegExReplace(string, "[\w\s@#]")
    return string
}

#IfWinActive ahk_exe SumatraPDF.exe

$^c::
SendInput {Ctrl Down}c{Ctrl Up}
ClipWait 3
Clip:= RegExReplace(Clipboard, "\s*\v+\s*")
Clipboard := Clean(Clip)
return

^+c::SendInput {Ctrl Down}c{Ctrl Up}
