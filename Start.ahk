Dir := A_WorkingDir "\"

Scripts := ["Basic\Shutdown\Shutdown"
          , "Basic\Window\WinDrag\main"
          , "Basic\Remap\Fn"

          , "General\Tips\Run"
          , "General\Correction\Pinyin"
          , "General\Abbreviation\Common"
          , "General\AHKMapCheatSheet\Mappings"

          , "Specific\Vim\Vim"
          , "Specific\Vim\KeyMap"

          , "Tool\Vark\main"]

For index, script in Scripts
    Run % "AutoHotkey.exe /restart /CP65001 " Dir script ".ahk"
