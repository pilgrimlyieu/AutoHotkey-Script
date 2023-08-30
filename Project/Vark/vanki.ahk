ProcessSetPriority "Realtime"
FileEncoding "UTF-8"
CoordMode "Caret"
CoordMode "Mouse"
SetWinDelay -1

#Include <Vanki>

global Settings := Map(
    "type"      , 1,
    "tempdir"   , "D:\Temp\vanki\",
    "historydir", "D:\Temp\vanki\.history\",
    "vimrc"     , "setting\vanki.vimrc",
    "savetoclip", 1,
    "sendbyclip", 1,
    "html"      , 0,
    "popsizes"  , [960, 300],
    "delimiter" , "`r`n<hr class='section'>`r`n`r`n",
)

VimAnki1 := Vark(Settings)
VimAnki2 := Vanki(Settings)
VimAnkis := [VimAnki1, VimAnki2]

#p::SwitchType()
#+p::StatusType()
#s::SwitchHTML()
#+s::StatusHTML()

SwitchType() {
    global VimAnkis
    Settings.type := !(Settings.type - 1) + 1
    ToolTip("Vanki type is turned to " Settings.type ".")
    SetTimer(() => ToolTip(), -1000)
}

StatusType() {
    ToolTip("Vanki type is " Settings.type ".")
    SetTimer(() => ToolTip(), -1000)
}

SwitchHTML() {
    global VimAnkis
    VimAnkis[Settings.type].HTML := !VimAnkis[Settings.type].HTML
    ToolTip(VimAnkis[Settings.type].HTML ? "HTML is turned on." : "HTML is turned off.")
    SetTimer(() => ToolTip(), -1000)
}

StatusHTML() {
    ToolTip(VimAnkis[Settings.type].HTML ? "HTML is on." : "HTML is off.")
    SetTimer(() => ToolTip(), -1000)
}

#HotIf WinActive("ahk_pid " VimAnkis[Settings.type].process_id)

#q::VimAnkis[Settings.type].Close(0)
#w::VimAnkis[Settings.type].Close(1)
#e::VimAnkis[Settings.type].Close(-1)
#r::VimAnkis[Settings.type].Close(2)
#t::VimAnkis[Settings.type].Empty()

#HotIf WinActive("ahk_exe anki.exe")

#1::VimAnkis[Settings.type].Open()
#y::VimAnkis[Settings.type].Combine()

#HotIf !WinActive("ahk_pid " VimAnkis[Settings.type].process_id)

#+1::VimAnkis[Settings.type].Clear()
