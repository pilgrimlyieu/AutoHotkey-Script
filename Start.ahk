AHK_Dir := "C:/Program Files/AutoHotkey/UX/"

Scripts := [
    "Basic/Abbreviation/Email.ahk",
    ; "Basic/Correction/AutoCorrect.ahk1",
    "Basic/Correction/Pinyin.ahk",
    ; "Basic/Remap/Fn.ahk",
    "Basic/Remap/NumLock.ahk",
    "Basic/Remap/Others.ahk",
    "Basic/Remap/Punctuation.ahk",
    "Basic/Window/WinDrag/main.ahk1",

    "General/Common/Run.ahk",
    "General/Health/MouseHand.ahk",
    "General/Specific/Vim/Vim.ahk",
    "General/Specific/WindowsTerminal.ahk",

    "Project/Vark/main.ahk",
]

Programs := [
    "_Compiled/OCRC.exe",
]

for index, script in Scripts
    Run("`"" AHK_Dir "AutoHotkeyUX.exe`" `"" AHK_Dir "launcher.ahk`" /restart `"" script)
for index, program in Programs
    Run(program)
