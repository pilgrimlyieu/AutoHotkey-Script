#NoTrayIcon

Process      Priority, , Realtime
FileEncoding UTF-8
CoordMode    Caret
CoordMode    Mouse
SetWinDelay  -1

#Include <Vark>

Global Settings := {"tempdir"     : "G:\Temp\.vark\"
                  , "vimdir"      : "D:\Program Files\Vim\vim90"
                  , "vimrc"       : "G:\Assets\Tool\AutoHotkey\Tool\Vark\setting\vark.vimrc"
                  , "tempfilename": "Temp"
                  , "savetoclip"  : 1
                  , "popsizes"    : [960, 360]}

Vim := new Vark(Settings)

#If WinActive("ahk_pid " Vim.process_id)

#q::Vim.Close(0)
#w::Vim.Close(1)
#e::Vim.Close(-1)
#r::Vim.Close(2)

#If !WinActive("ahk_pid " Vim.process_id)

#c::Vim.Open()
#+c::Vim.Clear()
