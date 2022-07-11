#NoTrayIcon

Process      Priority, , Realtime
FileEncoding UTF-8
CoordMode    Caret
CoordMode    Mouse
SetWinDelay  -1

#Include <Vark>

Global Settings := {"tempdir"      :  "G:\Temp\.vark\"
                  , "vimdir"       :  "D:\Program Files\Vim\vim90"
                  , "vimrc"        :  "G:\Assets\Tool\AutoHotkey\Vark\setting\vark.vimrc"
                  , "tempfilename" :  "Temp"
                  , "popsizes"     :  [960, 240]}

VimHere := new Vark(Settings)

#If WinActive("ahk_pid " VimHere.process_id)

#q::VimHere.Close(0)
#w::VimHere.Close(1)
#e::VimHere.Close(-1)
#r::VimHere.Close(2)

#If !WinActive("ahk_pid " VimHere.process_id)

#c::VimHere.Open()
#+c::VimHere.Clear()
