Show() {
    text := "Windows IDs:"
    for index, value in windows
        text .= "`r" index ": " value
    return text
}

IndexOf(item, list) {
    for index, value in list
        if (value = item)
            return index
    return 0
}

Global windows := []

#q::
win := WinActive("A")
index := IndexOf(win, windows)
if (index = windows.Length())
    actwin := windows[1]
else
    actwin := windows[index + 1]
WinActivate ahk_id %actwin%
return

#w::
win := WinActive("A")
if !IndexOf(win, windows)
    windows.Push(win)
return

#e::MsgBox % Show()

#r::
InputBox order, Delete Window ID, % Show(), , , , , , , 10, 1
if !ErrorLevel
    windows.RemoveAt(order)
return
