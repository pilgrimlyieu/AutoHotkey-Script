#Include <Derive>

class AnkiCloze {
    static turn := 0

    __GetText(cut := 1) {
        Clipboard := ""
        if cut
            SendInput {Ctrl Down}x{Ctrl Up}
        else
            SendInput {Ctrl Down}c{Ctrl Up}
        ClipWait 0
        this.text := Clipboard
    }

    Cloze(keep := 0) {
        this.__GetText()
        text := Trim(this.text, " `t`r`n")
        (!keep or !this.turn) ? this.turn ++
        if (text = "") {
            SendInput % "{Text}{{c" this.turn "::}} "
            SendInput {Left 3}
        }
        else if (SubStr(text, 1, 3) = "{{c" and SubStr(text, -1, 2) = "}}" and InStr(text, "::") > 4) {
            (!keep or !this.turn) ? this.turn --
            SendInput % "{Text}" SubStr(text, InStr(text, "::") + 2, StrLen(text) - 8) " "
        }
        else
            SendInput % "{Text}{{c" this.turn "::" text ((SubStr(text, 0) = "}") ? " }} " : "}} ")
    }
}

a := Derive.PartofSpeech()
msgbox % a
