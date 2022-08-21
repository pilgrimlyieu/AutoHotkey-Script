Process      Priority, , Realtime
FileEncoding UTF-8
CoordMode    Caret
CoordMode    Mouse
SetWinDelay  -1

#Include <Vanki>

Global Settings := {"tempdir"        : "G:\Temp\.vanki\"
                  , "historydir"     : "G:\Temp\.vanki\.history\"
                  , "vimdir"         : "D:\Program Files\Vim\vim90"
                  , "vimrc"          : "G:\Assets\Tool\AutoHotkey\Tool\Vark\setting\vanki.vimrc"
                  , "tempfilename"   : "Temp_"
                  , "mixfilename"    : "Mix.md"
                  , "combinefilename": "Combine.md"
                  , "savetoclip"     : 1
                  , "sendbyclip"     : 1
                  , "popsizes"       : [960, 300]
                  , "delimiter"      : "`r`n<hr class='section'>`r`n`r`n"}

VimAnki := new Vanki(Settings)

#If WinActive("ahk_pid " VimAnki.process_id)

#q::VimAnki.Close(0)
#w::VimAnki.Close(1)
#e::VimAnki.Close(-1)
#r::VimAnki.Close(2)
#t::VimAnki.Empty()

#If WinActive("ahk_exe anki.exe")

#1::VimAnki.Open()
#y::VimAnki.Combine()

#If !WinActive("ahk_pid " VimAnki.process_id)

#+1::VimAnki.Clear()
