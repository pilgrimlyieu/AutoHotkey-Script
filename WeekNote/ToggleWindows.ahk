Global browser := "", note := ""

#w::browser := WinActive("A")
#e::note := WinActive("A")
#q::
win := WinActive("A")
if (win = note)
    WinActivate ahk_id %browser%
else if (win = browser)
    WinActivate ahk_id %note%
return
