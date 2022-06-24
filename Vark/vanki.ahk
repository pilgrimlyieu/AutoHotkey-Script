Process     Priority, , Realtime
CoordMode   Caret
CoordMode   Mouse
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

#q::VimAnki.Close(0)
#w::VimAnki.Close(1)
#e::VimAnki.Close(-1)

#IfWinNotActive ahk_class Vim

#1::VimAnki.Open()
#t::VimAnki.Combine()
#+1::VimAnki.Clear()
