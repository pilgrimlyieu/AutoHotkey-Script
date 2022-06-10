Have_Label(text, start_label, end_label) {
    return SubStr(text, 1, StrLen(start_label)) = start_label and SubStr(text, - StrLen(end_label) + 1) = end_label
}

Insert_Label(text, start_label, end_label) {
    return start_label text end_label
}

Delete_Label(text, start_label, end_label) {
    return SubStr(text, StrLen(start_label) + 1, StrLen(text) - StrLen(end_label) - StrLen(start_label))
}

Label(label) {
    clip := Clipboard
    Clipboard := ""
    SendInput {Ctrl Down}x{Ctrl Up}
    ClipWait 0
    text := Trim(Clipboard, " `t`r`n")
    start_label := "<" label ">"
    end_label := "</" label ">"
    Clipboard := clip
    if (text = "") {
        SendInput % "{Text}" start_label end_label
        time := StrLen(end_label)
        SendInput {Left %time%}
        return
    }
    have_label := Have_Label(text, start_label, end_label)
    if have_label
        SendInput % "{Text}" Delete_Label(text, start_label, end_label)
    else
        SendInput % "{Text}" Insert_Label(text, start_label, end_label)
}

!a::Label("nhl")
