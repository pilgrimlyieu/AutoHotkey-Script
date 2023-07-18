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
;;;;;;; F3             自动化操作（清除 Board）
;;;;;;; F4             自动化操作（保留 Board）
;;;;; 自定义捷径
;;;;;;; 添加 <key>::<command>

SetTitleMatchMode 3

Get() {
    Clip := ClipboardAll
    SendInput {Ctrl Down}c{Ctrl Up}
    ClipWait 0
    content := Clipboard
    Clipboard := Clip
    return content
}

Clip(Text) {
    Text := RegExReplace(RegExReplace(Trim(Text, " `t`r`n"), "([a-z]+)\.\s?", "$1. "), "(*UCP)\s+", " ")
    for e, c in {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
        Text := RegExReplace(Text, (e ~= "[([]") ? ((e ~= "[.?()[\]]" ? "\" e : e) "(?=\s?[\x{4e00}-\x{9fa5}])") : ("(?:[\x{4e00}-\x{9fa5}]\s?)\K" (e ~= "[.?()[\]]" ? "\" e : e)), c)
    return "{Text}" Text
}

Put(clean := 1) {
    for index, value in Board {
        if (index < 3) {
            SendInput % Clip(value)
            SendInput {Tab}
            continue
        }
        if Mod(index, 2)
            SendInput % "{Text}{{c1::" Trim(value, " `t`r`n") "}} "
        else {
            SendInput % Clip(value)
            SendInput {Text}<br>`n
        }
    }
    SendInput {BackSpace 5}
    Sleep 1500
    SendInput {Ctrl Down}{Enter}{Ctrl Up}
    if clean
        Board := []
    return
}

Global Board := []

^q::WinActivate Add
^w::WinActivate Browse
^e::WinActivate PilgrimLyieu - Anki
f1::Board.Push(((Clip := Get()) != "") ? Clip :)
f2::Board := []
f3::
msg := ""
for index, value in Board
    msg .= index ": " value "`n"
MsgBox % msg
return

#IfWinActive Add

f1::SendInput % Clip(Board.RemoveAt(1))
f2::SendInput % "{Text}{{c1::" Trim(Board.RemoveAt(1), " `t`r`n") "}} "
f3::Put()
f4::Put(0)
+CapsLock::SendInput {Text}<i>eg.</i> `
