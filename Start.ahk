#Requires AutoHotkey v1.1.37+

Dir := A_WorkingDir "\"
AHK_Dir := "C:\Program Files\AutoHotkey\UX\"

Scripts := [ ;"Basic\Shutdown\Shutdown"
          , "Basic\Window\WinDrag\main"
          , "Basic\Remap\Fn"
          , "Basic\Remap\NumLock"
          , "Basic\Remap\Others"

          , "General\Tips\Run"
          , "General\Correction\Pinyin"
          , "General\Abbreviation\Common"
          , "General\AHKMapCheatSheet\Mappings"

          , "Specific\Vim\Vim"
          ; , "Specific\Anki\Must"

          , "Tool\Vark\main"]

for index, script in Scripts
    Run % """" AHK_Dir "AutoHotkeyUX.exe"" """ AHK_Dir "launcher.ahk"" /restart """ Dir script ".ahk"""
