Dir := A_WorkingDir "/"
AHK_Dir := "C:/Program Files/AutoHotkey/UX/"

Scripts := [
    ; "Basic/Shutdown/Shutdown.ahk1",
    "Basic/Window/WinDrag/main.ahk1",
    "Basic/Remap/Fn.ahk",
    "Basic/Remap/NumLock.ahk",
    "Basic/Remap/Others.ahk",

    "General/Tips/Run.ahk",
    "General/Correction/Pinyin.ahk",
    "General/Abbreviation/Common.ahk",
    "General/AHKMapCheatSheet/Mappings.ahk",

    "Specific/Vim/Vim.ahk",
    ; "Specific/Anki/Must.ahk1",

    "Tool/Vark/main.ahk",
]

for index, script in Scripts
    Run "`"" AHK_Dir "AutoHotkeyUX.exe`" `"" AHK_Dir "launcher.ahk`" /restart `"" Dir script