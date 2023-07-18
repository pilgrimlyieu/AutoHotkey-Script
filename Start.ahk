#Requires AutoHotkey v1.1.37+

Dir := A_WorkingDir "\"

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
    Run % "autohotkey.exe /restart /CP65001 " Dir script ".ahk"
