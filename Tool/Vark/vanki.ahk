Process      Priority, , Realtime
FileEncoding UTF-8
CoordMode    Caret
CoordMode    Mouse
SetWinDelay  -1

#Include <Vanki>

Global Settings := {"type"      : 1
                  , "tempdir"   : "G:\Temp\.vanki\"
                  , "historydir": "G:\Temp\.vanki\.history\"
                  , "vimdir"    : "D:\Program Files\Vim\vim90"
                  , "vimrc"     : "G:\Assets\Tool\AutoHotkey\Tool\Vark\setting\vanki.vimrc"
                  , "savetoclip": 1
                  , "sendbyclip": 1
                  , "html"      : 0
                  , "popsizes"  : [960, 300]
                  , "delimiter" : "`r`n<hr class='section'>`r`n`r`n"}

VimAnki1 := new Vark(Settings)
VimAnki2 := new Vanki(Settings)
VimAnkis := [VimAnki1, VimAnki2]

#p::Gosub SwitchType
#+p::Gosub StatusType
#s::Gosub SwitchHTML
#+s::Gosub StatusHTML

SwitchType:
Settings.type := !(Settings.type - 1) + 1
ToolTip % "Vanki type is turned to " Settings.type "."
SetTimer RemoveToolTip, -1000
return

StatusType:
ToolTip % "Vanki type is " Settings.type "."
SetTimer RemoveToolTip, -1000
return

SwitchHTML:
VimAnkis[Settings.type].HTML := !VimAnkis[Settings.type].HTML
ToolTip % VimAnkis[Settings.type].HTML ? "HTML is turned on." : "HTML is turned off."
SetTimer RemoveToolTip, -1000
return

StatusHTML:
ToolTip % VimAnkis[Settings.type].HTML ? "HTML is on." : "HTML is off."
SetTimer RemoveToolTip, -1000
return

RemoveToolTip:
ToolTip
return

#If WinActive("ahk_pid " VimAnkis[Settings.type].process_id)

#q::VimAnkis[Settings.type].Close(0)
#w::VimAnkis[Settings.type].Close(1)
#e::VimAnkis[Settings.type].Close(-1)
#r::VimAnkis[Settings.type].Close(2)
#t::VimAnkis[Settings.type].Empty()

#If WinActive("ahk_exe anki.exe")

#1::VimAnkis[Settings.type].Open()
#y::VimAnkis[Settings.type].Combine()

#If !WinActive("ahk_pid " VimAnkis[Settings.type].process_id)

#+1::VimAnkis[Settings.type].Clear()
