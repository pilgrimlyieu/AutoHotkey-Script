; Board 版派生捷径
;;; 使用 Borad 储存复制结果。效率高，性能好，兼容性较好。
;;;;; 全局捷径
;;;;;;; Ctrl + Q       跳转到 Add 窗口
;;;;;;; Ctrl + W       跳转到 Browse 窗口
;;;;;;; Ctrl + E       跳转到 Anki 主窗口
;;;;;;; F1             储存内容到 Board
;;;;;;; F2             清除 Board 内容
;;;;;;; F3             获取 Board 内容
;;;;; Anki 捷径
;;;;;;; `              保存卡片
;;;;;;; CapsLock       输入 <br> 并换行
;;;;;;; F1             格式化输出（词性智能空格 & 标点智能替换为中文）
;;;;;;; F2             格式化输出（自动添加 Cloze）
;;;;; 自定义捷径
;;;;;;; 添加 <key>::<command>

Get() {
    Clipboard := ""
    SendInput {Ctrl Down}c{Ctrl Up}
    ClipWait 1
    return Clipboard
}
Clip(Text) {
    Text := RegexRePlace(Trim(Text, " `t`r`n"), "(n|v|adj|adv|prep|conj|vt|vi)\.\s?", "$1. ")
    for e, c in {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
        Text := RegexReplace(Text, (e ~= "[([]") ? ((e ~= "[.?()[\]]" ? "\" e : e) "(?=\s?[\x{4e00}-\x{9fa5}])") : ("(?:[\x{4e00}-\x{9fa5}]\s?)\K" (e ~= "[.?()[\]]" ? "\" e : e)), c)
    return "{Text}" Text
}

Global Board := []

^q::WinActivate Add
^w::WinActivate Browse
^e::WinActivate PilgrimLyieu - Anki
f1::Board.Push((Clip := Get()) != "" ? Clip :)
f2::Board := []
f3::
msg := ""
for index, value in Board
    msg .= index ": " value "`n"
MsgBox % msg
return

#IfWinActive ahk_exe anki.exe
f1::SendInput % Clip(Board.RemoveAt(1))
f2::SendInput % "{Text}{{c1::" Trim(Board.RemoveAt(1), " `t`r`n") "}} "
`::SendInput ^{Enter}
CapsLock::SendInput {Text}<br>`n
#IfWinActive