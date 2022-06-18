Global browser := "", note := ""

#w::browser := WinActive("A")
#e::note := WinActive("A")
#q::WinActivate ahk_id % (WinActive("A") = note) ? browser : note
