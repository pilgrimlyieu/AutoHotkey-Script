Process     Priority, , Realtime
CoordMode   Caret
CoordMode   Mouse
SetWinDelay -1

#Include <Vark>

Global Settings := {"tempdir"      :  "G:\Temp\.vark\"
                  , "vimdir"       :  "C:\Program Files\Vim\vim82"
                  , "vimrc"        :  "G:\Assets\Tool\AutoHotkey\Vark\setting\vark.vimrc"
                  , "tempfilename" :  "Temp"
                  , "popsizes"     :  [960, 240]}

VimHere := new Vark(Settings)

#If WinActive("ahk_pid " VimHere.process_id)

#q::VimHere.Close(0)
#w::VimHere.Close(1)
#e::VimHere.Close(-1)

#If !WinActive("ahk_pid " VimHere.process_id)

#v::VimHere.Open()
#+v::VimHere.Clear()
