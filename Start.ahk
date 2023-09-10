AHK_Dir := "C:/Program Files/AutoHotkey/UX/"

Scripts := [
    "Basic/Abbreviation.ahk",
    "Basic/Correction.ahk",
    "Basic/Remap.ahk",
    "Basic/Window/WinDrag/main.ahk1",

    "General/Common.ahk",
    "General/Health.ahk",
    "General/Specific.ahk",

    "Project/Vark/main.ahk",
]

Programs := [
    "_Compiled/OCRC.exe",
]

for index, script in Scripts
    Run("`"" AHK_Dir "AutoHotkeyUX.exe`" `"" AHK_Dir "launcher.ahk`" /restart `"" script)
for index, program in Programs
    Run(program)
