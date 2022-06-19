Process     Priority, , Realtime
CoordMode   Caret
SetWinDelay -1

#Include <Vanki>

Global Settings := {"tempdir"         :  "G:\Temp\.vanki\"
                  , "historydir"      :  "G:\Temp\.vanki\.history\"
                  , "vimdir"          :  "C:\Program Files\Vim\vim82"
                  , "vimrc"           :  "G:\Assets\Tool\AutoHotkey\Vark\setting\vanki.vimrc"
                  , "tempfilename"    :  "Temp_"
                  , "mixfilename"     :  "Mix.md"
                  , "combinefilename" :  "Combine.md"
                  , "popsizes"        :  [960, 240]
                  , "delimiter"       :  "`r`n<hr class='section'>`r`n`r`n"}

VimAnki := new Vanki(Settings)

^w::VimAnki.Close(0)
^e::VimAnki.Close(1)
^r::VimAnki.Close(-1)

#IfWinNotActive ahk_class Vim

^q::VimAnki.Open()
^t::VimAnki.Combine()
^y::VimAnki.Clear()
