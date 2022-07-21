; Anki Cloze
;;; 特性   Features
;;;;; 1. 自动清除首尾空白字符                         Automatically clean left and right empty character
;;;;; 2. 自动添加尾部空格                             Automatically add right space
;;;;; 3. 末尾字符是 '}'' 时自动添加空格               Automatically add space if right character is '}'
;;;;; 4. 自动将 '}}' 改为 '} }'                       Automatically change '}}' to '} }'
;;;;; 5. 未选中内容输入空白 Cloze 并移动光标至其中    Create empty Cloze and put cursor into it while selecting nothing
;;; 有待支持特性 Unsupported Features
;;;;; 1. 多光标支持                                   Multiple cursors supprot
;;; Anki 捷径   Anki Shortcuts
;;;;; Shift + F1            重置 Cloze 序数           Reset Cloze order
;;;;; F5                    保持 Cloze 序数           Keeping Cloze order
;;;;; F6                    递增 Cloze 序数           Growing Cloze order
;;;;; `                     HTML 换行                 HTML Linebreak
;;;;; Shift + `             保存卡片并清除序数        Save card and Reset Cloze order

Cloze(keep := 0) {
    clip := Clipboard
    Clipboard := ""
    SendInput {Ctrl Down}x{Ctrl Up}
    ClipWait 0
    Text := Trim(Clipboard, " `t`r`n")
    Clipboard := clip
    (!(keep and turn)) ? turn ++
    if (Text = "") {
        SendInput % "{Text}{{c" turn "::}}"
        SendInput {Left 2}
    }
    else if (SubStr(Text, 1, 3) = "{{c" and SubStr(Text, -1, 2) = "}}" and InStr(Text, "::") > 4) {
        (!(keep and turn)) ? turn --
        SendInput % "{Text}" SubStr(Text, InStr(Text, "::") + 2, StrLen(Text) - 8)
    }
    else
        SendInput % "{Text}{{c" turn "::" StrReplace(StrReplace(Text, "}}", "} }"), "}}", "} }") ((SubStr(Text, 0) = "}") ? " }}" : "}}")
}

Global turn := 0

#IfWinActive ahk_exe anki.exe

+f1::turn := 0
f5::Cloze(1)
f6::Cloze()
`::SendInput {Text}<br>`n

#InputLevel 1

+`::SendInput {Ctrl Down}{Enter}{Ctrl Up}{Shift Down}{F1}{Shift Up}
