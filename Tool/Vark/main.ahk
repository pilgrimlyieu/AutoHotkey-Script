; #NoTrayIcon

ProcessSetPriority "Realtime"
FileEncoding "UTF-8"
CoordMode "Caret"
CoordMode "Mouse"
SetWinDelay -1

#Include <Vark>

global Settings := Map(
    "tempdir"   , "G:/Temp/.vark/",
    "vimrc"     , "G:/Project/Scripts/AutoHotkey/Tool/Vark/setting/vark.vimrc",
    "savetoclip", 1,
    "sendbyclip", 1,
    "popsizes"  , [960, 360],
)

Vim := Vark(Settings)

#HotIf WinActive("ahk_pid " Vim.process_id)

#q::Vim.Close(0)
#w::Vim.Close(1)
#e::Vim.Close(-1)
#r::Vim.Close(2)

#HotIf !WinActive("ahk_pid " Vim.process_id)

#c::Vim.Open()
#+c::Vim.Clear()