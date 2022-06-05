Global pinyins := "\w*[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜü]\w*", Board := {"Word": "", "Definition": "", "Sentence": "", "Prefix": ""}, Temp := ""

Clean(string) {
    if !(string ~= pinyins)
        string := RegexReplace(string, "[\w\d\s@#]")
    return string
}

Get(sentence := 0, prefix := 0) {
    Clipboard := ""
    SendInput {Ctrl Down}c{Ctrl Up}
    ClipWait 0
    if sentence
        Board.Sentence := Clean(Clipboard)
    else if prefix
        Board.Prefix := Clean(Clipboard)
    else if Board.Word
        Board.Definition := Clean(Clipboard)
    else
        Board.Word := Clean(Clipboard)
    Clipboard := ""
}

Put() {
    if Board.Word {
        SendInput % Board.Word
        Temp := Board.Word
        Board.Word := ""
    }
    else if Board.Definition {
        SendInput % Board.Definition
        Board.Definition := ""
    }
    else {
        SendInput % "{Text}《" Board.Prefix "》：" Board.Sentence
        Temp := ""
    }
}

f1::Get()
f2::Get(1)
f3::Get(0, 1)
f4::Board.Word := "", Board.Definition := ""
f5::Board.Word := "", Board.Definition := "", Board.Sentence := ""
f6::Board.Word := "", Board.Definition := "", Board.Sentence := "", Board.Prefix := ""
f7::
msg := ""
for index, value in Board
    msg .= index ": " value "`n"
MsgBox % msg
return

#IfWinActive ahk_exe anki.exe
f1::Put()
f2::
loop 3 {
    Put()
    SendInput {Tab}
}
return
