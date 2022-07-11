; Space 版派生捷径
;;; 使用 Space 作为前缀键，需搭配 Cloze 使用。效率较高，性能好；但兼容性不佳。
;;;;; 全局捷径
;;;;;;; Win + Q        设置当前激活窗口为标记窗口
;;;;;;; Space + Q      跳转到标记窗口
;;;;;;; Space + W      跳转到 Add 窗口
;;;;;;; Space + E      跳转到 Browse 窗口
;;;;;;; Space + R      跳转到 Anki 主窗口
;;;;;;; Space + A      复制
;;;;;;; Space + D      撤回
;;;;; Anki 捷径
;;;;;;; `              保存卡片
;;;;;;; CapsLock       输入 <br> 并换行
;;;;;;; Space + A      格式化输出（词性智能空格 & 标点智能替换为中文）
;;;;; 自定义捷径
;;;;;;; 添加 <key>::<command>

#q::WinId := WinActive("A")
Space & q::WinActivate ahk_id %WinId%
Space & w::WinActivate Add
Space & e::WinActivate Browse
Space & r::WinActivate PilgrimLyieu - Anki
Space & a::SendInput {Ctrl Down}c{Ctrl Up}
Space & d::SendInput {Ctrl Down}z{Ctrl Up}
Space::SendInput {Space}

#IfWinActive ahk_exe anki.exe
`::SendInput ^{Enter}
CapsLock::SendInput {Text}<br>`n
Space & a::
Result := RegexRePlace(Trim(Clipboard, " `t`r`n"), "(n|v|adj|adv|prep|conj|vt|vi)\.\s?", "$1. ")
for e, c in {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
    Result := RegexReplace(Result, (e ~= "[([]") ? ((e ~= "[.?()[\]]" ? "\" e : e) "(?=\s?[\x{4e00}-\x{9fa5}])") : ("(?:[\x{4e00}-\x{9fa5}]\s?)\K" (e ~= "[.?()[\]]" ? "\" e : e)), c)
SendInput {Text}%Result%
return
#IfWinActive